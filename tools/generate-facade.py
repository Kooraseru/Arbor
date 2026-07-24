#!/usr/bin/env python3
"""Regenerate an Arbor package root facade from Definitions/TypeFunctions.

This is the local CLI mirror of Authoring/FacadeGenerator.luau. It is part of
the package authoring surface for people working on Arbor outside Studio.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import argparse
import re
import shutil
import sys

sys.dont_write_bytecode = True


REQUIRE_START = "-- <arbor-facade-requires>"
REQUIRE_END = "-- </arbor-facade-requires>"
PUBLIC_START = "-- <arbor-facade-public>"
PUBLIC_END = "-- </arbor-facade-public>"
TYPE_START = "-- <arbor-facade-types>"
TYPE_END = "-- </arbor-facade-types>"

FUNCTION_PARAMETERS = re.compile(r"function\s*<([^>]+)>\s*\(")
PUBLIC_EXPORT = re.compile(r"^\s*--\s*arbor-facade-export\s+([A-Za-z_][A-Za-z0-9_.]*)\s*$")
PUBLIC_ALIAS = re.compile(
    r"^\s*--\s*arbor-facade-alias\s+([A-Za-z_][A-Za-z0-9_]*)\s*=\s*([A-Za-z_][A-Za-z0-9_.]*)\s*$"
)
SUPPORT_REQUIRE = re.compile(
    r'^\s*--\s*arbor-facade-require\s+([A-Za-z_][A-Za-z0-9_]*)\s+"([^"]+)"\s*$'
)
LUAU_KEYWORDS = {
    "and",
    "break",
    "do",
    "else",
    "elseif",
    "end",
    "export",
    "false",
    "for",
    "function",
    "if",
    "in",
    "local",
    "nil",
    "not",
    "or",
    "repeat",
    "return",
    "then",
    "true",
    "type",
    "until",
    "while",
}


@dataclass(frozen=True)
class Facade:
    category: str
    name: str
    require_path: str
    parameters: list[str]


@dataclass(frozen=True)
class PublicExport:
    path: tuple[str, ...]
    name: str
    require_path: str


@dataclass(frozen=True)
class PublicAlias:
    name: str
    source: tuple[str, ...]


@dataclass(frozen=True)
class SupportRequire:
    name: str
    require_path: str


def split_parameters(parameters: str) -> list[str]:
    return [parameter.strip() for parameter in parameters.split(",") if parameter.strip()]


def is_valid_identifier(value: str) -> bool:
    return re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", value) is not None and value not in LUAU_KEYWORDS


def collect_facades(src_root: Path) -> list[Facade]:
    type_functions_root = src_root / "Definitions" / "TypeFunctions"

    if not type_functions_root.exists():
        return []

    facades: list[Facade] = []
    seen_names: set[str] = set()

    for path in sorted(type_functions_root.rglob("*.luau")):
        relative = path.relative_to(src_root)
        parts = relative.parts

        if len(parts) < 4:
            continue

        category = parts[2]
        source = path.read_text(encoding="utf-8")
        match = FUNCTION_PARAMETERS.search(source)

        if not match:
            continue

        if not is_valid_identifier(path.stem):
            raise ValueError(f'Cannot generate Arbor facade "{path}": "{path.stem}" is not a valid Luau identifier')

        if path.stem in seen_names:
            raise ValueError(f'Cannot generate Arbor facade "{path.stem}": duplicate exported type name')

        seen_names.add(path.stem)

        facades.append(
            Facade(
                category=category,
                name=path.stem,
                require_path="@self/" + "/".join(part.removesuffix(".luau") for part in parts),
                parameters=split_parameters(match.group(1)),
            )
        )

    return sorted(facades, key=lambda facade: (facade.category, facade.name))


def collect_public_surface(src_root: Path) -> tuple[list[PublicExport], list[PublicAlias], list[SupportRequire]]:
    exports: list[PublicExport] = []
    aliases: list[PublicAlias] = []
    support_requires: list[SupportRequire] = []
    seen_exports: set[tuple[str, ...]] = set()
    seen_aliases: set[str] = set()
    seen_support_requires: set[str] = set()

    for path in sorted(src_root.rglob("*.luau")):
        if path.name == "init.luau":
            continue

        relative = path.relative_to(src_root)
        parts = tuple(part.removesuffix(".luau") for part in relative.parts)
        source = path.read_text(encoding="utf-8")

        for line in source.splitlines():
            export_match = PUBLIC_EXPORT.match(line)

            if export_match:
                export_path = tuple(export_match.group(1).split("."))

                if export_path in seen_exports:
                    raise ValueError(f'Cannot generate Arbor public facade "{path}": duplicate export {".".join(export_path)}')

                seen_exports.add(export_path)
                exports.append(
                    PublicExport(
                        path=export_path,
                        name=export_path[-1],
                        require_path="@self/" + "/".join(parts),
                    )
                )
                continue

            alias_match = PUBLIC_ALIAS.match(line)

            if alias_match:
                alias_name = alias_match.group(1)

                if alias_name in seen_aliases:
                    raise ValueError(f'Cannot generate Arbor public facade "{path}": duplicate alias {alias_name}')

                seen_aliases.add(alias_name)
                aliases.append(PublicAlias(name=alias_name, source=tuple(alias_match.group(2).split("."))))
                continue

            support_match = SUPPORT_REQUIRE.match(line)

            if support_match:
                support_name = support_match.group(1)

                if support_name in seen_support_requires:
                    raise ValueError(f'Cannot generate Arbor public facade "{path}": duplicate support require {support_name}')

                seen_support_requires.add(support_name)
                support_requires.append(SupportRequire(name=support_name, require_path=support_match.group(2)))

    exports.sort(key=lambda export: export.path)
    aliases.sort(key=lambda alias: alias.name)
    support_requires.sort(key=lambda support_require: support_require.name)
    return exports, aliases, support_requires


def build_type_line(facade: Facade) -> str:
    mold_arguments = list(facade.parameters)

    if len(mold_arguments) == 1:
        mold_arguments.append("never")
    elif len(mold_arguments) != 2:
        raise ValueError(
            f"FacadeGenerator currently supports one or two type parameters: {facade.name}"
        )

    parameters = ", ".join(facade.parameters)
    arguments = ", ".join(mold_arguments)

    return (
        f"export type {facade.name}<{parameters}> = "
        f"Run.Resolve<Mold.Resolve<typeof({facade.name}), {arguments}>>"
    )


def append_category(lines: list[str], current: str | None, category: str) -> str:
    if current != category:
        if lines:
            lines.append("")

        lines.append(f"--# {category}")

    return category


def build_require_lines(facades: list[Facade]) -> list[str]:
    lines: list[str] = []
    current_category: str | None = None

    for facade in facades:
        current_category = append_category(lines, current_category, facade.category)
        lines.append(f'local {facade.name} = require("{facade.require_path}")')

    return lines


def append_public_requires(lines: list[str], exports: list[PublicExport], support_requires: list[SupportRequire]) -> None:
    public_requires = [
        *(f'local {support_require.name} = require("{support_require.require_path}")' for support_require in support_requires),
        *(f'local {export.name} = require("{export.require_path}")' for export in exports),
    ]

    if public_requires and lines:
        lines.append("")

    lines.extend(public_requires)


def build_public_lines(exports: list[PublicExport], aliases: list[PublicAlias]) -> list[str]:
    lines: list[str] = []
    initialized: set[tuple[str, ...]] = set()

    for export in exports:
        for depth in range(1, len(export.path)):
            prefix = export.path[:depth]

            if prefix in initialized:
                continue

            lines.append(f'Arbor.{".".join(prefix)} = {{}}')
            initialized.add(prefix)

        lines.append(f'Arbor.{".".join(export.path)} = {export.name}')

    if aliases and lines:
        lines.append("")

    for alias in aliases:
        lines.append(f'Arbor.{alias.name} = Arbor.{".".join(alias.source)}')

    return lines


def build_type_lines(facades: list[Facade]) -> list[str]:
    lines: list[str] = []
    current_category: str | None = None

    for facade in facades:
        current_category = append_category(lines, current_category, facade.category)
        lines.append(build_type_line(facade))

        if facade.name == "Child":
            lines.append(
                'export type RequiredChild<Parent, Name> = Child<{ Parent: Parent, Name: Name, Mode: "required" }>'
            )

    if lines:
        lines.append("")

    lines.append("export type Mold<Schema, First, Second> = Mold.Resolve<Schema, First, Second>")
    lines.append("export type Run<Molded> = Run.Resolve<Molded>")
    lines.append(
        "export type Resolve1<Definition, First> = Run.Resolve<Mold.Resolve<Definition, First, never>>"
    )
    lines.append(
        "export type Resolve2<Definition, First, Second> = Run.Resolve<Mold.Resolve<Definition, First, Second>>"
    )

    return lines


def replace_block(source: str, start: str, end: str, lines: list[str]) -> str:
    start_index = source.find(start)
    end_index = source.find(end)

    if start_index == -1 or end_index == -1 or end_index < start_index:
        raise ValueError(f"Missing generated block markers: {start} / {end}")

    end_index += len(end)
    block = "\n".join([start, *lines, end])

    return source[:start_index] + block + source[end_index:]


def generate(src_root: Path, check: bool) -> int:
    init_path = src_root / "init.luau"
    source = init_path.read_text(encoding="utf-8")
    facades = collect_facades(src_root)
    public_exports, public_aliases, support_requires = collect_public_surface(src_root)
    require_lines = build_require_lines(facades)
    append_public_requires(require_lines, public_exports, support_requires)

    generated = replace_block(source, REQUIRE_START, REQUIRE_END, require_lines)
    generated = replace_block(generated, PUBLIC_START, PUBLIC_END, build_public_lines(public_exports, public_aliases))
    generated = replace_block(generated, TYPE_START, TYPE_END, build_type_lines(facades))

    if check:
        if generated != source:
            print(f"{init_path} is stale. Run generate-facade.py.", file=sys.stderr)
            return 1

        return 0

    init_path.write_text(generated, encoding="utf-8", newline="\n")
    print(f"Updated {init_path} with {len(facades)} facade type function(s).")
    return 0


def remove_python_caches(*roots: Path) -> None:
    seen: set[Path] = set()

    for root in roots:
        if not root.exists():
            continue

        for cache in root.rglob("__pycache__"):
            if cache in seen:
                continue

            seen.add(cache)
            shutil.rmtree(cache, ignore_errors=True)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--src",
        type=Path,
        default=Path(__file__).resolve().parents[1] / "src" / "arbor@1.1.0",
        help="Path to the Arbor ModuleScript root.",
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="Do not write files; fail if init.luau is stale.",
    )
    args = parser.parse_args()

    src_root = args.src.resolve()

    try:
        return generate(src_root, args.check)
    finally:
        remove_python_caches(src_root, Path(__file__).resolve().parent)


if __name__ == "__main__":
    raise SystemExit(main())
