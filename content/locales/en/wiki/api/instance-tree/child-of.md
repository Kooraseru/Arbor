---
title: ChildOf
---

# ChildOf

## Purpose

Returns the analyzer-visible type of one direct child by name.

## Signature

```lua
Arbor.ChildOf<T, Name>
InstanceTree.ChildOf.Of<T, Name>
```

## Example

```lua title="Type"
export type KickModule = Arbor.ChildOf<typeof(script), "Kick">
```

## Returned Type

```lua
type KickModule = typeof(script.Kick)
```

## Common Mistakes

- Passing a name that is not a direct child.
- Treating the child instance type as the module return type.
- Using it when a full child table shape would be clearer.

## Related Functions

- [ChildNames](child-names.md)
- [ChildRecord](child-record.md)
