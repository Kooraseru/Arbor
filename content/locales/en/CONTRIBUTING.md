# Contributing

Arbor is intentionally small. Changes should preserve the split between compile-time type knowledge and runtime behavior.

> [!IMPORTANT]
> Runtime discovery and compile-time typing are separate concerns. Do not add runtime behavior here just because it helps a local package load modules.

## Local Expectations

- Read `docs/knowledge/package-system.md` before editing package source.
- Keep type functions focused on analyzer-visible facts.
- Do not add runtime registry, boot, serialization, dispatch, or descriptor behavior here.
- Prefer root exported type aliases for package-facing type surfaces.
- Keep focused modules available when a direct analyzer path is clearer.

## Validation

Run focused validation before proposing a change:

```powershell
bash -n .github/scripts/write-release-notes.sh
bash -n .github/scripts/export-rbxm.sh
bash -n .github/scripts/test-pages-workflow.sh
python .github/scripts/construct-changelog.py
python .github/scripts/resolve-release-note.py --channel Stable
powershell -ExecutionPolicy Bypass -File .github/scripts/analyze-luau.ps1
bash .github/scripts/export-rbxm.sh
python -m mkdocs build --config-file .github\mkdocs.yml --site-dir ..\.generated-preview\results\docs\mkdocs-site
bash .github/scripts/test-pages-workflow.sh .generated-preview/pages/pages-workflow-test source
git diff --check
```

The checked-in analyzer wrapper runs `luau-lsp analyze` as a CLI check using
`tools/luau-lsp/analyze-settings.json`, the generated sourcemap, and Roblox
global types.

For repository CI, mirror these checks with paths relative to the package root.

## Branches

Arbor is moving to an authoring/publication branch model:

```txt
source   canonical authoring branch
preview  generated preview publication branch
release  generated stable publication branch
```

Human-authored pull requests target `source`.

`preview` and `release` are automation-owned generated outputs. Do not open
human-authored pull requests against them.

The full branch ownership model lives in
`docs/knowledge/branch-publication-model.md`.

## Releases

Stable package release notes live under `release-notes/Stable`.

Pre-release notes live under `release-notes/Pre-release`. Public release-note
language should say `Pre-release`.

`CHANGELOG.md` is constructed Markdown for package-history summaries and belongs
in generated publication output. Update release notes when package history
changes; do not hand-edit constructed changelog output as the source of truth.

Arbor follows a continuous `v1` package line:

```txt
v1.<release>.<patch>
```

Pre-release tags append a prerelease suffix:

```txt
v1.<release>.<patch>-preview.N
```

Only package changes create package versions. Documentation, workflow, examples,
media, and repository maintenance may be mentioned in release notes when they
ship alongside a release, but they do not create package versions by themselves.

Stable releases should attach:

```txt
Arbor.rbxm
```

Examples remain repository-only and are not included in exported package assets.

## Design Notes

Runtime discovery does not create static public API by itself. If a caller needs compile-time key checks, use analyzer-visible child-name discovery, generated surfaces, or another explicit typed surface.

> [!CAUTION]
> Do not use `any` or casts to force dynamic loaders through the analyzer. Use `unknown` at the dynamic boundary and validate.
