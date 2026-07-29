#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

try:
    import tomllib
except ModuleNotFoundError:  # pragma: no cover - exercised on Python < 3.11
    tomllib = None


TYPE_LINK_PATTERN = re.compile(
    r'class="[^"]*\barbor-type-link\b[^"]*"[^>]*>(?:<code>|`)?([^<`]+)(?:</code>|`)?</a>'
)

API_TOKEN_PATTERN = re.compile(
    r"`(?:(?:api):)?(?P<target>(?:Class|Datatype|Enum|Luau)\.[^`|]+)(?:\|(?P<label>[^`]+))?`"
)


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

    for line_number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
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
    if tomllib is None:
        return parse_simple_toml(path)
    with path.open("rb") as handle:
        return tomllib.load(handle)


def load_reference_names(path: Path) -> set[str]:
    data = load_toml(path)
    if not isinstance(data, dict):
        raise SystemExit(f"{path} must contain a TOML mapping")

    references = data.get("references")
    if not isinstance(references, dict):
        raise SystemExit(f"{path} must contain a references mapping")

    names = set()

    for name, entry in references.items():
        if not isinstance(name, str) or not name:
            raise SystemExit(f"{path} contains an invalid reference key: {name!r}")

        if not isinstance(entry, dict):
            raise SystemExit(f"{path}: {name} must be a mapping")

        for required in ("kind", "url", "label", "summary"):
            value = entry.get(required)
            if not isinstance(value, str) or not value.strip():
                raise SystemExit(f"{path}: {name} is missing {required}")

        names.add(name)
        names.add(entry["label"])

    return names


def validate_wiki_links(wiki_root: Path, known_names: set[str]) -> None:
    unknown: list[str] = []

    for path in sorted(wiki_root.rglob("*.md")):
        text = path.read_text(encoding="utf-8")

        for match in TYPE_LINK_PATTERN.finditer(text):
            label = match.group(1).strip()

            if label.endswith("?"):
                label = label[:-1]

            if label not in known_names:
                unknown.append(f"{path}: unknown arbor-type-link label {label!r}")

        for match in API_TOKEN_PATTERN.finditer(text):
            label = match.group("label")
            if label and label != "no-link" and label not in known_names:
                unknown.append(f"{path}: unknown API token label {label!r}")

    if unknown:
        raise SystemExit("\n".join(unknown))


def main() -> None:
    parser = argparse.ArgumentParser(description="Validate Arbor Roblox Creator Docs reference metadata.")
    parser.add_argument("--content-root", default="content")
    parser.add_argument("--references", default=None)
    parser.add_argument("--wiki-root", default=None)
    args = parser.parse_args()

    content_root = Path(args.content_root)
    defaults = []
    for locale_path in sorted((content_root / "locales").glob("*/locale.toml")):
        locale = load_toml(locale_path)
        if locale.get("default") is True:
            defaults.append(locale_path.parent.name)
    if len(defaults) != 1:
        raise SystemExit(f"Expected exactly one default locale, found {defaults or 'none'}")

    language = defaults[0]
    references = Path(args.references) if args.references else content_root / "locales" / language / "roblox-references.toml"
    wiki_root = Path(args.wiki_root) if args.wiki_root else Path(".generated/shared/content") / "locales" / language / "wiki"
    known_names = load_reference_names(references)
    validate_wiki_links(wiki_root, known_names)
    print(f"Roblox references OK: {references}")


if __name__ == "__main__":
    main()
