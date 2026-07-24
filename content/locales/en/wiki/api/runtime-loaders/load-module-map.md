---
title: LoadModuleMap
---

# LoadModuleMap

## Purpose

Loads direct ModuleScript children and validates each required value.

## Signature

```lua
export type ModuleValidator<T> = (value: unknown, moduleScript: ModuleScript) -> T

LoadModuleMap.From<T>(root: Instance, validate: ModuleValidator<T>): { [string]: T }
```

## Example

```lua title="Runtime loading"
local LoadModuleMap = Arbor.RuntimeLoaders.LoadModuleMap

local actions = LoadModuleMap.From(script, validateAction)
```

## Returned Type

```lua
{ [string]: T }
```

Pair it with `ChildRecord<typeof(root), T>` when the analyzer can see the exact child names.

## Common Mistakes

- Casting `require` results instead of validating `unknown`.
- Expecting recursive descendant loading.
- Letting this become a registry or lifecycle system.

## Related Functions

- [ChildRecord](../instance-tree/child-record.md)
- [Runtime Loading](../../runtime-loaders.md)
