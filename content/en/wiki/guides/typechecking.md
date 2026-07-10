---
title: Typechecking
---

# Typechecking

Arbor depends on the active Luau analyzer exposing owned direct children as
literal properties.

If a type does not narrow the way you expect, debug analyzer visibility first.

## Minimal Check

```lua
local valid: Arbor.ChildNames<typeof(script)> = "Kick"
local invalid: Arbor.ChildNames<typeof(script)> = "Nope"
```

The second assignment should fail when the analyzer can see the package tree and
`Nope` is not a direct child.

If it does not fail, the issue is likely analyzer visibility or source-map
configuration, not Arbor runtime behavior.

## Diagnosis Ladder

Check these in order:

1. Is the file being analyzed in the intended workspace?
2. Does the analyzer see the same Roblox tree you expect Studio to see?
3. Does direct property access work, such as `script.Kick`?
4. Is the child a direct child, not a descendant?
5. Is the child under an included root or service?
6. Is your source-map/data-model provider current?
7. Are you testing runtime loading when you meant to test compile-time typing?

## Direct Child Proof

Use a tiny proof before debugging a full package loader:

```lua
export type ActionId = Arbor.ChildNames<typeof(script)>

local kick: ActionId = "Kick"
local nope: ActionId = "Nope"
```

Expected result:

```txt
"Kick" is accepted.
"Nope" is rejected.
```

## Class-Filtered Proof

For class-filtered helpers, confirm that the analyzer sees the child classes:

```lua
export type ModuleChildName = Arbor.ChildNamesOfClass<typeof(script), ModuleScript>
```

If a non-module child appears in the resulting union, or a module child is
missing, the analyzer-visible class metadata is the thing to inspect.

## Runtime Loader Proof

Runtime loader content/en/examples should keep uncertainty at the validator boundary:

```lua
local actions = LoadModuleMap.From(script, validateAction)
```

Do not cast `require` results at the call site. If the validator cannot prove the
shape, fix the validator or the loaded module contract.

## Next

- [Analyzer Model](../analyzer-model.md)
- [Direct Children Example](../examples/direct-children.md)
- [Runtime Validation Example](../examples/runtime-validation.md)
