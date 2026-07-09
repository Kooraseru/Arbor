---
title: Examples
---

# Examples

These examples are packaged as repo files under `examples/` so the docs can show the same scripts that the analyzer checks.

## Direct Children

This example proves the names and child table shape of direct ModuleScript children.

Tree:

```txt
direct-children
  init.luau
  Kick.luau
  Ban.luau
```

`init.luau`:

```luau
--8<-- "examples/direct-children/init.luau"
```

`Kick.luau`:

```luau
--8<-- "examples/direct-children/Kick.luau"
```

`Ban.luau`:

```luau
--8<-- "examples/direct-children/Ban.luau"
```

## Class-Filtered Children

This example proves the child table shape after filtering direct children by Roblox class.

Tree:

```txt
class-filtered-children
  init.luau
  Kick.luau
  Ban.luau
```

`init.luau`:

```luau
--8<-- "examples/class-filtered-children/init.luau"
```

`Kick.luau`:

```luau
--8<-- "examples/class-filtered-children/Kick.luau"
```

`Ban.luau`:

```luau
--8<-- "examples/class-filtered-children/Ban.luau"
```

## Runtime Loader

This example keeps the compile-time tree shape separate from runtime module validation.

Tree:

```txt
runtime-loader
  init.luau
  Kick.luau
  Ban.luau
```

`init.luau`:

```luau
--8<-- "examples/runtime-loader/init.luau"
```

`Kick.luau`:

```luau
--8<-- "examples/runtime-loader/Kick.luau"
```

`Ban.luau`:

```luau
--8<-- "examples/runtime-loader/Ban.luau"
```

## Extracted Package

The extracted package example records the workspace shape used when Arbor is consumed from `ReplicatedStorage.Shared.Packages.Arbor`.

```md
--8<-- "examples/extracted-package/README.md"
```
