# Stable Release Notes

Stable release notes are the public source for stable GitHub releases and the
constructed changelog.

Use one Markdown file per stable tag:

```txt
release-notes/Stable/v1.0.0.md
```

Use `##` for the release heading so the note can be embedded under the
constructed changelog version heading.

## Format

```md
## v1.0.0

Channel: Stable
Date: YYYY-MM-DD

### Summary

Short public summary. Keep it practical and user-facing.

### Changes

- Practical change.
- Practical change.

### Assets

- `Arbor.rbxm`
- `src.zip`
- `src.tar.gz`

### Notes

- User-facing caveat only if needed.
```

`Assets` may appear in release notes because GitHub releases attach assets, but
the constructed changelog omits that section.
