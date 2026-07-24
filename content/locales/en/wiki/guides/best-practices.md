---
title: Best Practices
---

# Best Practices

## Prefer Direct Ownership

Derive types from trees your package owns.

```lua
type Name = Arbor.ChildNames<typeof(script)>
```

Avoid trying to describe unrelated game services or externally mutated trees.

## Keep Dynamic Values Unknown

Runtime `require` results should enter as `unknown` and leave through a validator.

Do not cast dynamic requires at call sites.

## Pick The Smallest Helper

Use:

- `ChildNames` for ids
- `ChildOf` for one child instance
- `ChildRecord` for exact child-keyed maps
- `ChildrenOfClass` for class-filtered child tables
- `LoadModuleMap` for validated direct ModuleScript loading
