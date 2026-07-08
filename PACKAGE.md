# TypeManager

Status: export-prep
Class: compile-time helper package
Public-ready: no
Entrypoint: init.luau
Runtime: Luau type functions, optional runtime loader helpers
Roblox services: none

## Purpose

TypeManager owns analyzer-facing helper types and type functions. It helps package-owned runtime loaders expose typed lookup surfaces without hand-maintained manifests.

## Required Dependencies

- None

## Optional Dependencies

- None

## Public API

Root facade:

- `TypeManager.ChildNames<T>`
- `TypeManager.ChildRecord<T, V>`
- `TypeManager.ChildOf<T, Name>`
- `TypeManager.ChildrenOfClass<T, ClassName>`
- `TypeManager.ModuleValidator<T>`
- `TypeManager.InstanceTree.ChildNames.Of<T>`
- `TypeManager.InstanceTree.ChildRecord.Of<T, V>`
- `TypeManager.InstanceTree.ChildOf.Of<T, Name>`
- `TypeManager.InstanceTree.ChildrenOfClass.Of<T, ClassName>`
- `TypeManager.RuntimeLoaders.LoadModuleMap.From(root, validate)`

Focused modules remain public:

- `InstanceTree/ChildNames.Of<T>`
- `InstanceTree/ChildRecord.Of<T, V>`
- `InstanceTree/ChildOf.Of<T, Name>`
- `InstanceTree/ChildrenOfClass.Of<T, ClassName>`
- `RuntimeLoaders/LoadModuleMap.From(root, validate)`

## Extraction Notes

- Copy this folder as `TypeManager`.
- Require the root facade when it reduces repeated require surface.
- Prefer root exported type aliases for package-facing type surfaces.
- Require focused modules directly when you need the leaf module's original `.Of` type-function namespace.
- The root facade is static and explicit; it does not discover helper modules dynamically.
- TypeManager core must not runtime-load modules or own runtime registry state.
- Runtime loaders are isolated under `RuntimeLoaders/`.

## Known Limitations

- These helpers depend on the active analyzer exposing children as extern properties.
- Child-name helpers prove names and instance-tree shape, not ModuleScript return types.
- Descendant/query helpers are intentionally not public until analyzer probes prove them.
- License: Apache-2.0.
- Public release is blocked on extracted analyzer parity, CI, and package-manager/export target selection.
