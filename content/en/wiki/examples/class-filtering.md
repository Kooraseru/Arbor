---
title: Class Filtering
---

# Class Filtering

## Problem

You own a child tree, but only some direct children should appear in a typed
surface.

```txt title="Package"
class-filtered-children/
  init.luau
  Kick.luau
  Ban.luau
```

For loader-style code, the useful set is often direct children whose
analyzer-visible class is `ModuleScript`.

## Source

```lua title="init.luau"
--8<-- "content/en/examples/class-filtered-children/init.luau"
```

```lua title="Kick.luau"
--8<-- "content/en/examples/class-filtered-children/Kick.luau"
```

```lua title="Ban.luau"
--8<-- "content/en/examples/class-filtered-children/Ban.luau"
```

## Result

When the analyzer sees `Kick` and `Ban` as direct `ModuleScript` children, Arbor
exposes:

```lua title="Analyzer-facing type"
type ModuleChildren = {
  Kick: typeof(script.Kick),
  Ban: typeof(script.Ban),
}
```

Only direct children that match `ModuleScript` appear in the table shape.

## Why It Works

`ChildrenOfClass<typeof(script), ModuleScript>` filters the analyzer-visible
direct child table by Roblox class.

Use it when the value you need is the child instance shape, not only the child
name union.

## What It Does Not Prove

This is analyzer-facing type filtering. It does not run `Instance:IsA()` at
runtime.

It also depends on the analyzer seeing class metadata for the child tree. If the
active toolchain cannot see child classes, Arbor cannot recover them from runtime
state.
