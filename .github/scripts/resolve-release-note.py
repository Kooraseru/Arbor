#!/usr/bin/env python3
from __future__ import annotations

import argparse
from dataclasses import dataclass
from pathlib import Path

try:
    import tomllib
except ModuleNotFoundError:  # pragma: no cover - exercised on Python <3.11
    tomllib = None


@dataclass(frozen=True)
class ReleaseCandidate:
    tag: str
    channel: str
    metadata_source: Path
    version_parts: tuple[int, ...]
    suffix: str
    prerelease: bool


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Resolve the latest Arbor release metadata.")
    parser.add_argument("--channel", choices=["Stable", "Pre-release"], required=True)
    parser.add_argument("--release-notes-dir", default="release-notes")
    parser.add_argument("--github-output", default=None)
    return parser.parse_args()


def load_metadata(path: Path) -> dict[str, object]:
    if tomllib is not None:
        with path.open("rb") as handle:
            return tomllib.load(handle)

    data: dict[str, object] = {}
    for line_number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        key, separator, raw = stripped.partition("=")
        if not separator:
            raise SystemExit(f"{path}:{line_number}: expected key = value")
        raw = raw.strip()
        if raw.startswith('"') and raw.endswith('"'):
            data[key.strip()] = raw[1:-1]
        elif raw.startswith("[") and raw.endswith("]"):
            data[key.strip()] = [
                item.strip().strip('"')
                for item in raw[1:-1].split(",")
                if item.strip()
            ]
        else:
            raise SystemExit(f"{path}:{line_number}: unsupported TOML value")
    return data


def candidate(path: Path) -> ReleaseCandidate:
    data = load_metadata(path)
    version = data.get("version")
    channel = data.get("channel")
    if not isinstance(version, str) or not version.startswith("v"):
        raise SystemExit(f"{path}: version must start with v")
    if channel not in {"stable", "pre-release"}:
        raise SystemExit(f"{path}: invalid channel {channel!r}")

    stable, separator, suffix = version.removeprefix("v").partition("-")
    if (channel == "pre-release") != bool(separator):
        raise SystemExit(f"{path}: channel {channel!r} does not match version {version!r}")
    try:
        parts = tuple(int(part) for part in stable.split("."))
    except ValueError as error:
        raise SystemExit(f"{path}: invalid version {version!r}") from error

    return ReleaseCandidate(
        tag=version,
        channel=channel,
        metadata_source=path,
        version_parts=parts,
        suffix=suffix,
        prerelease=bool(separator),
    )


def main() -> None:
    args = parse_args()
    expected_channel = "stable" if args.channel == "Stable" else "pre-release"
    candidates = [
        item
        for item in (
            candidate(path)
            for path in sorted(Path(args.release_notes_dir).rglob("*.toml"))
        )
        if item.channel == expected_channel
    ]
    if not candidates:
        raise SystemExit(f"No {args.channel} release metadata found")

    selected = max(candidates, key=lambda item: (item.version_parts, item.suffix))
    lines = [
        f"tag={selected.tag}",
        f"channel={args.channel}",
        f"notes_source={selected.metadata_source.as_posix()}",
        f"prerelease={'true' if selected.prerelease else 'false'}",
    ]
    for line in lines:
        print(line)
    if args.github_output:
        with Path(args.github_output).open("a", encoding="utf-8") as handle:
            for line in lines:
                handle.write(f"{line}\n")


if __name__ == "__main__":
    main()
