---
title: Typing A Child Tree
---

# Typing A Child Tree

Use Arbor when your Roblox data model has a child tree and you want Luau to understand that tree at compile time.

## Recommended Shape

```txt
SomeRoot/
  init.luau
  FeatureA.luau
  FeatureB.luau
```

Inside `init.luau`, derive names or records from `typeof(script)`:

```lua
local Arbor = require(path.to.Arbor)

export type FeatureName = Arbor.ChildNames<typeof(script)>
```

## Keep Runtime Separate

Use Arbor for static shape. Use validators for runtime module values.

```lua
export type FeatureMap = Arbor.ChildRecord<typeof(script), FeatureDefinition>
```

That type says what keys exist. It does not say the modules have already been required or validated.
