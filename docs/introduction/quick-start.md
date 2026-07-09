---
title: Quick Start
---

# Quick Start

Require the root facade:

```luau
local Arbor = require(path.to.Arbor)
```

Use direct child names:

```luau
export type ActionId = Arbor.ChildNames<typeof(script)>
```

Create a child-keyed runtime map type:

```luau
type ActionMap = Arbor.ChildRecord<typeof(script), ActionDefinition>
```

Load runtime modules through a validator:

```luau
local LoadModuleMap = Arbor.RuntimeLoaders.LoadModuleMap

local actions: ActionMap = LoadModuleMap.From(script, validateAction)
```

The key rule is simple: let Arbor expose the Roblox hierarchy to Luau's type system, then validate dynamic `require` results at the runtime boundary.
