#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any


SHA_RE = re.compile(r"^[0-9a-f]{40}$")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Collect generated branch publication manifests.")
    parser.add_argument("--release-manifest", default=None)
    parser.add_argument("--pre-release-manifest", default=None)
    parser.add_argument("--output", required=True)
    parser.add_argument("--github-output", default=None)
    return parser.parse_args()


def read_manifest(path: str | None, expected_channel: str) -> dict[str, str] | None:
    if not path:
        return None

    manifest_path = Path(path)
    if not manifest_path.is_file():
        return None

    data: Any = json.loads(manifest_path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise SystemExit(f"Publication manifest must be an object: {manifest_path}")

    expected_keys = {"channel", "version", "sourceCommit", "generatedAt"}
    if set(data) != expected_keys:
        raise SystemExit(f"Publication manifest has unexpected keys: {manifest_path}")

    for key in expected_keys:
        if not isinstance(data[key], str) or not data[key]:
            raise SystemExit(f"Publication manifest key must be a non-empty string: {manifest_path} {key}")

    if data["channel"] != expected_channel:
        raise SystemExit(f"Publication manifest channel mismatch: {manifest_path}")

    if not SHA_RE.match(data["sourceCommit"]):
        raise SystemExit(f"Publication manifest sourceCommit must be a full SHA: {manifest_path}")

    return {
        "channel": data["channel"],
        "version": data["version"],
        "sourceCommit": data["sourceCommit"],
        "generatedAt": data["generatedAt"],
    }


def write_github_outputs(path: str | None, release: dict[str, str] | None, pre_release: dict[str, str] | None) -> None:
    if not path:
        return

    lines = [
        f"release_source_commit={(release or {}).get('sourceCommit', '')}",
        f"release_version={(release or {}).get('version', '')}",
        f"pre_release_source_commit={(pre_release or {}).get('sourceCommit', '')}",
        f"pre_release_version={(pre_release or {}).get('version', '')}",
    ]

    with Path(path).open("a", encoding="utf-8", newline="\n") as output_file:
        for line in lines:
            output_file.write(f"{line}\n")


def main() -> None:
    args = parse_args()

    release = read_manifest(args.release_manifest, "release")
    pre_release = read_manifest(args.pre_release_manifest, "pre-release")

    output = {
        "release": release,
        "preRelease": pre_release,
    }

    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(output, indent=2) + "\n", encoding="utf-8", newline="\n")

    write_github_outputs(args.github_output, release, pre_release)
    print(f"Publication manifests written: {output_path}")


if __name__ == "__main__":
    main()

