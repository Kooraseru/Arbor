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

Arbor is a Luau package for turning analyzer-visible Roblox instance trees into useful static types.

Its public API is intentionally small: direct child discovery, child/ancestor/descendant relation types, exact child-keyed records, and tiny validated runtime loaders for places where Luau has to cross from typed source into dynamic `require`.

## Start Here

- [Install](install.md)
- [API Reference](api/index.md)
- [Runtime Loaders](api/runtime-loaders/index.md)
- [Release Notes](reference/release-notes.md)

## What Arbor Proves

Arbor exposes analyzer-visible structure:

```txt
direct child names
direct child lookup
class-filtered child names
class-filtered child records
direct child, ancestor, and descendant relations
```

It does not prove ModuleScript return types. Runtime-loaded values still need validation.

## Public Surface

The supported consumer entry point is the package root:

```lua
local Arbor = require(path.to.Arbor)
```

The root exports runtime aliases such as `CollectChildren`, `ExpectChild`, `FindChild`, and `LoadModules`, plus type aliases such as `ChildNames`, `RequiredChild`, `ChildTypeRecord`, `IsChildOf`, and `IsDescendantOf`.

## Package Boundary

Arbor does not own registries, lifecycle, serialization, dispatch, descriptors, pipeline ordering, or package lookup.

## Release Notes

- [Release Notes](reference/release-notes.md)
