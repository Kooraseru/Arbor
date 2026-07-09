---
title: Package Extraction
---

# Package Extraction

## Problem

Arbor is usually consumed after the package folder has been extracted into a Roblox-facing package location.

The important question is whether the package keeps the same public root shape after extraction.

## Source

```md title="examples/extracted-package/README.md"
--8<-- "examples/extracted-package/README.md"
```

## Result

```txt title="Exported model"
Arbor
  InstanceTree
    ChildNames
    ChildNamesOfClass
    ChildOf
    ChildRecord
    ChildrenOfClass
  RuntimeLoaders
    LoadModuleMap
```

`src/` is not exported as the root name. The RBXM package root is `ModuleScript Arbor`.

## Why It Works

The exporter treats `src/init.luau` as the root module and uses the package name as the root instance name. Child folders and modules stay underneath that package root.

Examples are intentionally not bundled into the RBXM package. They are repository fixtures with their own analyzer context.
