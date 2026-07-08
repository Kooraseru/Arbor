---
title: Runtime Loaders
---

# Runtime Loaders

Runtime loaders are small helpers for pairing dynamic runtime discovery with explicit validation.

## LoadModuleMap

```luau
local LoadModuleMap = Arbor.RuntimeLoaders.LoadModuleMap
```

Contract:

```luau
export type ModuleValidator<T> = (value: unknown, moduleScript: ModuleScript) -> T

LoadModuleMap.From<T>(root: Instance, validate: ModuleValidator<T>): { [string]: T }
```

Behavior:

```txt
reads direct children with GetChildren()
requires direct ModuleScript children
sorts by ModuleScript name
validates each required value
returns a map keyed by ModuleScript name
```

The validator is where uncertainty belongs. Call sites should receive typed values, not dynamic require results.

