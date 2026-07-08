# Arbor Wiki

Arbor provides analyzer-friendly helpers for describing owned Roblox instance surfaces.

Use it when a package owns a folder of children and wants the Luau analyzer to understand that static surface: child names, child lookup, class-filtered children, and validated module maps.

## Pages

- [Install](Install)
- [Analyzer Model](Analyzer-Model)
- [Type Functions](Type-Functions)
- [Examples](Examples)
- [Runtime Loaders](Runtime-Loaders)
- [Package Boundaries](Package-Boundaries)
- [Export And CI](Export-And-CI)
- [FAQ](FAQ)

## Quick Example

Given this owned tree:

```txt
Actions
  Kick.luau
  Ban.luau
```

```luau
local Arbor = require(path.to.Arbor)

local LoadModuleMap = Arbor.RuntimeLoaders.LoadModuleMap

export type ActionId = Arbor.ChildNames<typeof(script)>
export type ActionMap = Arbor.ChildRecord<typeof(script), ActionDefinition>

local actions: ActionMap = LoadModuleMap.From(script, validateAction)

return actions
```

Expected type result:

```luau
type ActionId = "Kick" | "Ban"
```

> [!IMPORTANT]
> Typed child-name discovery proves names. It does not prove ModuleScript return types. Validate runtime-loaded modules.
