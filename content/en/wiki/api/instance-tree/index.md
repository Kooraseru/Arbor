---
title: InstanceTree
---

# InstanceTree

`InstanceTree` contains type helpers for analyzer-visible direct children.

These helpers answer questions like:

```txt
what child names does the analyzer see?
what is the type of one child?
what table shape can be derived from direct child names?
which direct children match a Roblox class?
```

## Helpers

- [ChildNames](child-names.md)
- [ChildOf](child-of.md)
- [ChildRecord](child-record.md)
- [ChildrenOfClass](children-of-class.md)
- [ChildNamesOfClass](child-names-of-class.md)

## Boundary

InstanceTree helpers prove analyzer-visible tree shape. They do not prove ModuleScript return values.
