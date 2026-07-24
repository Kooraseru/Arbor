---
title: Package Extraction
---

# Package Extraction

## Problem

Arbor is usually consumed after the package folder has been exported or copied
into a Roblox-facing package location.

The important question is whether the package keeps the same public root shape
after extraction.

## Source

```md title="content/en/examples/extracted-package/README.md"
--8<-- "content/en/examples/extracted-package/README.md"
```

## Result

The exported package root is a `ModuleScript` named `Arbor`:

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

Consumers require Arbor from the package root:

```lua
local Arbor = require(path.to.Arbor)
```

## Why It Works

The exporter treats `src/init.luau` as the root module and uses the package name
as the root instance name. Child folders and modules stay underneath that package
root.

`src/` is a repository source folder. It should not appear as the package root
after export.

## What It Does Not Prove

Package extraction does not prove analyzer visibility by itself.

The consuming workspace still needs a source-map, plugin model, or other
analyzer-visible data model that exposes the extracted package tree to Luau.

Examples are intentionally not bundled into the RBXM package. They are
repository fixtures with their own analyzer context.
