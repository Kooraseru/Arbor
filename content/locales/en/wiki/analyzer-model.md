---
title: Analyzer Model
---

# Analyzer Model

Arbor can only expose what Luau already sees.

That is the whole model. Runtime discovery and compile-time typing are separate
concerns.

## The Rule

When the analyzer sees direct children as literal properties, Arbor can extract
those child names with type functions.

Given an owned tree:

```txt
Actions
  Kick
  Ban
```

This type:

```lua
export type ActionId = Arbor.ChildNames<typeof(script)>
```

can become:

```lua
type ActionId = "Kick" | "Ban"
```

But only if the analyzer sees `script.Kick` and `script.Ban` from the file being
checked.

## What Arbor Proves

Arbor proves analyzer-visible shape:

```txt
direct child names
direct child lookup
class-filtered child names
class-filtered child records
```

## What Arbor Does Not Prove

Arbor does not prove:

```txt
what require(childModule) returns
whether runtime discovery found every expected module
whether CLI, Studio, and LSP analyzers expose identical metadata
```

Validate runtime-loaded values at the loader boundary.

## Runtime Loading Is Separate

This is compile-time shape:

```lua
export type ActionId = Arbor.ChildNames<typeof(script)>
```

This is runtime behavior:

```lua
local actions = LoadModuleMap.From(script, validateAction)
```

The runtime loader still calls `require` dynamically. Arbor keeps that dynamic
value as `unknown` until your validator accepts it.

## Toolchain Notes

`luau-lsp` is recommended for development validation because it can show whether
the active analyzer sees the tree you expect.

A source-map or data-model provider can help the analyzer see Roblox instance
hierarchies. That provider belongs to your analyzer setup, not Arbor's runtime
package.

## Next

- [Typechecking](guides/typechecking.md)
- [Runtime Loading](runtime-loaders.md)
- [Examples](examples.md)
