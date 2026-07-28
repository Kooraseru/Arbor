from __future__ import annotations

import os
import json
import re
from pathlib import Path
from xml.etree import ElementTree

from markdown.extensions import Extension
from markdown.inlinepatterns import InlineProcessor

try:
    import tomllib
except ModuleNotFoundError:  # pragma: no cover - exercised on Python < 3.11
    tomllib = None


API_TOKEN_PATTERN = re.compile(
    r"`(?:(api):)?(?P<target>(?:Class|Datatype|Enum|Luau)\.[^`|]+)(?:\|(?P<label>[^`]+))?`"
)


def parse_simple_value(value: str) -> object:
    if value == "true":
        return True
    if value == "false":
        return False
    if value.startswith('"') and value.endswith('"'):
        return json.loads(value)
    if value.startswith("[") and value.endswith("]"):
        inner = value[1:-1].strip()
        if not inner:
            return []
        return [parse_simple_value(part.strip()) for part in inner.split(",")]
    raise ValueError(f"Unsupported TOML value: {value}")


def parse_simple_toml(path: Path) -> dict:
    root: dict[str, object] = {}
    current = root

    for line in path.read_text(encoding="utf-8").splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        if stripped.startswith("[") and stripped.endswith("]"):
            current = root
            for part in stripped[1:-1].split("."):
                current = current.setdefault(part, {})  # type: ignore[assignment]
            continue
        key, separator, value = stripped.partition("=")
        if separator:
            current[key.strip()] = parse_simple_value(value.strip())

    return root


def load_toml(path: Path) -> dict:
    if tomllib is None:
        return parse_simple_toml(path)
    with path.open("rb") as handle:
        return tomllib.load(handle)


def load_reference_tooltips(language: str | None = None) -> dict[str, str]:
    tooltips: dict[str, str] = {}
    content_root = Path(os.environ.get("ARBOR_CONTENT_ROOT", "content"))
    locales_root = content_root / "locales"
    language = language or os.environ.get("ARBOR_WIKI_LANGUAGE")

    if language is None:
        defaults = []
        for locale_path in sorted(locales_root.glob("*/locale.toml")):
            locale_data = load_toml(locale_path)
            if locale_data.get("default") is True:
                defaults.append(locale_path.parent.name)
        if len(defaults) != 1:
            return tooltips
        language = defaults[0]

    locale_path = locales_root / language / "locale.toml"
    locale_data = load_toml(locale_path)
    candidates = [language, *locale_data.get("fallback", [])]
    path = next(
        (
            locales_root / code / "roblox-references.toml"
            for code in candidates
            if (locales_root / code / "roblox-references.toml").exists()
        ),
        None,
    )
    if path is None:
        return tooltips

    data = load_toml(path)
    references = data.get("references", {}) if isinstance(data, dict) else {}
    if not isinstance(references, dict):
        return tooltips

    for name, entry in references.items():
        if not isinstance(name, str) or not isinstance(entry, dict):
            continue

        label = entry.get("label", name)
        summary = entry.get("summary")

        if isinstance(label, str) and isinstance(summary, str):
            tooltip = f"{label} - {summary}"
            tooltips[label] = tooltip
            tooltips[name] = tooltip

    return tooltips


def roblox_url(target: str) -> str | None:
    if target.startswith("Class."):
        rest = target[len("Class.") :]
        class_name, _, member = rest.partition(".")
        method_class, method_sep, method = rest.partition(":")

        if method_sep:
            method_name = method.split("(", 1)[0]
            return f"https://create.roblox.com/docs/reference/engine/classes/{method_class}#{method_name}"

        if member:
            return f"https://create.roblox.com/docs/reference/engine/classes/{class_name}#{member}"

        return f"https://create.roblox.com/docs/reference/engine/classes/{class_name}"

    if target.startswith("Datatype."):
        name = target[len("Datatype.") :].split(".", 1)[0]
        return f"https://create.roblox.com/docs/reference/engine/datatypes/{name}"

    if target.startswith("Enum."):
        name = target[len("Enum.") :].split(".", 1)[0]
        return f"https://create.roblox.com/docs/reference/engine/enums/{name}"

    if target.startswith("Luau."):
        name = target[len("Luau.") :]

        if name == "types":
            return "https://luau.org/types-library/"

        if name == "extern":
            return "https://luau.org/types-library/#extern-type-instance"

    return None


def display_label(target: str, explicit_label: str | None) -> str:
    if explicit_label:
        return explicit_label

    for prefix in ("Class.", "Datatype.", "Enum.", "Luau."):
        if target.startswith(prefix):
            target = target[len(prefix) :]
            break

    return target


class ApiLinkInlineProcessor(InlineProcessor):
    def __init__(self, md) -> None:
        super().__init__(API_TOKEN_PATTERN.pattern, md)
        self.tooltips = load_reference_tooltips()

    def handleMatch(self, match, data):
        target = match.group("target")
        label = match.group("label")

        if label == "no-link":
            code = ElementTree.Element("code")
            code.text = target
            return code, match.start(0), match.end(0)

        url = roblox_url(target)

        if not url:
            code = ElementTree.Element("code")
            code.text = match.group(0).strip("`")
            return code, match.start(0), match.end(0)

        visible_label = display_label(target, label)
        link = ElementTree.Element("a")
        link.set("href", url)
        link.set("class", "arbor-type-link")
        link.set("data-tooltip", self.tooltips.get(visible_label, visible_label))

        code = ElementTree.SubElement(link, "code")
        code.text = visible_label

        return link, match.start(0), match.end(0)


class ApiLinksExtension(Extension):
    def extendMarkdown(self, md) -> None:
        md.inlinePatterns.register(ApiLinkInlineProcessor(md), "arbor_api_links", 200)


def makeExtension(**kwargs):
    return ApiLinksExtension(**kwargs)
