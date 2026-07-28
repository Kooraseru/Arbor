#!/usr/bin/env python3
from __future__ import annotations

import argparse
import os
import re
from dataclasses import dataclass
from pathlib import Path

try:
    import tomllib
except ModuleNotFoundError:  # pragma: no cover - exercised on Python < 3.11
    tomllib = None


LANGUAGE_TABLE_RE = re.compile(
    r"(?P<indent>[ \t]*)<!-- LANGUAGES -->\n(?P<table>[ \t]*<table>\n.*?[ \t]*</table>)",
    re.DOTALL,
)
LANGUAGE_TOKEN_RE = re.compile(r"\{\{\s*arbor:language\s+(?P<code>[A-Za-z0-9_-]+)\s*\}\}")


@dataclass(frozen=True)
class Language:
    code: str
    name: str
    native_name: str
    readme: Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Update or render localized README language tables.")
    parser.add_argument("--source-root", default=".", help="Repository/source root.")
    parser.add_argument("--publication-root", default=None, help="Generated publication root.")
    parser.add_argument("--mode", choices=["source", "publication"], default="source")
    return parser.parse_args()


def load_locale(path: Path) -> dict[str, object]:
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
        return value[1:-1]
    if value.startswith("'") and value.endswith("'"):
        return value[1:-1]
    if value.startswith("[") and value.endswith("]"):
        inner = value[1:-1].strip()
        if not inner:
            return []
        return [parse_simple_value(part.strip()) for part in inner.split(",")]
    raise SystemExit(f"Unsupported TOML value: {value}")


def parse_simple_toml(path: Path) -> dict[str, object]:
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


def discover_default_language(locales_root: Path) -> str:
    defaults = []

    for locale_file in sorted(locales_root.glob("*/locale.toml")):
        data = load_locale(locale_file)
        if data.get("default") is True:
            defaults.append(locale_file.parent.name)

    if len(defaults) != 1:
        raise SystemExit(f"Expected exactly one default locale, found {defaults or 'none'}")

    return defaults[0]


def discover_languages(content_root: Path, base_root: Path, default_language: str) -> list[Language]:
    locales_root = content_root / "locales"
    languages: list[Language] = []

    for locale_path in sorted(locales_root.glob("*/locale.toml")):
        code = locale_path.parent.name
        readme = locale_path.parent / "README.md"

        if not readme.exists():
            continue

        data = load_locale(locale_path)
        name = data.get("name")
        native_name = data.get("native_name", name)

        for field, value in {"name": name, "native_name": native_name}.items():
            if not isinstance(value, str) or not value.strip():
                raise SystemExit(f"{locale_path} is missing {field}")

        languages.append(Language(code=code, name=name, native_name=native_name, readme=readme.relative_to(base_root)))

    if default_language not in {language.code for language in languages}:
        raise SystemExit(f"Default language {default_language!r} does not have a locale README")

    return sorted(languages, key=lambda language: (language.code != default_language, language.code))


def render_source_table(languages: list[Language], indent: str) -> str:
    rows = [
        f'{indent}    <td align="center">{{{{ arbor:language {language.code} }}}}</td>'
        for language in languages
    ]

    return "\n".join([
        f"{indent}<!-- LANGUAGES -->",
        f"{indent}<table>",
        f"{indent}  <tr>",
        *rows,
        f"{indent}  </tr>",
        f"{indent}</table>",
    ])


def replace_language_table(path: Path, languages: list[Language]) -> bool:
    text = path.read_text(encoding="utf-8")
    match = LANGUAGE_TABLE_RE.search(text)

    if not match:
        raise SystemExit(f"{path} is missing a <!-- LANGUAGES --> table")

    replacement = render_source_table(languages, match.group("indent"))
    updated = f"{text[:match.start()]}{replacement}{text[match.end():]}"

    if updated == text:
        return False

    path.write_text(updated, encoding="utf-8", newline="\n")
    return True


def update_source(languages: list[Language]) -> None:
    for language in languages:
        changed = replace_language_table(language.readme, languages)
        action = "Updated" if changed else "Already current"
        print(f"{action}: {language.readme.as_posix()}")


def publication_readme_path(publication_root: Path, language: Language, default_language: str) -> Path:
    if language.code == default_language:
        return publication_root / "README.md"

    return publication_root / language.readme


def relative_href(source: Path, destination: Path) -> str:
    return os.path.relpath(destination, source.parent).replace(os.sep, "/")


def render_tokens(text: str, current: Language, languages: dict[str, Language], publication_root: Path, default_language: str, output_path: Path) -> str:
    def replace(match: re.Match[str]) -> str:
        code = match.group("code")
        language = languages.get(code)

        if language is None:
            raise SystemExit(f"{output_path} references unknown language token: {code}")

        if code == current.code:
            return language.native_name

        href = relative_href(output_path, publication_readme_path(publication_root, language, default_language))
        return f'<a href="{href}">{language.native_name}</a>'

    return LANGUAGE_TOKEN_RE.sub(replace, text)


def render_publication(source_root: Path, publication_root: Path, languages: list[Language], default_language: str) -> None:
    by_code = {language.code: language for language in languages}

    for language in languages:
        output_path = publication_readme_path(publication_root, language, default_language)
        input_path = publication_root / language.readme

        if not input_path.exists():
            raise SystemExit(f"Missing README input for {language.code}: {input_path}")

        text = input_path.read_text(encoding="utf-8")
        rendered = render_tokens(text, language, by_code, publication_root, default_language, output_path)

        if language.code == default_language:
            rendered = rendered.replace("../../assets/", "content/assets/")

        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(rendered, encoding="utf-8", newline="\n")
        print(f"Rendered: {output_path.as_posix()}")


def main() -> None:
    args = parse_args()
    source_root = Path(args.source_root)
    base_root = Path(args.publication_root) if args.mode == "publication" and args.publication_root else source_root
    content_root = base_root / "content"
    locale_root = content_root / "locales"
    default_language = discover_default_language(locale_root)
    languages = discover_languages(content_root, base_root, default_language)

    if args.mode == "source":
        update_source(languages)
        return

    if not args.publication_root:
        raise SystemExit("--publication-root is required in publication mode")

    render_publication(source_root, Path(args.publication_root), languages, default_language)


if __name__ == "__main__":
    main()
