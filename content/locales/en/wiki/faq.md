---
title: "FAQ"
---

# FAQ

## Does Arbor load modules at compile time?

No. Arbor's type functions inspect analyzer-visible instance metadata.

## Does ChildNames prove ModuleScript return types?

No. It proves direct child names. Validate ModuleScript return values at runtime.

## Why is there an init.luau facade?

The facade is the stable public surface:

```lua
Arbor.ChildNames<T>
Arbor.ChildRecord<T, V>
Arbor.LoadModules(root, validate)
```

The implementation can split into focused folders without making consumers chase source layout.

## Should I require files under Definitions or RuntimeLoaders directly?

Prefer the root facade unless the API reference documents a lower-level member as public.

Direct requires into implementation folders make consumer code care about Arbor's internal split, which is exactly the dependency we do not want.

## Why does Arbor have runtime functions if it is mostly compile-time?

Runtime functions exist only at the boundary where Roblox gives you actual `Instance` children or dynamic `require` results.

They are deliberately small. They are not registries, boot systems, or package discovery frameworks.
