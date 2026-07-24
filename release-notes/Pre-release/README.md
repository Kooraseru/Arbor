# Pre-release Notes

Pre-release notes are the public source for preview GitHub releases and the
constructed changelog.

Use one Markdown file per pre-release tag:

```txt
release-notes/Pre-release/v1.1.0-canary.1.md
```

Pre-release notes are grouped under their base version in the constructed
changelog. For example, `v1.1.0-canary.1.md` appears under `v1.1.0` as a
pre-release segment named `canary.1`.

Use `##` for the release heading so the note can be embedded cleanly.

## Format

```md
## v1.1.0-canary.1

Channel: Pre-release
Date: YYYY-MM-DD

### Summary

Short preview summary. Say what is available to try.

### Changes

- Preview change.
- Preview change.

### Notes

- Pre-release behavior may change before stable.
```
