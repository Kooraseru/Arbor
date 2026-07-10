# Content Layout

Arbor keeps English project root files at the repository root:

- `README.md`
- `CONTRIBUTING.md`
- `RULES.md`
- `LICENSE`

`LICENSE` and `RULES.md` stay English-only. They are the legal and project-rule
sources of truth, so translated copies should not be created.

Localized project-facing files live at the top of each language folder:

```txt
content/<language>/
  README.md
  CONTRIBUTING.md
  wiki/
  examples/
```

English is the default language. Its wiki source lives under `content/en/wiki/`,
while the canonical English `README.md` and `CONTRIBUTING.md` remain at the
repository root.

Language codes use the project country-code style from `.github/wiki-languages.yml`;
for example, `jp` is Japanese.
