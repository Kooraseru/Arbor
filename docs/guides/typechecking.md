---
title: Typechecking
---

# Typechecking

Arbor depends on the active Luau analyzer exposing owned direct children as literal properties.

## What To Check

- direct child names are accepted
- unrelated child names are rejected
- class-filtered helpers produce the expected shape
- runtime loader examples keep `unknown` at the validation boundary

## Example Check

```luau
local valid: Arbor.ChildNames<typeof(script)> = "Kick"
local invalid: Arbor.ChildNames<typeof(script)> = "Nope"
```

The second assignment should fail when the analyzer can see the package tree.

If it does not fail, the issue is likely analyzer visibility or sourcemap/source-tree configuration, not Arbor runtime behavior.
