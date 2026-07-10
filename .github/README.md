# GitHub Automation

Arbor workflows are ordered by release responsibility.

## 1. Release

`.github/workflows/release.yml`

Builds the release package, creates or replaces the protected release tag, and
publishes the GitHub Release after validation and manual approval.

Release channels:

- `main` resolves `release-notes/Stable`.
- `canary` resolves `release-notes/Pre-release`.

Order:

1. Resolve the current release note for the branch channel.
2. Validate package shape, examples shape, and changelog construction.
3. Wait for the `release` environment approval.
4. Build `Arbor.rbxm` and release notes from the validated commit.
5. Use `RELEASE_TOKEN` to replace the protected tag at the validated commit.
6. Use `RELEASE_TOKEN` to publish the GitHub Release with `Arbor.rbxm`.
7. Upload the release package artifact for the workflow run.

`RELEASE_TOKEN` is only used after approval.

## 2. Pages

`.github/workflows/pages.yml`

Builds and deploys the public documentation site.

Pages owns the docs-facing automation around:

- `.github/mkdocs.yml`
- `.github/wiki-languages.yml`
- `assets/`
- `content/`
- `release-notes/`
- examples used by the wiki

Order:

1. Validate the checked example fixture shape.
2. Build MkDocs sites for configured branches and languages.
3. Deploy the generated Pages artifact.

`CHANGELOG.md` is constructed during workflows. It is not checked in.
