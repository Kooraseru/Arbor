---
title: Arbor
description: Compile-time Roblox data model typing for Luau.
---

# Arbor

<div class="arbor-hero">
  <img src="assets/brand/Billboard.svg" alt="Arbor">
  <p>
    Compile-time Roblox data model typing for Luau.
  </p>
</div>

Arbor is a Luau library that brings compile-time typing to Roblox data models through type-level names, child lookup types, class-filtered child tables, and validated runtime loading.

Its main job is to expose analyzer-visible Roblox instance hierarchies to Luau's type system. That can be useful inside packages, game services, plugin models, test fixtures, or any other Roblox data model shape your analyzer can see.

## Start Here

- [Install](install.md)
- [Examples](examples.md)
- [API Reference](api/instance-tree/index.md)
- [Runtime Loaders](runtime-loaders.md)
- [Release Notes](reference/release-notes.md)

## What Arbor Proves

Arbor exposes analyzer-visible structure:

```txt
direct child names
direct child lookup
class-filtered child names
class-filtered child records
```

It does not prove ModuleScript return types. Runtime-loaded values still need validation.

## Boundary

Arbor does not own registries, lifecycle, serialization, dispatch, descriptors, pipeline ordering, or package lookup.

## Release Notes

- [Release Notes](reference/release-notes.md)
