# Contributing

Arbor is intentionally small. Changes should preserve the split between compile-time type knowledge and runtime behavior.

> [!IMPORTANT]
> Runtime discovery and compile-time typing are separate concerns. Do not add runtime behavior here just because it helps a local package load modules.

## Local Expectations

- Read `RULES.md` before editing package source.
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
wsl fish ../../../.luau-lsp/analyze.fish src/Shared/Packages/Arbor/src/init.luau src/Shared/Packages/Arbor/content/en/examples/direct-children/init.luau src/Shared/Packages/Arbor/content/en/examples/class-filtered-children/init.luau src/Shared/Packages/Arbor/content/en/examples/runtime-loader/init.luau
bash .github/scripts/export-rbxm.sh
python -m mkdocs build --config-file .github\mkdocs.yml --site-dir ..\.tmp\results\docs\mkdocs-site
bash .github/scripts/test-pages-workflow.sh .tmp/results/pages/pages-workflow-test canary
git diff --check
```

The checked-in analyzer wrapper validates Arbor through the Packages workspace
`.luau-lsp` sourcemap and global types. Do not add a second global types file or
exported-package analyzer mirror inside Arbor.

For repository CI, mirror these checks with paths relative to the package root.

## Branches

Arbor uses three long-lived branches:

```txt
main    public stable package line
canary  early features before they are promoted
ci      testing/CI branch, not public-use docs or releases
```

CI runs on all three branches. GitHub Pages runs from `main`. Package releases
are created from version tags.

If Pages deployment is rejected by environment protection, update the `github-pages` environment in repository settings so `main` is allowed to deploy.

## Releases

Stable package release notes live under `release-notes/Stable`.

Pre-release notes live under `release-notes/Pre-release`. The `canary` branch and
`-canary.N` tag suffix are implementation mechanics; public release-note
language should say `Pre-release`.

`CHANGELOG.md` is constructed Markdown for package-history summaries. Update
release notes when package history changes; do not hand-edit constructed
changelog output as the source of truth.

Arbor follows a continuous `v1` package line:

```txt
v1.<release>.<patch>
```

Pre-release tags append the canary suffix:

```txt
v1.<release>.<patch>-canary.N
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
