---
title: FAQ
---

# FAQ

## Does Arbor load modules at compile time?

No. Arbor's type functions inspect analyzer-visible instance metadata.

## Does ChildNames prove ModuleScript return types?

No. It proves direct child names. Validate ModuleScript return values at runtime.

## Why is there an init.luau facade?

The facade reduces require noise for consumers that want root aliases:

```lua
Arbor.ChildNames<T>
Arbor.ChildRecord<T, V>
```

Focused modules remain available when local code reads better with the original `.Of<T>` namespace.

