#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
from dataclasses import dataclass
from pathlib import Path

try:
    import tomllib
except ModuleNotFoundError:  # pragma: no cover - exercised on Python <3.11
    tomllib = None


VERSION_KEY_RE = re.compile(r"[^A-Za-z0-9]+")


@dataclass(frozen=True)
class Release:
    version: str
    channel: str
    date: str | None
    assets: tuple[str, ...]
    path: Path

    @property
    def base_version(self) -> str:
        return self.version.split("-", 1)[0]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Construct localized Arbor changelog or release-note Markdown."
    )
    parser.add_argument("--release-notes-dir", default="release-notes")
    parser.add_argument("--output", default=".generated/shared/content/generated/CHANGELOG.md")
    parser.add_argument("--content-root", default="content")
    parser.add_argument("--language", default=None)
    parser.add_argument(
        "--release-version",
        default=None,
        help="Render one release note instead of the complete changelog.",
    )
    parser.add_argument(
        "--release-metadata",
        default=None,
        help="Render the release whose canonical metadata is at this path.",
    )
    return parser.parse_args()


def parse_simple_value(value: str) -> object:
    if value == "true":
        return True
    if value == "false":
        return False
    if value.startswith('"') and value.endswith('"'):
        return json.loads(value)
    if value.startswith("'") and value.endswith("'"):
        return value[1:-1]
    if value.startswith("[") and value.endswith("]"):
        inner = value[1:-1].strip()
        if not inner:
            return []
        return [parse_simple_value(part.strip()) for part in inner.split(",")]
    raise SystemExit(f"Unsupported TOML value: {value}")


def parse_simple_toml(path: Path) -> dict:
    root: dict[str, object] = {}
    current = root

    for line_number, line in enumerate(
        path.read_text(encoding="utf-8").splitlines(),
        start=1,
    ):
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        if stripped.startswith("[") and stripped.endswith("]"):
            current = root
            for part in stripped[1:-1].split("."):
                current = current.setdefault(part, {})  # type: ignore[assignment]
            continue

        key, separator, value = stripped.partition("=")
        if not separator:
            raise SystemExit(f"{path}:{line_number}: expected key = value")
        current[key.strip()] = parse_simple_value(value.strip())

    return root


def load_toml(path: Path) -> dict:
    if not path.exists():
        return {}
    if tomllib is None:
        return parse_simple_toml(path)
    with path.open("rb") as handle:
        return tomllib.load(handle)


def deep_merge(base: dict, overlay: dict) -> dict:
    merged = dict(base)
    for key, value in overlay.items():
        if isinstance(value, dict) and isinstance(merged.get(key), dict):
            merged[key] = deep_merge(merged[key], value)
        else:
            merged[key] = value
    return merged


def discover_locales(content_root: Path) -> tuple[dict[str, dict], str]:
    locales = {}
    defaults = []
    for locale_file in sorted((content_root / "locales").glob("*/locale.toml")):
        code = locale_file.parent.name
        data = load_toml(locale_file)
        locales[code] = data
        if data.get("default") is True:
            defaults.append(code)

    if len(defaults) != 1:
        raise SystemExit(f"Expected exactly one default locale, found {defaults or 'none'}")
    return locales, defaults[0]


def locale_chain(language: str, locales: dict[str, dict]) -> list[str]:
    if language not in locales:
        raise SystemExit(f"Unknown locale {language!r}")

    chain = [language]
    for fallback in locales[language].get("fallback", []):
        if fallback not in locales:
            raise SystemExit(f"Locale {language!r} references unknown fallback {fallback!r}")
        if fallback not in chain:
            chain.append(fallback)
    return chain


def localized_release_data(
    content_root: Path,
    language: str,
    locales: dict[str, dict],
) -> dict:
    data: dict = {}
    for code in reversed(locale_chain(language, locales)):
        data = deep_merge(data, load_toml(content_root / "locales" / code / "release.toml"))
    return data


def load_releases(root: Path) -> list[Release]:
    releases = []
    for path in sorted(root.rglob("*.toml")):
        data = load_toml(path)
        version = data.get("version")
        channel = data.get("channel")
        if not isinstance(version, str) or not version:
            raise SystemExit(f"{path}: version must be a non-empty string")
        if channel not in {"stable", "pre-release"}:
            raise SystemExit(f"{path}: channel must be 'stable' or 'pre-release'")

        date = data.get("date")
        assets = data.get("assets", [])
        if date is not None and not isinstance(date, str):
            raise SystemExit(f"{path}: date must be a string")
        if not isinstance(assets, list) or not all(isinstance(asset, str) for asset in assets):
            raise SystemExit(f"{path}: assets must be an array of strings")

        releases.append(Release(version, channel, date, tuple(assets), path))

    versions = [release.version for release in releases]
    duplicates = sorted({version for version in versions if versions.count(version) > 1})
    if duplicates:
        raise SystemExit(f"Duplicate release metadata: {', '.join(duplicates)}")
    return sorted(releases, key=lambda release: version_sort_key(release.version), reverse=True)


def version_sort_key(version: str) -> tuple[tuple[int, ...], int, str]:
    stable, separator, suffix = version.removeprefix("v").partition("-")
    numbers = tuple(int(part) for part in stable.split("."))
    return numbers, 1 if not separator else 0, suffix


def release_key(version: str) -> str:
    return VERSION_KEY_RE.sub("_", version).strip("_")


def release_strings(data: dict, release: Release) -> dict:
    releases = data.get("releases", {})
    localized = releases.get(release_key(release.version), {}) if isinstance(releases, dict) else {}
    if not isinstance(localized, dict):
        localized = {}
    if localized.get("version") != release.version:
        raise SystemExit(
            f"Missing localized release prose for {release.version}; "
            f"expected releases.{release_key(release.version)} in release.toml"
        )
    sections = localized.get("sections", {})
    if not isinstance(sections, dict) or not sections:
        raise SystemExit(f"Localized release {release.version} has no sections")
    return localized


def render_sections(localized: dict, heading_level: int) -> list[str]:
    lines: list[str] = []
    sections = localized["sections"]
    for section_id, section in sections.items():
        if not isinstance(section, dict):
            raise SystemExit(f"Release section {section_id} must be a table")
        kind = section.get("kind")
        heading = section.get("heading")
        if kind not in {"prose", "list"} or not isinstance(heading, str):
            raise SystemExit(f"Release section {section_id} needs kind and heading")

        lines.extend([f"{'#' * heading_level} {heading}", ""])
        if kind == "prose":
            body = section.get("body")
            if not isinstance(body, str) or not body:
                raise SystemExit(f"Prose release section {section_id} needs body")
            lines.extend([body, ""])
        else:
            items = [
                (key, value)
                for key, value in section.items()
                if key.startswith("item_") and isinstance(value, str)
            ]
            if not items:
                raise SystemExit(f"List release section {section_id} needs item_N values")
            for _key, item in sorted(items):
                lines.append(f"- {item}")
            lines.append("")
    return lines


def changelog_labels(data: dict) -> dict[str, str]:
    changelog = data.get("changelog", {})
    if not isinstance(changelog, dict):
        raise SystemExit("release.toml must contain [changelog]")
    required = ("title", "intro", "empty", "stable", "pre_release")
    missing = [key for key in required if not isinstance(changelog.get(key), str)]
    if missing:
        raise SystemExit(f"release.toml changelog is missing: {', '.join(missing)}")
    return {key: changelog[key] for key in required}


def render_release_note(release: Release, localized: dict, labels: dict[str, str]) -> str:
    channel = labels["stable"] if release.channel == "stable" else labels["pre_release"]
    lines = [f"## {release.version}", "", f"{channel}: {release.date or ''}".rstrip(), ""]
    lines.extend(render_sections(localized, heading_level=3))
    return "\n".join(lines).rstrip() + "\n"


def render_changelog(releases: list[Release], data: dict) -> str:
    labels = changelog_labels(data)
    lines = [
        f"# {labels['title']}",
        "",
        labels["intro"],
        "",
        "<!-- Constructed from release metadata and locale resources. Do not edit by hand. -->",
        "",
    ]
    if not releases:
        lines.extend([labels["empty"], ""])

    grouped: dict[str, list[Release]] = {}
    for release in releases:
        grouped.setdefault(release.base_version, []).append(release)

    for base in sorted(grouped, key=version_sort_key, reverse=True):
        group = grouped[base]
        stable = [release for release in group if release.channel == "stable"]
        date = (stable or group)[0].date
        heading = f"## {base}" + (f" - {date}" if date else "")
        lines.extend([heading, ""])

        for channel, label_key in (("stable", "stable"), ("pre-release", "pre_release")):
            channel_releases = [release for release in group if release.channel == channel]
            if not channel_releases:
                continue
            lines.extend([f"### {labels[label_key]}", ""])
            for release in channel_releases:
                if channel == "pre-release":
                    suffix = release.version.split("-", 1)[1]
                    lines.extend([f"#### {suffix}" + (f" - {release.date}" if release.date else ""), ""])
                    section_level = 5
                else:
                    section_level = 4
                lines.extend(render_sections(release_strings(data, release), section_level))

    return "\n".join(lines).rstrip() + "\n"


def main() -> None:
    args = parse_args()
    content_root = Path(args.content_root)
    locales, default_language = discover_locales(content_root)
    language = args.language or default_language
    data = localized_release_data(content_root, language, locales)
    releases = load_releases(Path(args.release_notes_dir))

    selected_version = args.release_version
    if args.release_metadata:
        metadata_path = Path(args.release_metadata).resolve()
        metadata_matches = [release for release in releases if release.path.resolve() == metadata_path]
        if len(metadata_matches) != 1:
            raise SystemExit(
                f"Expected one release for metadata {args.release_metadata!r}, "
                f"found {len(metadata_matches)}"
            )
        selected_version = metadata_matches[0].version

    if selected_version:
        matches = [release for release in releases if release.version == selected_version]
        if len(matches) != 1:
            raise SystemExit(f"Expected one release {selected_version!r}, found {len(matches)}")
        output = render_release_note(
            matches[0],
            release_strings(data, matches[0]),
            changelog_labels(data),
        )
    else:
        output = render_changelog(releases, data)

    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(output, encoding="utf-8", newline="\n")
    print(f"Constructed localized Markdown: {output_path}")


if __name__ == "__main__":
    main()
