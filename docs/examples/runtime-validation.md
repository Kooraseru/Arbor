---
title: Runtime Validation
---

# Runtime Validation

## Problem

Typed child discovery can prove names and instance shape, but it does not prove ModuleScript return values.

You need a runtime loader that keeps uncertainty at one validation boundary.

```txt title="Package"
runtime-loader/
  init.luau
  Kick.luau
  Ban.luau
```

## Source

```luau title="init.luau"
--8<-- "examples/runtime-loader/init.luau"
```

```luau title="Kick.luau"
--8<-- "examples/runtime-loader/Kick.luau"
```

```luau title="Ban.luau"
--8<-- "examples/runtime-loader/Ban.luau"
```

## Result

```luau title="Runtime-facing map"
type ActionMap = Arbor.ChildRecord<typeof(script), ActionDefinition>

local actions: ActionMap = LoadModuleMap.From(script, validateAction)
```

The returned table is keyed by direct module names, and each loaded value has passed `validateAction`.

## Why It Works

`LoadModuleMap.From` discovers direct ModuleScript children at runtime, requires each one, and passes each raw result through the validator.

The validator receives `unknown`, not `any`. That keeps dynamic uncertainty at the loader boundary and prevents call sites from casting their way around the type system.

## Playground

```luau title="Validation boundary"
local function validateAction(value: unknown, moduleScript: ModuleScript): ActionDefinition
  -- Check the runtime value here.
end

local actions = LoadModuleMap.From(script, validateAction)
```

Runtime shape is validated by the packaged example.
