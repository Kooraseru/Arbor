# Content Layout

Arbor keeps authored English public content under `content/locales/en/`:

- `README.md`
- `CONTRIBUTING.md`
- `LICENSE`

`LICENSE` stays English-only unless a translated legal surface is deliberately
introduced later.

Repository and package rules are not localized public content. They live under
maintainer-facing owner docs in `docs/knowledge/`.

Active localized project-facing files live under `content/locales/`:

```txt
content/
  assets/
  locales/
    <language>/
      README.md
      CONTRIBUTING.md
      wiki/
      examples/
```

English is the default language. Its public source lives under
`content/locales/en/`.

`CHANGELOG.md` is generated package-history output from release notes. It is
emitted into `.generated-preview/` or publication output, not authored under
`content/locales/`.

Language codes use the project country-code style from `.github/wiki-languages.yml`;
for example, `jp` is Japanese.

Outdated or shelved content lives under:

```txt
content/locales/outdated/<language>/
```

These files are rewrite/reference source only. They are not part of the active
wiki build.
