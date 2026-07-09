---
title: ChildrenOfClass
---

# ChildrenOfClass

## Purpose

Returns a table shape for direct children whose analyzer-visible type matches a Roblox class.

## Signature

```luau
Arbor.ChildrenOfClass<T, ClassName>
InstanceTree.ChildrenOfClass.Of<T, ClassName>
```

## Example

```luau title="Type"
export type ModuleChildren = Arbor.ChildrenOfClass<typeof(script), "ModuleScript">
```

## Returned Type

```luau
type ModuleChildren = {
  Kick: typeof(script.Kick),
  Ban: typeof(script.Ban),
}
```

## Common Mistakes

- Expecting runtime `IsA` behavior. This is analyzer-facing type filtering.
- Expecting descendants. The filter applies only to direct children.
- Using this when you need validated module return values.

## Related Functions

- [ChildNamesOfClass](child-names-of-class.md)
- [ChildRecord](child-record.md)
