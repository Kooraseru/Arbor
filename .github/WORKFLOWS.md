# GitHub Automation

Active GitHub automation is intentionally small.

Branch ownership is defined in
`docs/knowledge/branch-publication-model.md`.

Local publication outputs are staged under `.generated/` and use the same
payload builder as the publish workflow. Source-only authoring surfaces such as
`.generated/`, `.vscode/`, `docs/`, `tools/`, `.gitignore`, `.gitattributes`,
`AGENTS.md`, Python caches, and Rust build output are excluded from generated
pre-release/release shapes.

## Active Validate Workflow

`.github/workflows/validate.yml`

Owns repository validation. Do not add local-only validation scripts or editor
tasks that run checks outside the workflow model. If a check matters, add it as
a validation stage here, then local runs may use the same command.

Stages:

- Tooling Contracts: shell syntax, Python syntax, workflow contracts, and
  facade generation behavior.
- Package Build: generated RBXM package export.
- Documentation Build: localized content rendering, changelog construction,
  MkDocs builds, and Roblox reference validation.
- Luau Analysis: package source analyzer checks through the checked-in analyzer
  wrapper.

## Active Publish Workflow

`.github/workflows/publish.yml`

Publishes exactly one generated branch from current `source`.
It must be dispatched from the `source` branch.

Manual inputs:

- `channel`: `pre-release` or `release`
- `version`: release note version without the leading `v`

Required secrets:

- `RELEASE_TOKEN`: token with permission to replace generated branches and tags.
  Do not use this for the Pages refresh dispatch; the workflow uses
  `GITHUB_TOKEN` with `actions: write` for that explicit `workflow_dispatch`.
  It may be configured as an environment secret on the `release` environment;
  the Publish job declares that environment before reading the secret.
- `RELEASE_SIGNING_KEY`: ASCII-armored private GPG key for the maintainer
  identity that signs generated publication commits and release tags.
- `RELEASE_SIGNING_PASSPHRASE`: optional passphrase for that signing key.

Order:

1. Reject dispatches not started from `source`.
2. Enter the `release` environment and require `RELEASE_TOKEN` and
   `RELEASE_SIGNING_KEY`.
3. Check out `source`.
4. Resolve current source HEAD to a full source commit SHA.
5. Verify that SHA belongs to `origin/source`.
6. Configure Git/GPG signing for the maintainer release identity.
7. Build the generated publication payload with
   `.github/scripts/build-publication-payload.sh`.
8. Write `.github/publication.json` into the generated payload.
9. Replace the selected generated branch with
   `.github/scripts/publish-generated-branch.sh`.
10. Create or update the GitHub Release for `v<version>`.
11. Verify and create or replace the signed annotated `v<version>` tag at the generated
    publication commit.
12. Dispatch the Pages workflow from `source`.

`pre-release` and `release` are never merged into each other.

Publish creates or replaces generated branch refs, git tags, and GitHub Release
records. Existing GitHub Release records for the selected version are edited in
place and their generated asset is uploaded with `--clobber`. Release tags are
created as signed annotated tags by the GitHub Release step after the generated
release asset exists; generated branch replacement does not create tags.
Generated commits and release tags are signed by the configured maintainer
release identity. `pre-release` publishes a GitHub Release labeled
`Pre-release`; `release` publishes a normal latest release.

## Active Pages Workflow

.github/workflows/pages.yml

Pages runs only from the `source` workflow ref. It reads `.github/publication.json`
from `release` and `pre-release`, checks out the recorded source commits, and
builds:

```text
release docs      -> site root
pre-release docs  -> /pre-release/
```

If a generated branch or manifest is missing, Pages falls back to current
`source` for the release docs and skips the pre-release docs.

Pages owns the docs-facing automation around:

- `.github/mkdocs.yml`
- `.github/wiki-languages.yml`
- `content/assets/`
- `content/`
- `release-notes/`

Active order:

1. Check out source-owned tooling.
2. Check out generated publication metadata from `release` and `pre-release`.
3. Collect and validate publication manifests.
4. Check out the source commits recorded by those manifests.
5. Build MkDocs sites from the recorded source revisions.
6. Deploy the generated Pages artifact.

The changelog is constructed Markdown. Generate it from source-owned
`release-notes/` into `.generated/`, Pages build output, or publication output
when release notes change. Generated publication branches expose
`CHANGELOG.md`, not `release-notes/`.
