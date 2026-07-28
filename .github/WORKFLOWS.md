# GitHub Automation

Active GitHub automation is intentionally small.

Branch ownership is defined in
`docs/knowledge/branch-publication-model.md`.

Local publication outputs are staged under `.generated/` and use the same
payload builder as the publish workflow. Source-only authoring surfaces such as
`.generated/`, `.vscode/`, `docs/`, `tools/`, `.gitignore`, `.gitattributes`,
`AGENTS.md`, disabled workflow references, Python caches, and Rust build output
are excluded from generated pre-release/release shapes.

## Active Publish Workflow

`.github/workflows/publish.yml`

Publishes exactly one generated branch from a selected source commit.
It must be dispatched from the `source` branch.

Manual inputs:

- `channel`: `pre-release` or `release`
- `version`: publication version without the leading `v`
- `source_ref`: full source commit SHA, or `source` for current source HEAD

Required secret:

- `RELEASE_TOKEN`: token with permission to replace generated branches and tags.
  Use a token that can trigger downstream workflows; do not fall back to the
  default `github.token`, because pushes made by that token do not reliably
  start the Pages refresh workflow.

Order:

1. Reject dispatches not started from `source`.
2. Check out the selected source ref.
3. Resolve it to a full source commit SHA.
4. Verify that SHA belongs to `origin/source`.
5. Build the generated publication payload with
   `.github/scripts/build-publication-payload.sh`.
6. Write `.github/publication.json` into the generated payload.
7. Replace the selected generated branch with
   `.github/scripts/publish-generated-branch.sh`.
8. Tag the generated branch commit as `v<version>`.
9. The generated branch push refreshes Pages through the active Pages workflow.

`pre-release` and `release` are never merged into each other.

Local simulation:

```bash
bash .github/scripts/test-publish-workflow.sh .generated HEAD
```

VS Code task:

```text
Publication: Test Publish Workflow
```

This does not push branches or tags. It proves local payload generation,
publication manifests, generated repo shape, generated branch commits, version
tag creation/replacement, commit provenance, and collected Pages publication
state against a temporary local Git remote.

Legacy workflows were moved out of `.github/workflows/` and into
`.github/disabled-workflows/` so they cannot run while Arbor's publication model
is being redesigned.

Keep the disabled files as reference only. Do not re-enable them until they are
rewritten for the `source`/`pre-release`/`release` model.

## Disabled Release Reference

`.github/disabled-workflows/release.yml`

Builds the release package, creates or replaces the protected release tag, and
publishes the GitHub Release after validation and manual approval.

Current redesign target:

- `source` owns authoring inputs.
- generated publication output may be emitted to `pre-release` or `release`.
- `release-notes/` uses a version-shaped tree for release communication
  inputs.

Order:

1. Resolve the current release note for the branch channel.
2. Validate package shape, examples shape, and changelog construction.
3. Wait for the `release` environment approval.
4. Build `Arbor.rbxm` and release notes from the validated commit.
5. Use `RELEASE_TOKEN` to replace the protected tag at the validated commit.
6. Use `RELEASE_TOKEN` to publish the GitHub Release with `Arbor.rbxm`.
7. Upload the release package artifact for the workflow run.

`RELEASE_TOKEN` is only used after approval.

## Disabled Pages Reference

`.github/disabled-workflows/pages.yml`

Historical reference for the public documentation site.

Active Pages automation lives at:

```text
.github/workflows/pages.yml
```

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
