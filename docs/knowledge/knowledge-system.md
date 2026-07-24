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

`content/` is localized public product content:

- public wiki pages
- localized README and contributing surfaces
- examples that teach users
- shared public assets under `content/assets/`

Localized content lives under `content/locales/<language>/`. Shelved rewrite
material lives under `content/locales/outdated/`.

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
