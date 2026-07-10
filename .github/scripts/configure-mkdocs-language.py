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


def build_alternates(registry: dict, alternate_site_url: str | None) -> list[dict[str, str]]:
    alternates = []
    default_language = registry["default_language"]

    for code, language in registry["languages"].items():
        link = language["site_url"]
        if alternate_site_url:
            if code == default_language:
                link = alternate_site_url
            else:
                link = urljoin(alternate_site_url.rstrip("/") + "/", f"{code}/")

        alternates.append({
            "name": language["name"],
            "link": link,
            "lang": language.get("locale", code),
        })

    return alternates


def configure(
    config: dict,
    registry: dict,
    language_code: str,
    site_url: str | None,
    site_name: str | None,
    alternate_site_url: str | None,
) -> dict:
    languages = registry["languages"]
    if language_code not in languages:
        known = ", ".join(sorted(languages))
        raise SystemExit(f"Unknown wiki language '{language_code}'. Known languages: {known}")

    language = languages[language_code]
    configured = deepcopy(config)

    configured["docs_dir"] = f"../{language['content_dir']}"
    configured["site_url"] = site_url or language["site_url"]
    if site_name:
        configured["site_name"] = site_name

    theme = configured.setdefault("theme", {})
    theme["language"] = language.get("locale", language_code)

    extra = configured.setdefault("extra", {})
    extra["language"] = {
        "code": language_code,
        "name": language["name"],
        "locale": language.get("locale", language_code),
        "default": bool(language.get("default", False)),
        "content_dir": language["content_dir"],
        "examples_dir": language["examples_dir"],
        "root_dir": language["root_dir"],
        "readme": language["readme"],
        "contributing": language["contributing"],
        "domain_aliases": language.get("domain_aliases", []),
    }
    extra["root_policy"] = registry["root_policy"]
    extra["alternate"] = build_alternates(registry, alternate_site_url)

    return configured


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Configure MkDocs for one Arbor wiki language.")
    parser.add_argument("--config", default=".github/mkdocs.yml", help="MkDocs YAML file to rewrite.")
    parser.add_argument("--languages", default=".github/wiki-languages.yml", help="Language registry YAML.")
    parser.add_argument("--language", default=None, help="Language code to configure. Defaults to registry default_language.")
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
    language_code = args.language or registry["default_language"]

    configured = configure(config, registry, language_code, args.site_url, args.site_name, args.alternate_site_url)
    write_yaml(config_path, configured)


if __name__ == "__main__":
    main()
