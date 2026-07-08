# Examples

These examples show the call, the expected analyzer-facing result, and the important caveat.

The examples assume Arbor can see an owned direct-child surface through the active Luau analyzer.

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

Use this when callers need a typed id surface for children owned by the current package.

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

## Child Records

Owned tree:

```txt
Actions
  Kick.luau
  Ban.luau
```

Call:

```luau
export type ActionMap = Arbor.ChildRecord<typeof(script), ActionDefinition>
```

Expected result:

```luau
type ActionMap = {
  Kick: ActionDefinition,
  Ban: ActionDefinition,
}
```

This only proves the keys. Validate ModuleScript return values before putting them in the record.

## Child Lookup

Owned tree:

```txt
Actions
  Kick.luau
```

Call:

```luau
export type KickModule = Arbor.ChildOf<typeof(script), "Kick">
```

Expected result:

```luau
type KickModule = typeof(script.Kick)
```

If the child is not analyzer-visible, Arbor returns `never`.

## Children Of Class

Owned tree:

```txt
Actions
  Kick.luau
  Ban.luau
  Metadata
```

Call:

```luau
export type ModuleChildren = Arbor.ChildrenOfClass<typeof(script), "ModuleScript">
```

Expected result:

```luau
type ModuleChildren = {
  Kick: typeof(script.Kick),
  Ban: typeof(script.Ban),
}
```

Use this when you need the analyzer-visible child instances, not a loaded module-return map.

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

The validator is what turns unknown required values into trusted package behavior.
