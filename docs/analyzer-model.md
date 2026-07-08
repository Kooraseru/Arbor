---
title: Analyzer Model
---

# Analyzer Model

Arbor relies on analyzer-visible Roblox or host extern metadata.

When the analyzer sees direct children as literal properties, Arbor can extract those child names with type functions.

## What Works

Given an owned tree:

```txt
Origin
  DefaultModule1
  DefaultModule2
```

Call:

```luau
export type Names = Arbor.ChildNames<typeof(workspace.Origin)>
```

Expected result:

```luau
type Names = "DefaultModule1" | "DefaultModule2"
```

## What This Does Not Prove

Child-name discovery proves names and instance-tree shape.

It does not prove:

```txt
what require(childModule) returns
whether runtime discovery found every expected module
whether CLI, Studio, and LSP analyzers expose identical metadata
```

Validate runtime-loaded values at the loader boundary.

