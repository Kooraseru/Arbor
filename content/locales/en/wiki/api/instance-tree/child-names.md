---
title: ChildNames
---

# ChildNames

## Purpose

Returns a union of analyzer-visible direct child names.

## Signature

```lua
Arbor.ChildNames<T>
InstanceTree.ChildNames.Of<T>
```

## Example

```txt title="Tree"
Package/
  init.luau
  Kick.luau
  Ban.luau
```

```lua title="Type"
export type ActionId = Arbor.ChildNames<typeof(script)>
```

## Returned Type

```lua
type ActionId = "Kick" | "Ban"
```

## Common Mistakes

- Expecting descendant names. `ChildNames` only reads direct children.
- Expecting ModuleScript return types. It proves names, not `require` results.
- Using a runtime-discovered `Instance` value whose children are not analyzer-visible.

## Related Functions

- [ChildOf](child-of.md)
- [ChildRecord](child-record.md)
- [ChildNamesOfClass](child-names-of-class.md)
