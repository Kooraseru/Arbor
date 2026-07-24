---
title: Runtime Validation
---

# Runtime Validation

## Problem

Typed child discovery can prove names and instance shape, but it does not prove
ModuleScript return values.

You need a runtime loader that keeps uncertainty at one validation boundary.

```txt title="Package"
runtime-loader/
  init.luau
  Kick.luau
  Ban.luau
```

## Source

```lua title="init.luau"
--8<-- "content/en/examples/runtime-loader/init.luau"
```

```lua title="Kick.luau"
--8<-- "content/en/examples/runtime-loader/Kick.luau"
```

```lua title="Ban.luau"
--8<-- "content/en/examples/runtime-loader/Ban.luau"
```

## Result

The returned table is keyed by direct module names, and each loaded value has
passed `validateAction`.

```lua title="Runtime-facing map"
type ActionMap = Arbor.ChildRecord<typeof(script), ActionDefinition>

local actions: ActionMap = LoadModuleMap.From(script, validateAction)
```

Call sites receive a typed map after validation:

```lua
actions.Kick.Run("Builder")
actions.Ban.Run("Spammer")
```

## Why It Works

`LoadModuleMap.From` discovers direct `ModuleScript` children at runtime,
requires each one, and passes each raw result through the validator.

The validator receives `unknown`, not `any`. That keeps dynamic uncertainty at
the loader boundary and prevents call sites from casting around the type system.

## What It Does Not Prove

This example does not make dynamic `require` statically known.

It also does not prove that every module in a real project returns the right
shape. Your validator owns that runtime contract.
