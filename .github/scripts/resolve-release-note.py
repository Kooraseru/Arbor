#!/usr/bin/env python3
from __future__ import annotations

import argparse
import re
from dataclasses import dataclass
from pathlib import Path


STABLE_RE = re.compile(r"^v(?P<version>\d+(?:\.\d+)*)\.md$")
PRE_RELEASE_RE = re.compile(r"^v(?P<version>\d+(?:\.\d+)*)-(?P<label>[A-Za-z]+)\.(?P<number>\d+)\.md$")


@dataclass(frozen=True)
class ReleaseCandidate:
    tag: str
    notes_source: Path
    version_parts: tuple[int, ...]
    pre_release_number: int
    prerelease: bool


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Resolve the latest Arbor release note for a channel.")
    parser.add_argument("--channel", choices=["Stable", "Pre-release"], required=True)
    parser.add_argument("--stable-dir", default="release-notes/Stable")
    parser.add_argument("--pre-release-dir", default="release-notes/Pre-release")
    parser.add_argument("--github-output", default=None, help="Optional GITHUB_OUTPUT file to append values to.")
    return parser.parse_args()


def version_parts(version: str) -> tuple[int, ...]:
    return tuple(int(part) for part in version.split("."))


def stable_candidates(directory: Path) -> list[ReleaseCandidate]:
    candidates = []

    for path in directory.glob("*.md"):
        if path.name.casefold() == "readme.md":
            continue

        match = STABLE_RE.match(path.name)
        if not match:
            continue

        version = match.group("version")
        candidates.append(ReleaseCandidate(
            tag=f"v{version}",
            notes_source=path,
            version_parts=version_parts(version),
            pre_release_number=-1,
            prerelease=False,
        ))

    return candidates


def pre_release_candidates(directory: Path) -> list[ReleaseCandidate]:
    candidates = []

    for path in directory.glob("*.md"):
        if path.name.casefold() == "readme.md":
            continue

        match = PRE_RELEASE_RE.match(path.name)
        if not match:
            continue

        version = match.group("version")
        label = match.group("label")
        number = int(match.group("number"))
        candidates.append(ReleaseCandidate(
            tag=f"v{version}-{label}.{number}",
            notes_source=path,
            version_parts=version_parts(version),
            pre_release_number=number,
            prerelease=True,
        ))

    return candidates


def latest_candidate(candidates: list[ReleaseCandidate], channel: str) -> ReleaseCandidate:
    if not candidates:
        raise SystemExit(f"No {channel} release notes found")

    return max(candidates, key=lambda candidate: (candidate.version_parts, candidate.pre_release_number))


def output_lines(candidate: ReleaseCandidate, channel: str) -> list[str]:
    prerelease_value = "true" if candidate.prerelease else "false"

    return [
        f"tag={candidate.tag}",
        f"channel={channel}",
        f"notes_source={candidate.notes_source.as_posix()}",
        f"prerelease={prerelease_value}",
    ]


def main() -> None:
    args = parse_args()

    if args.channel == "Stable":
        candidate = latest_candidate(stable_candidates(Path(args.stable_dir)), args.channel)
    else:
        candidate = latest_candidate(pre_release_candidates(Path(args.pre_release_dir)), args.channel)

    lines = output_lines(candidate, args.channel)

    for line in lines:
        print(line)

    if args.github_output:
        with Path(args.github_output).open("a", encoding="utf-8") as handle:
            for line in lines:
                handle.write(f"{line}\n")


if __name__ == "__main__":
    main()
