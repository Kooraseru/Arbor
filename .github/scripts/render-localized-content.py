#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
import shutil
import sys
from dataclasses import dataclass
from pathlib import Path

try:
    import tomllib
except ModuleNotFoundError:  # pragma: no cover - exercised on Python < 3.11
    tomllib = None


PLACEHOLDER_RE = re.compile(r"\{\{\s*([A-Za-z0-9_.-]+)\s*\}\}")


@dataclass(frozen=True)
class Locale:
    code: str
    path: Path
    name: str
    native_name: str
    locale: str
    default: bool
    published: bool
    fallback: tuple[str, ...]


def load_toml(path: Path) -> dict:
    if not path.exists():
        return {}

    if tomllib is None:
        return parse_simple_toml(path)

    with path.open("rb") as handle:
        return tomllib.load(handle)


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
    lines = path.read_text(encoding="utf-8").splitlines()
    line_number = 0

    while line_number < len(lines):
        line_number += 1
        line = lines[line_number - 1]
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
        value = value.strip()

        if value == "'''":
            multiline: list[str] = []
            while line_number < len(lines):
                line_number += 1
                multiline_line = lines[line_number - 1]
                if multiline_line == "'''":
                    break
                multiline.append(multiline_line)
            else:
                raise SystemExit(f"{path}:{line_number}: unterminated multiline literal string")

            current[key.strip()] = "\n".join(multiline)
            continue

        current[key.strip()] = parse_simple_value(value)

    return root


def flatten(data: dict, prefix: str = "") -> dict[str, str]:
    flattened: dict[str, str] = {}

    for key, value in data.items():
        path = f"{prefix}.{key}" if prefix else str(key)
        if isinstance(value, dict):
            flattened.update(flatten(value, path))
        elif isinstance(value, str):
            flattened[path] = value
        else:
            raise SystemExit(f"Unsupported localized value for {path}: expected string or table")

    return flattened


def load_locale(locale_path: Path) -> Locale:
    data = load_toml(locale_path / "locale.toml")
    code = locale_path.name

    return Locale(
        code=code,
        path=locale_path,
        name=str(data.get("name", code)),
        native_name=str(data.get("native_name", data.get("name", code))),
        locale=str(data.get("locale", code)),
        default=bool(data.get("default", False)),
        published=bool(data.get("published", True)),
        fallback=tuple(data.get("fallback", [])),
    )


def discover_locales(locales_root: Path) -> list[Locale]:
    locales = [
        load_locale(path)
        for path in sorted(locales_root.iterdir())
        if path.is_dir() and (path / "locale.toml").exists()
    ]
    defaults = [locale.code for locale in locales if locale.default]

    if len(defaults) != 1:
        raise SystemExit(f"Expected exactly one default locale, found {defaults or 'none'}")

    return locales


def locale_chain(locale: Locale, locales: dict[str, Locale]) -> list[Locale]:
    chain = [locale]

    for fallback_code in locale.fallback:
        if fallback_code not in locales:
            raise SystemExit(f"{locale.path / 'locale.toml'} references unknown fallback locale {fallback_code!r}")
        chain.append(locales[fallback_code])

    return chain


def load_strings(chain: list[Locale]) -> dict[str, str]:
    strings: dict[str, str] = {}

    for locale in reversed(chain):
        strings.update(flatten(load_toml(locale.path / "strings.toml")))
        strings.update(flatten(load_toml(locale.path / "readme.toml")))

    return strings


def render_template(text: str, strings: dict[str, str], source_path: Path) -> tuple[str, set[str]]:
    used: set[str] = set()
    missing: set[str] = set()

    def replace(match: re.Match[str]) -> str:
        key = match.group(1)
        used.add(key)
        if key not in strings:
            missing.add(key)
            return match.group(0)
        return strings[key]

    rendered = PLACEHOLDER_RE.sub(replace, text)

    if missing:
        missing_list = ", ".join(sorted(missing))
        raise SystemExit(f"{source_path}: missing localized string(s): {missing_list}")

    return rendered, used


def copy_tree(
    source_root: Path,
    destination_root: Path,
    strings: dict[str, str],
    excluded: set[Path] | None = None,
) -> set[str]:
    used: set[str] = set()
    excluded = excluded or set()

    if not source_root.exists():
        return used

    for source_path in sorted(source_root.rglob("*")):
        if source_path.is_dir():
            continue

        relative = source_path.relative_to(source_root)
        if relative in excluded:
            continue
        destination_path = destination_root / relative
        destination_path.parent.mkdir(parents=True, exist_ok=True)

        text_suffixes = {".md", ".html", ".txt", ".toml", ".yml", ".yaml", ".json"}
        if source_path.suffix.lower() in text_suffixes:
            rendered, path_used = render_template(source_path.read_text(encoding="utf-8"), strings, source_path)
            destination_path.write_text(rendered, encoding="utf-8", newline="\n")
            used.update(path_used)
        else:
            shutil.copy2(source_path, destination_path)

    return used


def render_api_pages(
    content_root: Path,
    output_locale_root: Path,
    strings: dict[str, str],
) -> tuple[set[str], set[Path]]:
    manifest_path = content_root / "api" / "reference.toml"
    manifest = load_toml(manifest_path)
    pages = manifest.get("pages", {})
    if not isinstance(pages, dict) or not pages:
        raise SystemExit(f"{manifest_path}: expected a non-empty [pages] table")

    used: set[str] = set()
    sources: set[Path] = set()
    outputs: set[Path] = set()

    for page_id, page in pages.items():
        if not isinstance(page, dict):
            raise SystemExit(f"{manifest_path}: pages.{page_id} must be a table")

        required = ("source", "output", "kind", "lifecycle")
        missing = [field for field in required if not isinstance(page.get(field), str) or not page[field]]
        if missing:
            raise SystemExit(f"{manifest_path}: pages.{page_id} is missing {', '.join(missing)}")
        members = page.get("members")
        if not isinstance(members, list) or not members or not all(
            isinstance(member, str) and member for member in members
        ):
            raise SystemExit(f"{manifest_path}: pages.{page_id}.members must be a non-empty string array")

        source_relative = Path(page["source"])
        output_relative = Path(page["output"])
        if source_relative in sources:
            raise SystemExit(f"{manifest_path}: duplicate API source {source_relative}")
        if output_relative in outputs:
            raise SystemExit(f"{manifest_path}: duplicate API output {output_relative}")

        source_path = content_root / "pages" / source_relative
        if not source_path.is_file():
            raise SystemExit(f"{manifest_path}: missing API template {source_path}")

        rendered, path_used = render_template(
            source_path.read_text(encoding="utf-8"),
            strings,
            source_path,
        )
        absent_members = [member for member in members if member not in rendered]
        if absent_members:
            raise SystemExit(
                f"{manifest_path}: pages.{page_id} members absent from rendered page: "
                f"{', '.join(absent_members)}"
            )
        destination = output_locale_root / output_relative
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_text(rendered, encoding="utf-8", newline="\n")
        used.update(path_used)
        sources.add(source_relative)
        outputs.add(output_relative)

    return used, sources


def render_locale(
    locale: Locale,
    locales: dict[str, Locale],
    content_root: Path,
    output_root: Path,
) -> set[str]:
    chain = locale_chain(locale, locales)
    strings = load_strings(chain)
    output_locale_root = output_root / "locales" / locale.code

    if output_locale_root.exists():
        shutil.rmtree(output_locale_root)

    used = set()
    api_used, api_sources = render_api_pages(content_root, output_locale_root, strings)
    used.update(api_used)
    used.update(
        copy_tree(
            content_root / "pages",
            output_locale_root,
            strings,
            excluded=api_sources,
        )
    )
    used.update(copy_tree(content_root / "repo", output_locale_root, strings))

    locale_license = output_locale_root / "LICENSE"
    if locale_license.exists():
        locale_license.unlink()

    for metadata_name in ("locale.toml", "release.toml", "roblox-references.toml"):
        metadata_source = locale.path / metadata_name
        if metadata_source.exists():
            shutil.copy2(metadata_source, output_locale_root / metadata_name)

    unused = set(strings) - used
    if unused:
        print(f"warning: {locale.code} has unused localized string(s): {', '.join(sorted(unused))}", file=sys.stderr)

    return used


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Render Arbor localized content.")
    parser.add_argument("--content-root", default="content")
    parser.add_argument("--output-root", default=".generated/shared/content")
    parser.add_argument("--language", action="append", default=[])
    parser.add_argument("--require-path", action="append", default=[], help="Rendered path, relative to output root, that must exist after rendering.")
    parser.add_argument("--list-languages", action="store_true", help="Print renderable locales in default-first order and exit.")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    content_root = Path(args.content_root)
    output_root = Path(args.output_root)
    locales = {locale.code: locale for locale in discover_locales(content_root / "locales")}
    default_locale = next(locale for locale in locales.values() if locale.default)

    if args.list_languages:
        selected_locales = sorted(locales.values(), key=lambda locale: (locale.code != default_locale.code, locale.code))
        for locale in selected_locales:
            if locale.published:
                print(locale.code)
        return

    selected = args.language or sorted(locales)

    output_root.mkdir(parents=True, exist_ok=True)
    if not args.language:
        shutil.rmtree(output_root / "locales", ignore_errors=True)

    for code in selected:
        if code not in locales:
            raise SystemExit(f"Unknown locale {code!r}")
        render_locale(locales[code], locales, content_root, output_root)

    for required_path in args.require_path:
        path = output_root / required_path
        if not path.exists():
            raise SystemExit(f"Rendered output is missing required path: {path}")

    print(f"Rendered localized content: {output_root}")


if __name__ == "__main__":
    main()
