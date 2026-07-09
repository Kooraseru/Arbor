---
title: Arbor
description: Analyzer-friendly static tree helpers for Luau and Roblox packages.
---

# Arbor

Arbor describes analyzer-visible owned instance surfaces, starting with direct children.

<div class="hero-note">
Arbor is named after the Latin word for tree. It exposes the static structure of owned Roblox instance trees so package code can keep dynamic runtime loading without giving up compile-time key extraction.
</div>

## Start Here

- [Install](install.md)
- [Examples](examples.md)
- [API Reference](api/instance-tree/index.md)
- [Runtime Loaders](runtime-loaders.md)

## What Arbor Proves

Arbor proves analyzer-visible structure:

```txt
direct child names
direct child lookup
class-filtered child names
class-filtered child records
```

It does not prove ModuleScript return types. Runtime-loaded values still need validation.

## Package Boundary

Arbor does not own registries, lifecycle, serialization, dispatch, descriptors, pipeline ordering, or package lookup.
