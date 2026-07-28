# Contributing

Arbor is intentionally small. Changes should preserve the split between compile-time type knowledge and runtime behavior.

> [!IMPORTANT]
> Runtime discovery and compile-time typing are separate concerns. Do not add runtime behavior here just because it helps a local package load modules.

## Branches

All human development happens on `source`.

Open issues, proposals, fixes, documentation changes, package source changes,
release-note changes, workflow changes, and pull requests against `source`.

Do not author changes on `pre-release` or `release`.

Those branches are generated publication outputs built from `source`:

```txt
source       canonical authoring branch
pre-release generated pre-release publication branch
release      generated stable publication branch
```

If something is wrong on `pre-release` or `release`, fix the source-owned input
on `source`, then rebuild or republish the generated branch. Direct edits to
generated publication branches are invalid and may be overwritten.

The full branch ownership model lives in
`docs/knowledge/branch-publication-model.md`.

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
bash -n .github/scripts/test-publish-workflow.sh
python .github/scripts/construct-changelog.py
python .github/scripts/resolve-release-note.py --channel Stable
python .github/scripts/validate-python-scripts.py
python .github/scripts/validate-workflow-contracts.py
powershell -ExecutionPolicy Bypass -File .github/scripts/analyze-luau.ps1
bash .github/scripts/export-rbxm.sh
bash .github/scripts/test-publish-workflow.sh .generated HEAD
python .github/scripts/run-mkdocs.py build --config-file .github/mkdocs.yml --site-dir .generated/shared/pages
bash .github/scripts/test-pages-workflow.sh .generated source pre-release release
git diff --check
```

The checked-in analyzer wrapper runs `luau-lsp analyze` as a CLI check using
`tools/luau-lsp/analyze-settings.json`, the generated sourcemap, and Roblox
global types.

For repository CI, mirror these checks with paths relative to the package root.

## Releases

Stable package release metadata lives in TOML files such as
`release-notes/v1.0.1.toml`. A version with multiple channels may use
`release-notes/v1.1.0/stable.toml` and
`release-notes/v1.1.0/beta.1.toml`.

Keep version, channel, date, and asset metadata in those files. Put
human-readable release sections in each locale's `release.toml`. Public
release-note language should say `Pre-release`.

`CHANGELOG.md` is constructed Markdown for package-history summaries and belongs
in generated publication output. Update release notes when package history
changes; do not hand-edit constructed changelog output as the source of truth.

Arbor follows a continuous `v1` package line:

```txt
v1.<release>.<patch>
```

Pre-release tags append a prerelease suffix:

```txt
v1.<release>.<patch>-beta.N
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
