# TypeManager

Analyzer-facing type helpers for Luau/Roblox package surfaces.

TypeManager helps modular packages keep dynamic runtime loading without giving up compile-time key checks. It is meant for owned child trees: folders where the package owns the children, discovers them at runtime, and wants the analyzer to know the child names.

<p align="center">
  <a href="https://github.com/Kooraseru/TypeManager/wiki"><img alt="Wiki" src="https://shieldcn.dev/badge/Wiki.svg?variant=ghost&logo=lu%3AFlower"></a>
  <a href="https://github.com/Kooraseru/TypeManager/releases"><img alt="Release" src="https://shieldcn.dev/github/Kooraseru/TypeManager/release.svg?variant=ghost"></a>
  <a href="https://github.com/Kooraseru/TypeManager/issues"><img alt="Issues" src="https://shieldcn.dev/github/Kooraseru/TypeManager/issues.svg?variant=ghost"></a>
  <br>
  <a href="https://github.com/Kooraseru/TypeManager"><img alt="Stars" src="https://shieldcn.dev/github/Kooraseru/TypeManager/stars.svg?variant=ghost"></a>
  <a href="CONTRIBUTING.md"><img alt="Contributors" src="https://shieldcn.dev/github/Kooraseru/TypeManager/contributors.svg?variant=ghost"></a>
  <a href="https://github.com/sponsors/Kooraseru"><img alt="Sponsor" src="https://shieldcn.dev/github/sponsors/Kooraseru.svg?variant=ghost"></a>
  <br>
  <a href="CHANGELOG.md"><img alt="Changelog" src="https://shieldcn.dev/badge/Changelog.svg?variant=ghost&logo=ri%3APiTimer"></a>
  <a href="LICENSE"><img alt="License" src="https://shieldcn.dev/github/Kooraseru/TypeManager/license.svg?variant=ghost"></a>
  <img alt="Flag" src="https://shieldcn.dev/flag/kp.svg?variant=ghost">
</p>

## Table Of Contents

- [Status](#status)
- [Install](#install)
- [Quick Start](#quick-start)
- [Public API](#public-api)
- [Concepts](#concepts)
- [What This Proves](#what-this-proves)
- [Runtime Loader Contract](#runtime-loader-contract)
- [Analyzer Requirements](#analyzer-requirements)
- [Package Boundaries](#package-boundaries)
- [Repository Layout](#repository-layout)
- [Release Blockers](#release-blockers)

## Status

Experimental package. The current implementation is being prepared for standalone export.

> [!WARNING]
> Do not treat this package as public-stable until analyzer parity, CI, and export layout are confirmed.

## Install

Copy the `TypeManager` folder into your package area:

```txt
ReplicatedStorage
  Packages
    TypeManager
```

Then require the package root:

```luau
local TypeManager = require(path.To.TypeManager)
```

When used inside a standalone package, internal TypeManager requires use `@self` and focused child modules.

> [!NOTE]
> Package-manager metadata is intentionally not committed yet. First public export should choose the target install story instead of guessing between copy-folder, Wally, pesde, subtree, or another layout.

## Quick Start

Use the root facade when you want fewer require lines:

```luau
local TypeManager = require("../TypeManager")

local LoadModuleMap = TypeManager.RuntimeLoaders.LoadModuleMap

export type ActionId = TypeManager.ChildNames<typeof(script)>
export type ActionMap = TypeManager.ChildRecord<typeof(script), ActionDefinition>

local actions: ActionMap = LoadModuleMap.From(script, validateAction)

return actions
```

Use focused modules when you want the simplest analyzer path:

```luau
local ChildNames = require("../TypeManager/InstanceTree/ChildNames")
local ChildRecord = require("../TypeManager/InstanceTree/ChildRecord")
local LoadModuleMap = require("../TypeManager/RuntimeLoaders/LoadModuleMap")

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
  init.luau
  InstanceTree/
    ChildNames.luau
    ChildRecord.luau
    ChildOf.luau
    ChildrenOfClass.luau
  RuntimeLoaders/
    LoadModuleMap.luau
  PACKAGE.md
  README.md
  CHANGELOG.md
  CONTRIBUTING.md
  LICENSE
  NOTICE
```

## License

Apache License 2.0. See `LICENSE` and `NOTICE`.

## Release Blockers

Before a public release:

```txt
confirm extraction analyzer behavior
add CI that runs Luau analysis and architecture/rule checks
document the supported install layout
decide package manager metadata target, if any
```

See `EXPORT.md` for the repository setup checklist.
