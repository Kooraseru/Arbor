---
title: Serialized Types
---

# Serialized Types

## Problem

You have a folder of type modules and want Luau to understand the child names,
records, and relationships from the actual analyzer-visible tree.

## Source

```lua title="IdentifyType.luau"
--8<-- "src/examples/serialized-types/IdentifyType.luau"
```

```lua title="CheckRelations.luau"
--8<-- "src/examples/serialized-types/CheckRelations.luau"
```

## Result

`ChildNames`, `ChildRecord`, `ChildOf`, `IsChildOf`, `IsAncestorOf`, and
`IsDescendantOf` are checked against the fixture tree under
`src/examples/serialized-types/Fixture`.

## Why It Works

The CLI analyzer loads Arbor's sourcemap, so the source tree appears at
`ReplicatedStorage.Shared.Packages.Arbor.src`. Arbor's type functions can then
read analyzer-visible children and relationships from that tree.

