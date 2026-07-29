---
title: "API Reference"
description: "Public Arbor API reference."
---

# API Reference

Arbor exposes one package root and a small set of public members.

The root facade is the supported consumer surface:

```lua
local Arbor = require(path.to.Arbor)
```

## Summary

| Member | Kind | Purpose |
| --- | --- | --- |
| `Arbor.Version` | value | Current package version string. |
| `Arbor.EntryProtocolVersion` | value | Facade metadata protocol version. |
| `Arbor.CollectChildren` | function | Return direct children keyed by name. |
| `Arbor.FindChild` | function | Return a named direct child or `nil`. |
| `Arbor.ExpectChild` | function | Return a named direct child or raise an error. |
| `Arbor.LoadModules` | function | Load direct `ModuleScript` children with validation. |
| `Arbor.Child` | type | Resolve one direct child by name with checked, optional, or required mode. |
| `Arbor.RequiredChild` | type | Resolve one required direct child by name. |
| `Arbor.ChildNames` | type | Union of analyzer-visible direct child names. |
| `Arbor.ChildNamesOfClass` | type | Union of direct child names matching a class. |
| `Arbor.ChildOf` | type | Keep a child type only if it is a direct child of a parent. |
| `Arbor.ChildRecord` | type | Table keyed by direct child names with a chosen value type. |
| `Arbor.ChildTypeRecord` | type | Table keyed by direct child names with child instance types. |
| `Arbor.ChildrenOfClass` | type | Table of direct children matching a class. |
| `Arbor.IsChildOf` | type | Boolean direct-child relation check. |
| `Arbor.AncestorOf` | type | Keep an ancestor type only if the relation passes. |
| `Arbor.DescendantOf` | type | Keep a descendant type only if the relation passes. |
| `Arbor.IsAncestorOf` | type | Boolean ancestor relation check. |
| `Arbor.IsDescendantOf` | type | Boolean descendant relation check. |
| `Arbor.Mold` | type | Low-level type-function molding primitive. |
| `Arbor.Run` | type | Low-level molded definition resolver. |
| `Arbor.Resolve1` | type | Resolve a definition with one type argument. |
| `Arbor.Resolve2` | type | Resolve a definition with two type arguments. |

## API Groups

| Group | Contents |
| --- | --- |
| [Runtime Members](runtime.md) | `CollectChildren`, `FindChild`, and `ExpectChild`. |
| [Child Types](children.md) | Named child lookup, child name unions, exact child records, and class-filtered children. |
| [Relation Types](relations.md) | Direct-child, ancestor, and descendant filters/checks. |
| [Definition Runtime](definitions.md) | Low-level `Mold`, `Run`, `Resolve1`, and `Resolve2` aliases. |
| [Runtime Loaders](runtime-loaders/index.md) | Validated direct `ModuleScript` loading. |

## Boundary

Arbor reference pages describe the public surface exported by `src/arbor@1.1.0/init.luau`.

Pages under `Authoring`, `Definitions`, `Mold`, and `Run` are implementation-facing unless the root facade exports a public alias for them. They are documented as split-ready internals only where that helps explain the public API.
