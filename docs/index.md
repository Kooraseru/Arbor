---
title: Arbor
description: Compile-time hierarchy logic for Luau and Roblox.
---

# Arbor

<div class="arbor-hero">
  <img src="assets/brand/Billboard.svg" alt="Arbor">
  <p>
    Compile-time hierarchy logic for Luau and Roblox.
  </p>
</div>

Arbor is for general use in Roblox/Luau packages. It turns instance-tree shape into type-level names, child lookup types, class-filtered child tables, and typed runtime-loading boundaries.

Its main job is to expose Roblox instance hierarchies to Luau's type system so compile-time package infrastructure can be built from analyzer-visible trees.

## Start Here

- [Install](install.md)
- [Examples](examples.md)
- [API Reference](api/instance-tree/index.md)
- [Runtime Loaders](runtime-loaders.md)

## What Arbor Proves

Arbor exposes analyzer-visible structure:

```txt
direct child names
direct child lookup
class-filtered child names
class-filtered child records
```

It does not prove ModuleScript return types. Runtime-loaded values still need validation.

## Package Boundary

Arbor does not own registries, lifecycle, serialization, dispatch, descriptors, pipeline ordering, or package lookup.
