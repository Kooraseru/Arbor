---
title: Class Filtering
---

# Class Filtering

## Problem

You want to expose only children whose analyzer-visible Roblox class matches a requested class.

```txt title="Package"
class-filtered-children/
  init.luau
  Kick.luau
  Ban.luau
```

## Source

```luau title="init.luau"
--8<-- "examples/class-filtered-children/init.luau"
```

```luau title="Kick.luau"
--8<-- "examples/class-filtered-children/Kick.luau"
```

```luau title="Ban.luau"
--8<-- "examples/class-filtered-children/Ban.luau"
```

## Result

```luau title="Analyzer-facing type"
type ModuleChildren = {
  Kick: typeof(script.Kick),
  Ban: typeof(script.Ban),
}
```

Only direct children that match `"ModuleScript"` appear in the table shape.

## Why It Works

`ChildrenOfClass<typeof(script), "ModuleScript">` filters the direct child table by analyzer-visible class. Use it when the value you need is the child instance shape, not just the child name union.

`ChildNamesOfClass` exists as an API surface, but class-filtered child tables are currently the clearer documented path because they preserve the child instance types directly.

## Playground

```txt title="Tree"
Package/
  init.luau
  Kick.luau
  Ban.luau
```

```luau title="Type"
type Modules = Arbor.ChildrenOfClass<typeof(script), "ModuleScript">
-- { Kick: typeof(script.Kick), Ban: typeof(script.Ban) }
```

Analyzer verified by the packaged example.
