# Changelog

All notable Arbor package changes should be recorded here.

## 1.0.0 - 2026-07-08

- Added root `init.luau` facade with exported type aliases.
- Added `InstanceTree` type functions for child-name and child-record surfaces.
- Added `RuntimeLoaders/LoadModuleMap` for validated direct-child ModuleScript loading.
- Removed default `table.freeze` usage from type-behavior placeholder modules.
- Added Apache-2.0 license text.
- Added standalone repository docs, contribution notes, package metadata, and GitHub templates.
- Added GitHub Actions CI, wiki sync, and per-commit release automation.
- Moved runtime/analyzer-facing Luau source under `src/`.
- Documented analyzer limits around typed child-name discovery and ModuleScript return types.
