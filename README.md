<p align="center">
  <a href="https://github.com/Kooraseru/Arbor"><img alt="Stars + Forks + License" src="https://shieldcn.dev/group/github/stars/Kooraseru/Arbor+github/forks/Kooraseru/Arbor+github/license/Kooraseru/Arbor.svg?variant=ghost"></a>
  <br>
  <a href="https://github.com/Kooraseru/Arbor/wiki"><img alt="Wiki" src="https://shieldcn.dev/badge/Wiki-Docs.svg?variant=ghost&logo=ri%3AFaBook"></a>
  <a href="https://github.com/Kooraseru/Arbor/releases"><img alt="Releases" src="https://shieldcn.dev/github/Kooraseru/Arbor/release.svg?variant=ghost"></a>
  <a href="https://github.com/Kooraseru/Arbor/issues"><img alt="Issues" src="https://shieldcn.dev/github/Kooraseru/Arbor/issues.svg?variant=ghost&logo=ri%3APiWarning"></a>
  <br>
  <a href="https://github.com/Kooraseru/Arbor/releases"><img alt="Downloads" src="https://shieldcn.dev/github/Kooraseru/Arbor/downloads.svg?variant=ghost"></a>
  <a href="https://github.com/Kooraseru/Arbor/graphs/contributors"><img alt="Contributors" src="https://shieldcn.dev/github/Kooraseru/Arbor/contributors.svg?variant=ghost"></a>
  <br>
  <a href="CHANGELOG.md"><img alt="Changelog" src="https://shieldcn.dev/badge/Changelog.svg?variant=ghost&logo=ri%3AFaClock"></a>
  <img alt="Built In" src="https://shieldcn.dev/flag/kp.svg?variant=ghost">
</p>

<div align="center">
  <h1>Arbor</h1>
  <p>Analyzer-friendly static tree helpers for Luau/Roblox package surfaces.</p>
  <p>
    Arbor is named after the Latin word for tree. It describes and exposes the static structure of owned instance trees, enabling analyzer-friendly navigation and compile-time type extraction.
  </p>
</div>

## Table Of Contents

- [Status](#status)
- [Install](#install)
- [Quick Start](#quick-start)
- [Public API](#public-api)
- [Wiki](#wiki)
- [Concepts](#concepts)
- [What This Proves](#what-this-proves)
- [Runtime Loader Contract](#runtime-loader-contract)
- [Analyzer Requirements](#analyzer-requirements)
- [Package Boundaries](#package-boundaries)
- [Repository Layout](#repository-layout)
- [Release Blockers](#release-blockers)

## Status

Initial stable package release.

> [!WARNING]
> Typed child-name discovery still depends on analyzer/toolchain behavior. Validate your target environment before treating analyzer-derived child names as a published API guarantee.

## Install

Place `Arbor` wherever your project or package manager exposes required modules.

Require the package root through whatever module reference your environment provides:

```luau
local Arbor = require(path.to.Arbor)
```

When used inside a standalone package, internal Arbor requires use `@self` and focused child modules.

> [!NOTE]
> Package-manager metadata is intentionally not committed yet. First public export should choose the target install story instead of guessing between copy-folder, Wally, pesde, subtree, or another layout.

## Quick Start

Use the root facade when you want fewer require lines:

```luau
local Arbor = require(path.to.Arbor)

local LoadModuleMap = Arbor.RuntimeLoaders.LoadModuleMap

export type ActionId = Arbor.ChildNames<typeof(script)>
export type ActionMap = Arbor.ChildRecord<typeof(script), ActionDefinition>

local actions: ActionMap = LoadModuleMap.From(script, validateAction)

return actions
```

Use focused modules when you want the simplest analyzer path:

```luau
local ChildNames = require(path.to.Arbor.InstanceTree.ChildNames)
local ChildRecord = require(path.to.Arbor.InstanceTree.ChildRecord)
local LoadModuleMap = require(path.to.Arbor.RuntimeLoaders.LoadModuleMap)

export type ActionId = ChildNames.Of<typeof(script)>
export type ActionMap = ChildRecord.Of<typeof(script), ActionDefinition>

local actions: ActionMap = LoadModuleMap.From(script, validateAction)

return actions
```

## Public API

Root exported type aliases:

```txt
Arbor.ChildNames<T>
Arbor.ChildNamesOfClass<T, ClassName>
Arbor.ChildRecord<T, V>
Arbor.ChildOf<T, Name>
Arbor.ChildrenOfClass<T, ClassName>
Arbor.ModuleValidator<T>
```

Root runtime facade:

```txt
Arbor.InstanceTree.ChildNames
Arbor.InstanceTree.ChildNamesOfClass
Arbor.InstanceTree.ChildRecord
Arbor.InstanceTree.ChildOf
Arbor.InstanceTree.ChildrenOfClass
Arbor.RuntimeLoaders.LoadModuleMap
```

Focused modules:

```txt
InstanceTree/ChildNames.Of<T>
InstanceTree/ChildNamesOfClass.Of<T, ClassName>
InstanceTree/ChildRecord.Of<T, V>
InstanceTree/ChildOf.Of<T, Name>
InstanceTree/ChildrenOfClass.Of<T, ClassName>
RuntimeLoaders/LoadModuleMap.From(root, validate)
```

## Wiki

Longer guides live in the GitHub Wiki:

- [Home](https://github.com/Kooraseru/Arbor/wiki)
- [Install](https://github.com/Kooraseru/Arbor/wiki/Install)
- [Analyzer Model](https://github.com/Kooraseru/Arbor/wiki/Analyzer-Model)
- [Type Functions](https://github.com/Kooraseru/Arbor/wiki/Type-Functions)
- [Examples](https://github.com/Kooraseru/Arbor/wiki/Examples)
- [Runtime Loaders](https://github.com/Kooraseru/Arbor/wiki/Runtime-Loaders)
- [Package Boundaries](https://github.com/Kooraseru/Arbor/wiki/Package-Boundaries)
- [Export And CI](https://github.com/Kooraseru/Arbor/wiki/Export-And-CI)
- [FAQ](https://github.com/Kooraseru/Arbor/wiki/FAQ)

## Concepts

`Arbor` is named after the Latin word for tree. The package is about owned instance-tree shape: direct child names, child records, child lookup, and small runtime loaders that preserve a typed boundary.

`ChildNames<T>` returns a union of direct child names visible to the Luau analyzer.

`ChildNamesOfClass<T, ClassName>` returns a union of direct child names whose analyzer-visible type matches the given class.

`ChildRecord<T, V>` returns a table shape with direct child names as keys and `V` as the value type.

`ChildOf<T, Name>` returns the analyzer-visible type of one direct child.

`ChildrenOfClass<T, ClassName>` returns a table shape for direct children whose analyzer-visible type matches the given class.

`LoadModuleMap.From(root, validate)` loads direct ModuleScript children at runtime, validates each required value, and returns a map keyed by ModuleScript name.

> [!TIP]
> Prefer root exported type aliases for package-facing APIs. Reach for focused modules when a leaf `.Of<T>` namespace makes a local type surface easier for the analyzer or a reader to follow.

## What This Proves

Typed child-name discovery proves names and instance-tree shape.

> [!IMPORTANT]
> Typed child-name discovery does not prove ModuleScript return types by itself. Runtime loaders still need validation, and package public APIs still need static, generated, or analyzer-validated surfaces.

## Runtime Loader Contract

```luau
export type ModuleValidator<T> = (value: unknown, moduleScript: ModuleScript) -> T

LoadModuleMap.From<T>(root: Instance, validate: ModuleValidator<T>): { [string]: T }
```

The validator is the boundary between dynamic `require` and project-owned typed behavior.

> [!CAUTION]
> Keep uncertainty at the validator boundary. Do not cast dynamic require results at call sites.

## Analyzer Requirements

These helpers depend on the active Luau analyzer exposing direct children as literal extern properties.

> [!NOTE]
> Validate your target solver/toolchain before treating child-name discovery as public API.

Known confirmed behavior from current research:

```txt
ChildNames<typeof(workspace.Origin)> produced "DefaultModule1" | "DefaultModule2"
and rejected unrelated names in VS Code/Luau LSP.
```

Still important for export:

```txt
confirm CLI/external analyzer parity
confirm behavior after package extraction
confirm module return type strategy separately
```

## Package Boundaries

Arbor owns analyzer-visible tree structure and small helper conventions.

Arbor must not own:

```txt
runtime registries
startup lifecycle
serialization tags
pipeline ordering
dispatch/action parsing
descriptor identity
```

`RuntimeLoaders` exists as a tiny helper for analyzer-friendly runtime loading. It is not a runtime architecture framework.

## Repository Layout

```txt
Arbor/
  .github/
  wiki/
  .gitignore
  src/
    init.luau
    InstanceTree/
      ChildNames.luau
      ChildNamesOfClass.luau
      ChildRecord.luau
      ChildOf.luau
      ChildrenOfClass.luau
    RuntimeLoaders/
      LoadModuleMap.luau
  PACKAGE.md
  Badges.md
  README.md
  CHANGELOG.md
  CONTRIBUTING.md
  LICENSE
```

## License

Apache License 2.0. See [LICENSE](LICENSE).
