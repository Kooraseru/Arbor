---
title: ChildNamesOfClass
---

# ChildNamesOfClass

## Purpose

Returns a union of direct child names whose analyzer-visible type matches a Roblox class.

## Signature

```lua
Arbor.ChildNamesOfClass<T, ClassType>
InstanceTree.ChildNamesOfClass.Of<T, ClassType>
```

## Example

```lua title="Type"
export type ModuleName = Arbor.ChildNamesOfClass<typeof(script), ModuleScript>
```

## Returned Type

```lua
type ModuleName = "Kick" | "Ban"
```

## Common Mistakes

- Treating class-filtered names as proof of module return types.
- Using this where `ChildrenOfClass` would preserve more child-instance information.
- Relying on this without checking analyzer support in the target toolchain.

## Related Functions

- [ChildrenOfClass](children-of-class.md)
- [ChildNames](child-names.md)
