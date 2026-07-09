---
title: ChildRecord
---

# ChildRecord

## Purpose

Builds a table shape whose keys are analyzer-visible direct child names and whose values are the provided type.

## Signature

```luau
Arbor.ChildRecord<T, V>
InstanceTree.ChildRecord.Of<T, V>
```

## Example

```luau title="Type"
export type ActionMap = Arbor.ChildRecord<typeof(script), ActionDefinition>
```

## Returned Type

```luau
type ActionMap = {
  Kick: ActionDefinition,
  Ban: ActionDefinition,
}
```

## Common Mistakes

- Using `{ [string]: V }` when you want exact child keys.
- Assuming `ChildRecord` loads modules. It only describes a table shape.
- Forgetting to validate runtime-loaded module values before assigning them to this shape.

## Related Functions

- [ChildNames](child-names.md)
- [RuntimeLoaders.LoadModuleMap](../runtime-loaders/load-module-map.md)
