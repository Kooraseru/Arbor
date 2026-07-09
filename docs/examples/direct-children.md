---
title: Direct Children
---

# Direct Children

## Problem

You have a package-like module with direct child modules:

```txt title="Package"
direct-children/
  init.luau
  Kick.luau
  Ban.luau
```

You want the analyzer to know the available child names and child table shape without hand-writing a second manifest.

## Source

```luau title="init.luau"
--8<-- "examples/direct-children/init.luau"
```

```luau title="Kick.luau"
--8<-- "examples/direct-children/Kick.luau"
```

```luau title="Ban.luau"
--8<-- "examples/direct-children/Ban.luau"
```

## Result

```luau title="Analyzer-facing types"
type ActionId = "Kick" | "Ban"
type ActionChildren = {
  Kick: typeof(script.Kick),
  Ban: typeof(script.Ban),
}
```

`Kick` and `Ban` are accepted. Unrelated names are rejected.

## Why It Works

`ChildNames<typeof(script)>` reads the analyzer-visible direct children of the current module. `ChildRecord<typeof(script), V>` uses those same names as table keys and assigns the provided value type to each key.

This proves the static tree shape. It does not prove what `require(script.Kick)` returns at runtime.

## Playground

```txt title="Tree"
Package/
  init.luau
  Kick.luau
  Ban.luau
```

```luau title="Type"
type Names = Arbor.ChildNames<typeof(script)>
-- "Kick" | "Ban"
```

Analyzer verified by the packaged example.
