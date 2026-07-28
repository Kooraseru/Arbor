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

- `content/pages/` changes
- `content/repo/` changes
- `content/locales/<language>/` changes
- `.github/mkdocs.yml` changes
- `.github/wiki-languages.yml` changes
- public content assets move

Repo-owned interface:

- `.github/workflows/publish.yml`
- `.github/workflows/pages.yml`
- `.github/scripts/render-localized-content.py`
- `content/api/reference.toml`
- `.github/scripts/build-publication-payload.sh`
- `.github/scripts/publish-generated-branch.sh`
- `.github/scripts/collect-publication-manifests.py`
- `.github/scripts/validate-roblox-references.py`
- `.github/scripts/validate-python-scripts.py`
- `.github/scripts/validate-workflow-contracts.py`
- `.github/mkdocs_extensions/api_links.py`
- `.github/scripts/test-publish-workflow.sh`
- `.github/mkdocs.yml`
- `.github/wiki-languages.yml`
- `.github/scripts/configure-mkdocs-language.py`
- `.github/scripts/test-pages-workflow.sh`
- VS Code task: `Publication: Test Pages Workflow`
- VS Code task: `Publication: Test Publish Workflow`
- `.vscode/tasks.json`
- `.github/disabled-workflows/pages.yml` as disabled reference only

Evidence:

- generated or configured MkDocs output
- pages workflow script output
- publication metadata under `.github/publication.json`
- collected publication metadata under
  `.generated/shared/content/generated/publications.json`
- local publish simulation output
- temporary local Git remote branch/tag creation and replacement verification
- workflow contract validation output
- Python syntax validation output without bytecode caches
- broken-link/path failures when present
- local Pages artifact under `.generated/shared/pages`
- local pre-release Pages artifact under `.generated/shared/pages/pre-release`
- staged wiki source under `.generated/shared/content`
- Roblox Creator Docs reference metadata validation output
- publication branch payloads under `.generated/repos/pre-release` and
  `.generated/repos/release`

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
