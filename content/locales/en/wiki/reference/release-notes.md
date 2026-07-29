---
title: "Release Notes"
---

# Release Notes

Release metadata and localized prose are the source of truth for Arbor release communication.

Canonical version, channel, date, and asset metadata live in `release-notes/` as TOML. Human-readable sections live in each locale's `release.toml`.

## Metadata

```toml
version = "v1.0.1"
channel = "stable"
date = "2026-07-09"
assets = ["Arbor.rbxm"]
```

The release-note and changelog generators combine this metadata with the selected locale. The root GitHub release body uses whichever locale is marked `default = true`.
