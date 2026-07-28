# Configuration Conventions

This document records Arbor-specific application of the global configuration
rules.

Universal TOML/YAML/JSON behavior is owned by:

```text
/mnt/c/Users/Kooraseru/docs/knowledge/configuration-conventions.md
```

Arbor follows that global owner: use TOML for Arbor-owned metadata, use YAML
only for external interfaces such as GitHub Actions and MkDocs, and keep
workflow business logic in locally runnable scripts.

## Documentation Metadata

Keep API metadata separate from localized text.

Canonical API metadata should live in TOML when introduced:

- member ID
- kind
- version or lifecycle state
- signatures
- parameters
- return types
- behavior flags needed by generators

Localized strings should live with locale data under
`content/locales/<language>/`.

## Localization Data

Avoid maintaining duplicated documentation trees when practical.

Use this split:

- canonical structure under `content/pages/` and `content/repo/`
- canonical API metadata in TOML
- localized strings under `content/locales/<language>/`
- generated localized documentation during the build

Do not add authored locale wiki overlays. The renderer accepts canonical page
templates, canonical API/release metadata, and locale-owned TOML resources.

Fallback between locales is locale metadata, not tool policy. A generator must
not assume the default locale is a valid fallback unless the locale declares it.

Documentation structure should remain identical across locales. Only
human-readable strings should change.

Never translate:

- API names
- type names
- module names
- identifiers
- code
- commands
- file paths
- URLs

Only translate user-facing prose.
