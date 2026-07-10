---
title: Direct Children
---

# Direct Children

## Problem

You own a module with direct child modules:

```txt title="Package"
direct-children/
  init.luau
  Kick.luau
  Ban.luau
```

Runtime code can discover those children, but package-facing types still need a
static surface. You want Luau to know the available child names without
hand-writing a second manifest.

## Source

```lua title="init.luau"
--8<-- "content/en/examples/direct-children/init.luau"
```

```lua title="Kick.luau"
--8<-- "content/en/examples/direct-children/Kick.luau"
```

```lua title="Ban.luau"
--8<-- "content/en/examples/direct-children/Ban.luau"
```

## Result

When the analyzer sees `Kick` and `Ban` as direct children, Arbor exposes:

```lua title="Analyzer-facing types"
type ActionId = "Kick" | "Ban"
type ActionChildren = {
  Kick: typeof(script.Kick),
  Ban: typeof(script.Ban),
}
```

`"Kick"` and `"Ban"` are accepted as `ActionId`. Unrelated names should be
rejected.

## Why It Works

`ChildNames<typeof(script)>` reads the analyzer-visible direct children of the
current module.

`ChildOf<typeof(script), "Kick">` returns the analyzer-visible type of one named
child.

`ChildRecord<typeof(script), V>` uses the same direct-child names as table keys
and assigns the provided value type to each key.

## What It Does Not Prove

This example proves static tree shape. It does not prove what
`require(script.Kick)` returns at runtime.

If you dynamically load child modules, validate the loaded values at the runtime
boundary.
