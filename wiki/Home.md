# Arbor Wiki

Arbor provides analyzer-facing type helpers for Luau/Roblox packages.

It exists for one reason:

```txt
Let package-owned dynamic module loading keep compile-time key surfaces.
```

## Pages

- [Install](Install)
- [Analyzer Model](Analyzer-Model)
- [Type Functions](Type-Functions)
- [Runtime Loaders](Runtime-Loaders)
- [Package Boundaries](Package-Boundaries)
- [Export And CI](Export-And-CI)
- [FAQ](FAQ)

## Quick Example

```luau
local Arbor = require(path.to.Arbor)

local LoadModuleMap = Arbor.RuntimeLoaders.LoadModuleMap

export type ActionId = Arbor.ChildNames<typeof(script)>
export type ActionMap = Arbor.ChildRecord<typeof(script), ActionDefinition>

local actions: ActionMap = LoadModuleMap.From(script, validateAction)

return actions
```

> [!IMPORTANT]
> Typed child-name discovery proves names. It does not prove ModuleScript return types. Validate runtime-loaded modules.
