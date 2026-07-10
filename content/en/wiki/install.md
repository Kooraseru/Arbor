---
title: Install
---

# Install

Place `Arbor` wherever your project or package manager exposes required
modules.

Require the package root through your environment's module reference:

```lua
local Arbor = require(path.to.Arbor)
```

## Package Requirements

Arbor has no required peer package dependencies.

It does not require Registry, Bootstrap, Wally, Pesde, a source-map generator, or
another Arbor package to run.

## Analyzer Visibility Requirements

Arbor's type helpers can only expose children that the active Luau analyzer can
already see.

If the analyzer can see `script.Kick`, Arbor can turn that child into type-level
information:

```lua
export type ActionId = Arbor.ChildNames<typeof(script)>
```

If the analyzer cannot see `script.Kick`, Arbor cannot invent `"Kick"` at the
type level.

## Recommended Tooling

Use `luau-lsp` when you want local editor feedback and reproducible analyzer
checks.

Your analyzer-visible tree can come from different toolchains:

- luau-lsp package or plugin data model
- another source-map or data-model provider that exposes the Roblox tree to Luau

That provider is part of your analyzer setup, not an Arbor runtime dependency.

## Focused Modules

Root facade:

```lua
local Arbor = require(path.to.Arbor)
```

Focused module:

```lua
local ChildNames = require(path.to.Arbor.InstanceTree.ChildNames)
```

Use whichever is clearer for the caller.

## Next

- [Analyzer Model](analyzer-model.md)
- [Typechecking](guides/typechecking.md)
- [Examples](examples.md)
