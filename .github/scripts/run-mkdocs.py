#!/usr/bin/env python3
from __future__ import annotations

import runpy
import sys
from pathlib import Path


def main() -> None:
    github_dir = Path(__file__).resolve().parents[1]
    sys.path.insert(0, str(github_dir))
    sys.argv = ["mkdocs", *sys.argv[1:]]
    runpy.run_module("mkdocs", run_name="__main__")


if __name__ == "__main__":
    main()
