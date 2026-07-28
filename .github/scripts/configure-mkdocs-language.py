#!/usr/bin/env python3
from __future__ import annotations

import argparse
from copy import deepcopy
from pathlib import Path
from urllib.parse import urljoin

import yaml


def load_yaml(path: Path) -> dict:
    with path.open("r", encoding="utf-8") as handle:
        return yaml.safe_load(handle)


def write_yaml(path: Path, data: dict) -> None:
    with path.open("w", encoding="utf-8") as handle:
        yaml.safe_dump(data, handle, sort_keys=False, allow_unicode=True)


def load_locale(content_root: Path, language_code: str) -> dict:
    path = content_root / "locales" / language_code / "locale.toml"

    if not path.exists():
        raise SystemExit(f"Unknown wiki language '{language_code}': missing {path}")

    data: dict[str, object] = {}

    for line_number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
        stripped = line.strip()

        if not stripped or stripped.startswith("#"):
            continue

        key, separator, value = stripped.partition("=")
        if not separator:
            raise SystemExit(f"{path}:{line_number}: expected key = value")

        key = key.strip()
        value = value.strip()

        if value in ("true", "false"):
            data[key] = value == "true"
        elif value.startswith('"') and value.endswith('"'):
            data[key] = value[1:-1]
        elif value.startswith("'") and value.endswith("'"):
            data[key] = value[1:-1]
        elif value.startswith("[") and value.endswith("]"):
            inner = value[1:-1].strip()
            data[key] = [] if not inner else [
                item.strip()[1:-1]
                for item in inner.split(",")
                if item.strip().startswith('"') and item.strip().endswith('"')
            ]
        else:
            raise SystemExit(f"{path}:{line_number}: expected quoted string, boolean, or string array")

    return data


def discover_default_language(content_root: Path) -> str:
    defaults = []

    for locale_path in sorted((content_root / "locales").glob("*/locale.toml")):
        language = load_locale(content_root, locale_path.parent.name)
        if language.get("default") is True:
            defaults.append(locale_path.parent.name)

    if len(defaults) != 1:
        raise SystemExit(f"Expected exactly one default locale, found {defaults or 'none'}")

    return defaults[0]


def discover_alternates(content_root: Path, default_language: str, alternate_site_url: str | None) -> list[dict[str, str]]:
    alternates = []

    for locale_path in sorted((content_root / "locales").glob("*/locale.toml")):
        code = locale_path.parent.name
        wiki_root = locale_path.parent / "wiki"

        if not wiki_root.exists():
            continue

        language = load_locale(content_root, code)
        link = f"https://kooraseru.github.io/Arbor/{'' if code == default_language else code + '/'}"
        if alternate_site_url:
            if code == default_language:
                link = alternate_site_url
            else:
                link = urljoin(alternate_site_url.rstrip("/") + "/", f"{code}/")

        alternates.append({
            "name": language.get("native_name", language.get("name", code)),
            "link": link,
            "lang": language.get("locale", code),
        })

    return alternates


def configure(
    config: dict,
    registry: dict,
    language_code: str,
    content_root: Path,
    site_url: str | None,
    site_name: str | None,
    alternate_site_url: str | None,
) -> dict:
    default_language = discover_default_language(content_root)
    language = load_locale(content_root, language_code)
    content_dir = f"{content_root.as_posix()}/locales/{language_code}/wiki"
    configured = deepcopy(config)

    configured["docs_dir"] = f"../{content_dir}"
    configured["site_url"] = site_url or f"https://kooraseru.github.io/Arbor/{'' if language_code == default_language else language_code + '/'}"
    if site_name:
        configured["site_name"] = site_name

    theme = configured.setdefault("theme", {})
    theme["language"] = language.get("locale", language_code)

    extra = configured.setdefault("extra", {})
    extra_language = {
        "code": language_code,
        "name": language["name"],
        "locale": language.get("locale", language_code),
        "default": language_code == default_language,
        "content_dir": content_dir,
        "root_dir": "." if language_code == default_language else language_code,
        "readme": f"{content_root.as_posix()}/locales/{language_code}/README.md",
        "contributing": f"{content_root.as_posix()}/locales/{language_code}/CONTRIBUTING.md",
        "domain_aliases": [],
    }

    extra["language"] = extra_language
    extra["alternate"] = discover_alternates(content_root, default_language, alternate_site_url)

    return configured


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Configure MkDocs for one Arbor wiki language.")
    parser.add_argument("--config", default=".github/mkdocs.yml", help="MkDocs YAML file to rewrite.")
    parser.add_argument("--languages", default=".github/wiki-languages.yml", help="Language registry YAML.")
    parser.add_argument("--language", default=None, help="Language code to configure. Defaults to the locale marked default = true.")
    parser.add_argument("--content-root", default="content", help="Rendered content root containing locales/.")
    parser.add_argument("--site-url", default=None, help="Override site_url for previews or custom domains.")
    parser.add_argument("--site-name", default=None, help="Override site_name for previews.")
    parser.add_argument("--alternate-site-url", default=None, help="Base URL used for language switcher links.")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    config_path = Path(args.config)
    registry_path = Path(args.languages)

    config = load_yaml(config_path)
    registry = load_yaml(registry_path)
    content_root = Path(args.content_root)
    language_code = args.language or discover_default_language(content_root)

    configured = configure(config, registry, language_code, content_root, args.site_url, args.site_name, args.alternate_site_url)
    write_yaml(config_path, configured)


if __name__ == "__main__":
    main()
