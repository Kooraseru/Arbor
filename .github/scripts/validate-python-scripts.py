#!/usr/bin/env python3
from __future__ import annotations

import argparse
from pathlib import Path


DEFAULT_PATHS = [
    ".github/scripts/collect-publication-manifests.py",
    ".github/scripts/configure-mkdocs-language.py",
    ".github/scripts/construct-changelog.py",
    ".github/scripts/resolve-release-note.py",
    ".github/scripts/run-mkdocs.py",
    ".github/scripts/update-readme-language-links.py",
    ".github/scripts/validate-roblox-references.py",
    ".github/scripts/validate-python-scripts.py",
    ".github/scripts/validate-workflow-contracts.py",
    ".github/mkdocs_extensions/api_links.py",
]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Validate Python script syntax without writing bytecode.")
    parser.add_argument("paths", nargs="*", default=DEFAULT_PATHS)
    return parser.parse_args()


def main() -> None:
    args = parse_args()

    for raw_path in args.paths:
        path = Path(raw_path)
        source = path.read_text(encoding="utf-8")
        compile(source, path.as_posix(), "exec")
        print(f"Python syntax OK: {path.as_posix()}")


if __name__ == "__main__":
    main()
