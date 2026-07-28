# Knowledge System

Arbor uses a small owner-doc model.

Every durable repository fact should have one owner. Supporting files may link,
explain, validate, or project that fact, but should not redefine it.

## Surfaces

`docs/` is maintainer-facing knowledge:

- repository rules
- architecture and source ownership
- workflow
- validation
- script and tool behavior
- planning conventions

`content/` is public product content source:

- canonical wiki page structure under `content/pages/`
- canonical repository-facing page structure under `content/repo/`
- localized strings and metadata under `content/locales/<language>/`
- examples that teach users
- shared public assets under `content/assets/`

Authored page structure should not be duplicated per language. Keep the
structural source once, then merge it with locale-owned strings and metadata
when generating publication output.

Use this source shape:

```text
content/
  assets/
  pages/
    wiki/
  repo/
    README.md
    CONTRIBUTING.md
    LICENSE
  locales/
    en/
      locale.toml
      strings.toml
      roblox-references.toml
    ja/
      locale.toml
      strings.toml
      roblox-references.toml
```

`content/pages/` owns reusable public wiki structure. `content/repo/` owns
reusable repository-facing structure such as `README.md`, `CONTRIBUTING.md`,
and `LICENSE`. `content/locales/<language>/` owns language-specific strings,
display metadata, and localized Roblox/Luau reference labels.

Locale fallback must be explicit in `locale.toml`. Do not silently fall back to
the default locale from renderer or publication code.

Do not add authored `content/locales/<language>/wiki/` trees. Wiki Markdown is
generated from canonical page templates and locale TOML resources.

Use `docs/knowledge/configuration-conventions.md` for TOML/YAML/JSON rules,
workflow script boundaries, and the metadata/localized-string split.

Shelved rewrite material lives under `content/locales/outdated/`.

`docs/local/` is local/private knowledge:

- roadmap
- active/backlog/done state
- maintained handoffs and leftover notes
- machine-local setup notes

Planning lives under `docs/local/planning/` because it contains messy decision
history and future intent that should help local agents resume work without
becoming public or maintainer-facing repository documentation.

Generated outputs should say where they came from and should not become
canonical owners.

## Metadata Restraint

Do not require a manifest, registry entry, map entry, and projection priority
entry for every new owner.

Use this preferred shape:

```text
named owner document
  -> optional lightweight metadata only when tools consume it
  -> generated indexes or adapters
```

Avoid metadata fan-out where adding one concept requires touching several
hand-maintained registries.

## Docs And Wiki Boundary

The wiki is not a projection of all repository docs.

Shared technical facts still need one canonical contract, but user education can
have wiki-native owners. If a fact matters to both repository maintainers and
public users, name the owner and have the other surface reference or project it.

## Wiki Style And API Reference Format

Public wiki prose style is owned by
`docs/knowledge/documentation-style.md`.

Public API reference layout is owned by
`docs/knowledge/api-reference-format.md`.

Do not treat Roblox Creator Docs `STYLE.md` as Arbor's API reference layout
specification. Use it for prose conventions, terminology, Roblox API links,
callout tone, and inline formatting.
