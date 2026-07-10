#!/usr/bin/env python3
from __future__ import annotations

import argparse
import re
from dataclasses import dataclass
from pathlib import Path


FRONT_MATTER_BOUNDARY = "---"
DATE_RE = re.compile(r"^Date:\s*(.+)$", re.MULTILINE)
HEADING_RE = re.compile(r"^#\s+(.+)$", re.MULTILINE)
VERSION_RE = re.compile(r"v\d+(?:\.\d+)*(?:-[A-Za-z0-9.-]+)?")
OMITTED_CHANGELOG_SECTIONS = {"assets"}
OMITTED_CHANGELOG_METADATA = {"channel", "date", "package", "status"}


@dataclass(frozen=True)
class ReleaseNote:
    version: str
    base_version: str
    channel: str
    date: str | None
    path: Path
    body: str


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Construct Arbor CHANGELOG.md from release notes.")
    parser.add_argument("--stable-dir", default="release-notes/Stable", help="Stable release notes directory.")
    parser.add_argument("--pre-release-dir", default="release-notes/Pre-release", help="Pre-release notes directory.")
    parser.add_argument("--output", default="CHANGELOG.md", help="Constructed Markdown output.")
    return parser.parse_args()


def strip_front_matter(text: str) -> str:
    if not text.startswith(FRONT_MATTER_BOUNDARY):
        return text

    parts = text.split(FRONT_MATTER_BOUNDARY, 2)
    if len(parts) != 3:
        return text

    return parts[2].lstrip()


def version_sort_key(version: str) -> tuple[int, ...]:
    version_text = version.removeprefix("v")
    stable_text = version_text.split("-", 1)[0]
    parts = []

    for part in stable_text.split("."):
        try:
            parts.append(int(part))
        except ValueError:
            parts.append(0)

    return tuple(parts)


def base_version(version: str) -> str:
    return version.split("-", 1)[0]


def version_segment(version: str) -> str:
    parts = version.split("-", 1)
    if len(parts) == 1:
        return version

    return parts[1]


def release_version(path: Path, text: str) -> str:
    match = VERSION_RE.search(path.stem)
    if match:
        return match.group(0)

    heading = HEADING_RE.search(text)
    if heading:
        match = VERSION_RE.search(heading.group(1))
        if match:
            return match.group(0)

    raise ValueError(f"Could not determine release version for {path}")


def release_date(text: str) -> str | None:
    match = DATE_RE.search(text)
    if match:
        return match.group(1).strip()

    return None


def release_body(text: str) -> str:
    body = strip_front_matter(text).strip()
    return re.sub(r"^#{1,6}\s+.+\n+", "", body, count=1).strip()


def remove_omitted_metadata(markdown: str) -> str:
    lines = markdown.splitlines()

    while lines:
        line = lines[0]
        if not line.strip():
            lines.pop(0)
            continue

        key, separator, _value = line.partition(":")
        if separator and key.strip().casefold() in OMITTED_CHANGELOG_METADATA:
            lines.pop(0)
            continue

        break

    return "\n".join(lines).strip()


def remove_omitted_sections(markdown: str) -> str:
    lines = markdown.splitlines()
    kept_lines = []
    skipping = False
    skipped_level = 0

    for line in lines:
        if line.startswith("#"):
            marker, _, title = line.partition(" ")
            if marker and all(character == "#" for character in marker):
                level = len(marker)
                section_name = title.strip().casefold()

                if skipping and level <= skipped_level:
                    skipping = False

                if section_name in OMITTED_CHANGELOG_SECTIONS:
                    skipping = True
                    skipped_level = level
                    continue

        if not skipping:
            kept_lines.append(line)

    return "\n".join(kept_lines).strip()


def demote_headings(markdown: str, levels: int) -> str:
    lines = []

    for line in markdown.splitlines():
        if line.startswith("#"):
            marker, _, title = line.partition(" ")
            if marker and all(character == "#" for character in marker):
                line = f"{'#' * (len(marker) + levels)} {title}"

        lines.append(line)

    return "\n".join(lines).strip()


def changelog_body(note: ReleaseNote) -> str:
    body = remove_omitted_metadata(note.body)
    body = remove_omitted_sections(body)
    return demote_headings(body, 1)


def load_release_notes(directory: Path, channel: str) -> list[ReleaseNote]:
    notes = []

    if not directory.exists():
        return notes

    for path in directory.glob("*.md"):
        if path.name.casefold() == "readme.md":
            continue

        text = path.read_text(encoding="utf-8")
        version = release_version(path, text)
        notes.append(ReleaseNote(
            version=version,
            base_version=base_version(version),
            channel=channel,
            date=release_date(text),
            path=path,
            body=release_body(text),
        ))

    return sorted(notes, key=lambda note: version_sort_key(note.version), reverse=True)


def group_release_notes(notes: list[ReleaseNote]) -> dict[str, list[ReleaseNote]]:
    grouped: dict[str, list[ReleaseNote]] = {}

    for note in notes:
        grouped.setdefault(note.base_version, []).append(note)

    return grouped


def version_date(notes: list[ReleaseNote]) -> str | None:
    stable_dates = [note.date for note in notes if note.channel == "Stable" and note.date]
    if stable_dates:
        return stable_dates[0]

    dates = [note.date for note in notes if note.date]
    if dates:
        return dates[0]

    return None


def append_channel(lines: list[str], heading: str, notes: list[ReleaseNote], include_note_version: bool) -> None:
    if not notes:
        return

    lines.extend([f"### {heading}", ""])

    for note in notes:
        if include_note_version:
            note_heading = f"#### {version_segment(note.version)}"
            if note.date:
                note_heading = f"{note_heading} - {note.date}"
            lines.extend([note_heading, ""])

        lines.extend([changelog_body(note), ""])


def main() -> None:
    args = parse_args()
    stable_dir = Path(args.stable_dir)
    pre_release_dir = Path(args.pre_release_dir)
    output_path = Path(args.output)
    notes = [
        *load_release_notes(stable_dir, "Stable"),
        *load_release_notes(pre_release_dir, "Pre-release"),
    ]
    grouped_notes = group_release_notes(notes)

    lines = [
        "# Changelog",
        "",
        "All notable Arbor package changes are constructed from release notes.",
        "",
        "<!-- This file is constructed from release-notes/Stable/*.md and release-notes/Pre-release/*.md. Do not edit it by hand. -->",
        "",
    ]

    if not notes:
        lines.extend(["No release notes have been published yet.", ""])

    for version in sorted(grouped_notes, key=version_sort_key, reverse=True):
        version_notes = grouped_notes[version]
        heading = f"## {version}"
        date = version_date(version_notes)
        if date:
            heading = f"{heading} - {date}"

        lines.extend([heading, ""])

        stable_notes = [note for note in version_notes if note.channel == "Stable"]
        pre_release_notes = [note for note in version_notes if note.channel == "Pre-release"]

        append_channel(lines, "Stable", stable_notes, include_note_version=False)
        append_channel(lines, "Pre-release", pre_release_notes, include_note_version=True)

    output_path.write_text("\n".join(lines).rstrip() + "\n", encoding="utf-8")
    print(f"Constructed changelog: {output_path}")


if __name__ == "__main__":
    main()
