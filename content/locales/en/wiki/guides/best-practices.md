---
title: "Best Practices"
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

- `ChildNames` for child ids
- `RequiredChild` for a named child that must exist
- `Child` for checked or optional named child lookup
- `ChildRecord` for exact child-keyed value maps
- `ChildTypeRecord` for exact child-keyed instance maps
- `ChildrenOfClass` for class-filtered child tables
- `IsChildOf`, `IsAncestorOf`, and `IsDescendantOf` for relation checks
- `LoadModules` for validated direct ModuleScript loading

## Depend On The Facade

Use `Arbor.*` public aliases in consuming code.

Lower-level folders are allowed to split so the implementation can stay sane. Treat them as implementation structure unless the API reference says otherwise.
