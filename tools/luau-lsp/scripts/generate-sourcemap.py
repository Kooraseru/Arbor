#!/usr/bin/env python3
"""Generate a Luau LSP sourcemap from the repository filesystem."""

from __future__ import annotations

import json
import argparse
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
DEFAULT_CONFIG_PATH = "tools/luau-lsp/sourcemap.config.json"


def resolve_repo_path(path: str) -> Path:
    candidate = Path(path)
    if candidate.is_absolute():
        return candidate

    return ROOT / candidate


def load_config(path: str) -> tuple[dict[str, str], set[str]]:
    config_path = resolve_repo_path(path)
    if not config_path.exists():
        raise FileNotFoundError(f"Missing sourcemap config at {config_path}")

    config = json.loads(config_path.read_text(encoding="utf-8"))
    source_roots = config.get("sourceRoots")
    ignored_directory_names = config.get("ignoredDirectoryNames")

    if not isinstance(source_roots, dict) or not source_roots:
        raise ValueError("sourcemap config must define a non-empty sourceRoots object")

    if not isinstance(ignored_directory_names, list):
        raise ValueError("sourcemap config must define ignoredDirectoryNames as an array")

    normalized_source_roots = {}
    for source_name, service_path in source_roots.items():
        if not isinstance(source_name, str) or not source_name:
            raise ValueError("sourceRoots keys must be non-empty strings")

        if not isinstance(service_path, str) or not service_path:
            raise ValueError(f"sourceRoots['{source_name}'] must be a non-empty string")

        normalized_source_roots[source_name.strip("/")] = service_path.strip("/")

    normalized_ignored_names = set()
    for name in ignored_directory_names:
        if not isinstance(name, str) or not name:
            raise ValueError("ignoredDirectoryNames entries must be non-empty strings")

        normalized_ignored_names.add(name)

    return normalized_source_roots, normalized_ignored_names


def posix_relative(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def script_class_name(path: Path) -> str:
    name = path.name.lower()

    if name.endswith(".server.luau") or name.endswith(".server.lua") or name.endswith(".plugin.luau") or name.endswith(".plugin.lua"):
        return "Script"

    if name.endswith(".client.luau") or name.endswith(".client.lua") or name.endswith(".local.luau"):
        return "LocalScript"

    return "ModuleScript"


def script_instance_name(path: Path) -> str:
    name = path.name

    for suffix in (
        ".server.luau",
        ".server.lua",
        ".client.luau",
        ".client.lua",
        ".local.luau",
        ".local.lua",
        ".plugin.luau",
        ".plugin.lua",
    ):
        if name.endswith(suffix):
            return name[: -len(suffix)]

    return path.stem


def find_init_file(path: Path) -> Path | None:
    return next((
        candidate
        for candidate in (
            path / "init.luau",
            path / "init.lua",
            path / "init.plugin.luau",
            path / "init.plugin.lua",
        )
        if candidate.exists()
    ), None)


def build_directory(path: Path, ignored_directory_names: set[str]) -> dict[str, object] | None:
    init_file = find_init_file(path)
    children = []

    for child in sorted(path.iterdir(), key=lambda item: (not item.is_dir(), item.name.lower())):
        if child.is_dir():
            if child.name in ignored_directory_names:
                continue

            child_node = build_directory(child, ignored_directory_names)
            if child_node is not None:
                children.append(child_node)
            continue

        if child == init_file or child.suffix not in {".luau", ".lua"}:
            continue

        children.append({
            "name": script_instance_name(child),
            "className": script_class_name(child),
            "filePaths": [posix_relative(child)],
        })

    if init_file is not None:
        node = {
            "name": path.name,
            "className": script_class_name(init_file),
            "filePaths": [posix_relative(init_file)],
        }
        if children:
            node["children"] = children
        return node

    if children:
        return {
            "name": path.name,
            "className": "Folder",
            "children": children,
        }

    return None


def build_service(
    service_name: str,
    source_name: str,
    ignored_directory_names: set[str],
) -> dict[str, object]:
    source_path = ROOT / source_name
    source_node = build_directory(source_path, ignored_directory_names)
    children = []
    if source_node is not None:
        if source_node.get("name") == service_name and source_node.get("className") == "Folder":
            children = list(source_node.get("children", []))
        else:
            children = [source_node]

    return {
        "name": service_name,
        "className": service_name,
        "children": children,
    }


def merge_node(target: dict[str, object], source: dict[str, object]) -> None:
    target_children = target.setdefault("children", [])
    source_children = source.get("children", [])

    if not isinstance(target_children, list) or not isinstance(source_children, list):
        return

    for source_child in source_children:
        if not isinstance(source_child, dict):
            continue

        source_name = source_child.get("name")
        source_class = source_child.get("className")
        existing = next((
            child
            for child in target_children
            if isinstance(child, dict)
            and child.get("name") == source_name
            and child.get("className") == source_class
        ), None)

        if existing is not None:
            merge_node(existing, source_child)
        else:
            target_children.append(source_child)


def insert_path(
    root: dict[str, object],
    service_path: str,
    source_name: str,
    ignored_directory_names: set[str],
) -> None:
    parts = service_path.split("/")
    current = root

    for index, part in enumerate(parts):
        children = current.setdefault("children", [])
        if not isinstance(children, list):
            return

        class_name = part if index == 0 else "Folder"
        next_node = next((
            child
            for child in children
            if isinstance(child, dict)
            and child.get("name") == part
        ), None)

        if next_node is None:
            next_node = {
                "name": part,
                "className": class_name,
                "children": [],
            }
            children.append(next_node)

        current = next_node

    merge_node(current, build_service(parts[-1], source_name, ignored_directory_names))


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate a Luau LSP sourcemap from the repository filesystem.")
    parser.add_argument(
        "--output",
        default="tools/luau-lsp/generated/sourcemap.json",
        help="Output sourcemap path, relative to the repository root unless absolute.",
    )
    parser.add_argument(
        "--config",
        default=DEFAULT_CONFIG_PATH,
        help="Sourcemap config path, relative to the repository root unless absolute.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    source_roots, ignored_directory_names = load_config(args.config)
    output = Path(args.output)
    if not output.is_absolute():
        output = ROOT / output

    output.parent.mkdir(parents=True, exist_ok=True)

    tree = {
        "name": "game",
        "className": "DataModel",
        "children": [],
    }

    for source_name, service_name in source_roots.items():
        if (ROOT / source_name).exists():
            insert_path(tree, service_name, source_name, ignored_directory_names)

    output.write_text(json.dumps(tree, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {output.relative_to(ROOT).as_posix()}")


if __name__ == "__main__":
    main()
