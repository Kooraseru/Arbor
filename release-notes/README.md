# Release Notes

Release notes are source inputs for GitHub release bodies and generated
`CHANGELOG.md` output. Canonical release identity, channel, date, and asset
metadata are TOML. Human-readable release prose lives in each locale's
`release.toml`.

Use a version-shaped tree:

```txt
release-notes/
  v1.0.1.toml
  v1.1.0/
    stable.toml
    beta.1.toml
    beta.2.toml
```

Stable releases may be authored as a top-level TOML file when there are no
pre-releases:

```txt
release-notes/v1.0.1.toml
```

When a version has pre-releases, use the version folder. The stable release note
for that version lives in `stable.toml`; pre-release metadata uses the suffix:

```txt
release-notes/v1.1.0/stable.toml
release-notes/v1.1.0/beta.1.toml
release-notes/v1.1.0/beta.2.toml
```

The full tags are derived from the path:

| Path | Tag |
| --- | --- |
| `release-notes/v1.0.1.toml` | `v1.0.1` |
| `release-notes/v1.1.0/stable.toml` | `v1.1.0` |
| `release-notes/v1.1.0/beta.1.toml` | `v1.1.0-beta.1` |

Each metadata file declares `version`, `channel`, optional `date`, and `assets`.
The generator supplies Markdown heading levels for GitHub release bodies and
localized changelog pages.
