---
title: ChildNamesOfClass
---

# ChildNamesOfClass

## Purpose

Returns a union of direct child names whose analyzer-visible type matches a Roblox class.

## Signature

```luau
Arbor.ChildNamesOfClass<T, ClassName>
InstanceTree.ChildNamesOfClass.Of<T, ClassName>
```

## Example

```luau title="Type"
export type ModuleName = Arbor.ChildNamesOfClass<typeof(script), "ModuleScript">
```

## Returned Type

```luau
type ModuleName = "Kick" | "Ban"
```

## Common Mistakes

- Treating class-filtered names as proof of module return types.
- Using this where `ChildrenOfClass` would preserve more child-instance information.
- Relying on this without checking analyzer support in the target toolchain.

## Related Functions

- [ChildrenOfClass](children-of-class.md)
- [ChildNames](child-names.md)
