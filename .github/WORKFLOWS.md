# GitHub Automation

Active GitHub automation is intentionally small.

Branch ownership is defined in
`docs/knowledge/branch-publication-model.md`.

Local publication outputs are staged under `.generated/` and use the same
payload builder as the publish workflow. Source-only authoring surfaces such as
`.generated/`, `.vscode/`, `docs/`, `tools/`, `.gitignore`, `.gitattributes`,
`AGENTS.md`, Python caches, and Rust build output are excluded from generated
pre-release/release shapes.

## Active Publish Workflow

`.github/workflows/publish.yml`

Publishes exactly one generated branch from current `source`.
It must be dispatched from the `source` branch.

Manual inputs:

- `channel`: `pre-release` or `release`
- `version`: release note version without the leading `v`

Required secret:

- `RELEASE_TOKEN`: token with permission to replace generated branches and tags.
  Use a token that can trigger downstream workflows; do not fall back to the
  default `github.token`, because pushes made by that token do not reliably
  start the Pages refresh workflow. It may be configured as an environment
  secret on the `release` environment; the Publish job declares that environment
  before reading the secret.

Order:

1. Reject dispatches not started from `source`.
2. Enter the `release` environment and require `RELEASE_TOKEN`.
3. Check out `source`.
4. Resolve current source HEAD to a full source commit SHA.
5. Verify that SHA belongs to `origin/source`.
6. Build the generated publication payload with
   `.github/scripts/build-publication-payload.sh`.
7. Write `.github/publication.json` into the generated payload.
8. Replace the selected generated branch with
   `.github/scripts/publish-generated-branch.sh`.
9. Tag the generated branch commit as `v<version>`.
10. Create or update the GitHub Release for `v<version>`.
11. The generated branch push refreshes Pages through the active Pages workflow.

`pre-release` and `release` are never merged into each other.

Local simulation:

```bash
bash .github/scripts/test-publish-workflow.sh .generated
```

VS Code task:

```text
Publication: Test Publish Workflow
```

This does not push branches or tags. It proves local payload generation,
publication manifests, generated repo shape, generated branch commits, version
tag creation/replacement, commit provenance, and collected Pages publication
state against a temporary local Git remote.

Publish creates or replaces generated branch refs, git tags, and GitHub Release
records. Existing GitHub Release records for the selected version are edited in
place and their generated asset is uploaded with `--clobber`. `pre-release`
publishes a GitHub Release labeled `Pre-release`; `release` publishes a normal
latest release.

## Active Pages Workflow

.github/workflows/pages.yml

It reads `.github/publication.json` from `release` and `pre-release`, checks out
the recorded source commits, and builds:

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
