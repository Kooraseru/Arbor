---
title: Creating a Package
---

# Creating a Package

Use Arbor when your package owns a small child tree and wants the analyzer to understand that tree.

## Recommended Shape

```txt
Package/
  init.luau
  FeatureA.luau
  FeatureB.luau
```

Inside `init.luau`, derive names or records from `typeof(script)`:

```luau
local Arbor = require(path.to.Arbor)

export type FeatureName = Arbor.ChildNames<typeof(script)>
```

## Keep Runtime Separate

Use Arbor for static shape. Use validators for runtime module values.

```luau
export type FeatureMap = Arbor.ChildRecord<typeof(script), FeatureDefinition>
```

That type says what keys exist. It does not say the modules have already been required or validated.
