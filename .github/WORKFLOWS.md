# GitHub Automation

Active GitHub automation is currently disconnected.

Branch ownership is defined in
`docs/knowledge/branch-publication-model.md`.

Local publication previews are staged under `.generated-preview/` and use Git
archive/export rules. Source-only authoring surfaces such as `docs/`, `tools/`,
and `AGENTS.md` are excluded from generated preview/release shapes.

Legacy workflows were moved out of `.github/workflows/` and into
`.github/disabled-workflows/` so they cannot run while Arbor's publication model
is being redesigned.

Keep the disabled files as reference only. Do not re-enable them until they are
rewritten for the `source`/`preview`/`release` model.

## Disabled Release Reference

`.github/disabled-workflows/release.yml`

Builds the release package, creates or replaces the protected release tag, and
publishes the GitHub Release after validation and manual approval.

Current redesign target:

- `source` owns authoring inputs.
- generated publication output may be emitted to `preview`, `release`, or both.
- `release-notes/Stable` and `release-notes/Pre-release` remain release
  communication inputs.

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

Builds and deploys the public documentation site.

Pages owns the docs-facing automation around:

- `.github/mkdocs.yml`
- `.github/wiki-languages.yml`
- `content/assets/`
- `content/`
- `release-notes/`
- examples used by the wiki

Order:

1. Validate the checked example fixture shape.
2. Build MkDocs sites for configured branches and languages.
3. Deploy the generated Pages artifact.

The changelog is constructed Markdown. Generate it from `release-notes/` into
`.generated-preview/`, other build output, or publication output when release
notes change.
