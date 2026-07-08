# Changelog

All notable Arbor package changes should be recorded here.

Version slots mean:

```txt
[core release].[implementation].[bug-fix/patch]
```

## 1.1.1 - 2026-07-08

### Summary

```diff
+ Added examples-focused documentation for Arbor type helpers.
- Removed slogan-style wiki Home wording.
```

### Documentation

- Added `wiki/Examples.md` with owned-tree examples, calls, expected analyzer-facing results, and runtime notes.
- Expanded `wiki/Type-Functions.md` into a call/result reference format.
- Updated wiki Home copy to describe Arbor's practical use without the old "exists for one reason" phrasing.
- Linked the Examples page from README and wiki Home.

## 1.1.0 - 2026-07-08

### Summary

```diff
+ Added one class-filtered direct-child type helper.
```

### API

- Added `ChildNamesOfClass<T, ClassName>`.
- Returns a union of direct child names whose analyzer-visible child type matches `ClassName`.
- Complements `ChildrenOfClass<T, ClassName>`, which returns a table shape instead of a name union.

### Documentation

- Added `ChildNamesOfClass` to README, package metadata, and wiki type-function docs.
- Updated the local roadmap to mark the first Lane 1 helper as implemented.

## 1.0.0 - 2026-07-08

### Summary

```diff
+ Added initial Arbor source, docs, workflows, and package metadata.
+ Added direct-child analyzer helpers and validated module loading.
- Removed default table.freeze usage from type-behavior placeholder modules.
```

### API

- Added `src/init.luau` as the root facade.
- Added root exported type aliases:
  - `ChildNames<T>`
  - `ChildRecord<T, V>`
  - `ChildOf<T, Name>`
  - `ChildrenOfClass<T, ClassName>`
  - `ModuleValidator<T>`
- Added focused type-function modules under `src/InstanceTree/`.

### Runtime

- Added `RuntimeLoaders/LoadModuleMap`.
- `LoadModuleMap.From(root, validate)` requires direct ModuleScript children, validates each loaded value, and returns a map keyed by ModuleScript name.

### Documentation

- Added README, package metadata, contribution notes, and wiki drafts.
- Documented analyzer limits around typed child-name discovery.
- Documented that child-name discovery proves names and instance-tree shape, not ModuleScript return types.

### Repository

- Added Apache-2.0 license text.
- Added GitHub issue templates, pull request template, funding metadata, CI, wiki sync, and per-commit release automation.
- Moved runtime/analyzer-facing Luau source under `src/`.

### Removed

- Removed default `table.freeze` usage from type-behavior placeholder modules.
