# Arbor

Status: stable
Class: compile-time helper package
Public-ready: yes
Entrypoint: src/init.luau
Runtime: Luau type functions, optional runtime loader helpers
Roblox services: none

## Purpose

Arbor is named after the Latin word for tree. It owns analyzer-facing helper types for describing and exposing the static structure of owned instance trees.

It helps package-owned runtime loaders expose typed lookup surfaces without hand-maintained manifests.

## Required Dependencies

- None

## Optional Dependencies

- None

## Public API

Root facade:

- `Arbor.ChildNames<T>`
- `Arbor.ChildNamesOfClass<T, ClassName>`
- `Arbor.ChildRecord<T, V>`
- `Arbor.ChildOf<T, Name>`
- `Arbor.ChildrenOfClass<T, ClassName>`
- `Arbor.ModuleValidator<T>`
- `Arbor.InstanceTree.ChildNames.Of<T>`
- `Arbor.InstanceTree.ChildNamesOfClass.Of<T, ClassName>`
- `Arbor.InstanceTree.ChildRecord.Of<T, V>`
- `Arbor.InstanceTree.ChildOf.Of<T, Name>`
- `Arbor.InstanceTree.ChildrenOfClass.Of<T, ClassName>`
- `Arbor.RuntimeLoaders.LoadModuleMap.From(root, validate)`

Focused modules remain public:

- `InstanceTree/ChildNames.Of<T>`
- `InstanceTree/ChildNamesOfClass.Of<T, ClassName>`
- `InstanceTree/ChildRecord.Of<T, V>`
- `InstanceTree/ChildOf.Of<T, Name>`
- `InstanceTree/ChildrenOfClass.Of<T, ClassName>`
- `RuntimeLoaders/LoadModuleMap.From(root, validate)`

## Extraction Notes

- Copy this repository as `Arbor`.
- Require the root facade when it reduces repeated require surface.
- Prefer root exported type aliases for package-facing type surfaces.
- Require focused modules directly when you need the leaf module's original `.Of` type-function namespace.
- The root facade is static and explicit; it does not discover helper modules dynamically.
- Arbor core must not runtime-load modules or own runtime registry state.
- Runtime loaders are isolated under `RuntimeLoaders/`.

## Known Limitations

- These helpers depend on the active analyzer exposing children as extern properties.
- Child-name helpers prove names and instance-tree shape, not ModuleScript return types.
- Descendant/query helpers are intentionally not public until analyzer probes prove them.
- License: Apache-2.0.
- Analyzer-specific behavior should still be validated in each target toolchain before treating extracted child names as a public guarantee.
