---
title: Design Goals
---

# Design Goals

Arbor is intentionally small.

## Goals

- expose Roblox instance hierarchy shape to Luau's type system
- keep package source easy to inspect
- avoid second sources of truth for child names
- preserve dynamic runtime loading when validation is explicit
- keep helper APIs focused enough to explain in one page each

## Non-Goals

- runtime registries
- startup lifecycle
- recursive package discovery
- network serialization
- action dispatch
- package manager lockfiles

If a feature needs one of those responsibilities, it probably belongs in another package or an adapter around Arbor.
