# Tool Capabilities

This document owns Arbor's repo-facing tool handlers.

Tools are selected by capability first, then by concrete implementation.

## Luau CLI Analysis

Need: run Luau analysis from the command line and report diagnostics as
validation evidence.

Arbor uses `luau-lsp analyze` as a CLI analyzer. The analyzer wrappers live
under `tools/luau-lsp/` and load `tools/luau-lsp/analyze-settings.json`,
generated sourcemap data, and Roblox global types before returning CLI output
for the requested source files.

Use when:

- Luau source changes
- sourcemap roots change
- public API or require paths change
- generated facade/type examples change

Repo-owned interface:

- `tools/luau-lsp/analyze.ps1`
- `tools/luau-lsp/analyze.sh`
- `tools/luau-lsp/analyze.fish`
- `tools/luau-lsp/scripts/generate-sourcemap.py`
- `tools/luau-lsp/sourcemap.config.json`
- `tools/luau-lsp/analyze-settings.json`
- `.github/scripts/analyze-luau.ps1`

Evidence:

- settings file used for analysis
- generated `tools/luau-lsp/generated/sourcemap.json`
- analyzed target list
- analyzer pass/fail output
- diagnostics from `luau-lsp analyze`

## Public Wiki Build

Need: build or test localized public documentation.

Use when:

- `content/locales/<language>/wiki/` changes
- `.github/mkdocs.yml` changes
- `.github/wiki-languages.yml` changes
- public content assets move

Repo-owned interface:

- `.github/mkdocs.yml`
- `.github/wiki-languages.yml`
- `.github/scripts/configure-mkdocs-language.py`
- `.github/scripts/test-pages-workflow.sh`
- `.github/disabled-workflows/pages.yml` as disabled reference only

Evidence:

- generated or configured MkDocs output
- pages workflow script output
- broken-link/path failures when present

## Facade Generation

Need: generate or test Arbor facade/type output from source definitions.

Use when:

- `src/arbor@1.1.0/Authoring/` changes
- definition/type-function shape changes
- facade generator scripts change
- source examples depend on generated output

Repo-owned interface:

- `tools/generate-facade.py`
- `tools/test-generate-facade.py`
- `tools/lune/generate-root-facade.luau`

Evidence:

- test output
- generated diff or no-diff confirmation
