---
title: Generated Type Facade
---

# Generated Type Facade

## Problem

You want project-owned generated types that use Arbor's generic operators
without making Arbor own the project service tree.

## Source

```md title="README.md"
--8<-- "src/examples/generated-type-facade/README.md"
```

## Result

The generated facade lives beside the project code it describes, while Arbor
provides the type operators that make the facade useful to Luau.

## Why It Works

Arbor separates generic tree/type operators from user-owned generated source.
The source tree remains the project contract; Arbor supplies reusable type
machinery.
