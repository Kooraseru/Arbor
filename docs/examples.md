---
title: Examples
---

# Examples

These examples show the owned tree, the call, the expected analyzer-facing result, and the caveat.

## Direct Child Names

Owned tree:

```txt
Actions
  Kick.luau
  Ban.luau
```

Call:

```luau
export type ActionId = Arbor.ChildNames<typeof(script)>
```

Expected result:

```luau
type ActionId = "Kick" | "Ban"
```

## Class-Filtered Child Names

Owned tree:

```txt
Actions
  Kick.luau
  Ban.luau
  Metadata
```

Call:

```luau
export type ActionModuleId = Arbor.ChildNamesOfClass<typeof(script), "ModuleScript">
```

Expected result:

```luau
type ActionModuleId = "Kick" | "Ban"
```

`Metadata` is not included because it is not analyzer-visible as a `ModuleScript`.

## Validated Module Map

Owned tree:

```txt
Actions
  Kick.luau
  Ban.luau
```

Call:

```luau
local LoadModuleMap = Arbor.RuntimeLoaders.LoadModuleMap

export type ActionId = Arbor.ChildNames<typeof(script)>
export type ActionMap = Arbor.ChildRecord<typeof(script), ActionDefinition>

local actions: ActionMap = LoadModuleMap.From(script, validateAction)
```

Expected result:

```luau
type ActionId = "Kick" | "Ban"
type ActionMap = {
  Kick: ActionDefinition,
  Ban: ActionDefinition,
}
```

Runtime behavior:

```txt
requires direct ModuleScript children
passes each required value into validateAction
returns a map keyed by ModuleScript name
```

