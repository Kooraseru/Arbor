<div align="center">
  <h1>TypeManager</h1>
  <p>Analyzer-facing type helpers for Luau/Roblox package surfaces.</p>
  <p>
    TypeManager helps modular packages keep dynamic runtime loading without giving up compile-time key checks.
    It is meant for owned child trees: folders where the package owns the children, discovers them at runtime, and wants the analyzer to know the child names.
  </p>
</div>

<p align="center">
  <br>
  <a href="https://github.com/Kooraseru/TypeManager/wiki"><img alt="Wiki" src="https://shieldcn.dev/badge/Wiki.svg?variant=ghost&logo=lu%3AFlower"></a>
  <a href="https://github.com/Kooraseru/TypeManager/releases"><img alt="Release" src="https://shieldcn.dev/badge/Release-v1.0.0.svg?variant=ghost&logo=ri%3AGitBranchLine"></a>
  <a href="https://github.com/Kooraseru/TypeManager/issues"><img alt="Issues" src="https://shieldcn.dev/badge/Issues-0%20open.svg?variant=ghost&logo=ri%3AErrorWarningLine"></a>
  <br>
  <a href="https://github.com/Kooraseru/TypeManager"><img alt="Stars" src="https://shieldcn.dev/badge/Stars-0.svg?variant=ghost&logo=ri%3AStarLine"></a>
  <a href="CONTRIBUTING.md"><img alt="Contributors" src="https://shieldcn.dev/badge/Contributors-1.svg?variant=ghost&logo=ri%3ATeamLine"></a>
  <a href="https://github.com/sponsors/Kooraseru"><img alt="Sponsor" src="https://shieldcn.dev/badge/Sponsors-0.svg?variant=ghost&logo=ri%3AHeartLine"></a>
  <br>
  <a href="CHANGELOG.md"><img alt="Changelog" src="https://shieldcn.dev/badge/Changelog.svg?variant=ghost&logo=ri%3APiTimer"></a>
  <a href="LICENSE"><img alt="License" src="https://shieldcn.dev/badge/License-Apache%202.0.svg?variant=ghost&logo=ri%3AScales3Line"></a>
  <img alt="Flag" src="https://shieldcn.dev/flag/kp.svg?variant=ghost">
</p>

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

Place `TypeManager` wherever your project or package manager exposes required modules.

Require the package root through whatever module reference your environment provides:

```luau
local TypeManager = require(path.to.TypeManager)
```

When used inside a standalone package, internal TypeManager requires use `@self` and focused child modules.

> [!NOTE]
> Package-manager metadata is intentionally not committed yet. First public export should choose the target install story instead of guessing between copy-folder, Wally, pesde, subtree, or another layout.

## Quick Start

Use the root facade when you want fewer require lines:

```luau
local TypeManager = require(path.to.TypeManager)

local LoadModuleMap = TypeManager.RuntimeLoaders.LoadModuleMap

export type ActionId = TypeManager.ChildNames<typeof(script)>
export type ActionMap = TypeManager.ChildRecord<typeof(script), ActionDefinition>

local actions: ActionMap = LoadModuleMap.From(script, validateAction)

return actions
```

Use focused modules when you want the simplest analyzer path:

```luau
local ChildNames = require(path.to.TypeManager.InstanceTree.ChildNames)
local ChildRecord = require(path.to.TypeManager.InstanceTree.ChildRecord)
local LoadModuleMap = require(path.to.TypeManager.RuntimeLoaders.LoadModuleMap)

export type ActionId = ChildNames.Of<typeof(script)>
export type ActionMap = ChildRecord.Of<typeof(script), ActionDefinition>

local actions: ActionMap = LoadModuleMap.From(script, validateAction)

return actions
```

## Public API

Root exported type aliases:

```txt
TypeManager.ChildNames<T>
TypeManager.ChildRecord<T, V>
TypeManager.ChildOf<T, Name>
TypeManager.ChildrenOfClass<T, ClassName>
TypeManager.ModuleValidator<T>
```

Root runtime facade:

```txt
TypeManager.InstanceTree.ChildNames
TypeManager.InstanceTree.ChildRecord
TypeManager.InstanceTree.ChildOf
TypeManager.InstanceTree.ChildrenOfClass
TypeManager.RuntimeLoaders.LoadModuleMap
```

Focused modules:

```txt
InstanceTree/ChildNames.Of<T>
InstanceTree/ChildRecord.Of<T, V>
InstanceTree/ChildOf.Of<T, Name>
InstanceTree/ChildrenOfClass.Of<T, ClassName>
RuntimeLoaders/LoadModuleMap.From(root, validate)
```

## Wiki

Longer guides live in the GitHub Wiki:

- [Home](https://github.com/Kooraseru/TypeManager/wiki)
- [Install](https://github.com/Kooraseru/TypeManager/wiki/Install)
- [Analyzer Model](https://github.com/Kooraseru/TypeManager/wiki/Analyzer-Model)
- [Type Functions](https://github.com/Kooraseru/TypeManager/wiki/Type-Functions)
- [Runtime Loaders](https://github.com/Kooraseru/TypeManager/wiki/Runtime-Loaders)
- [Package Boundaries](https://github.com/Kooraseru/TypeManager/wiki/Package-Boundaries)
- [Export And CI](https://github.com/Kooraseru/TypeManager/wiki/Export-And-CI)
- [FAQ](https://github.com/Kooraseru/TypeManager/wiki/FAQ)

## Concepts

`ChildNames<T>` returns a union of direct child names visible to the Luau analyzer.

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

TypeManager owns compile-time type surfaces and small helper conventions.

TypeManager must not own:

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
TypeManager/
  .github/
  wiki/
  .gitignore
  src/
    init.luau
    InstanceTree/
      ChildNames.luau
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
