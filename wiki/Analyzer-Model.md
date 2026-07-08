# Analyzer Model

Arbor relies on analyzer-visible Roblox/host extern metadata.

The important bit:

```txt
direct children can appear as literal properties on an Instance type
```

If the analyzer sees a folder with children:

```txt
Origin
  DefaultModule1
  DefaultModule2
```

Then:

```luau
export type Names = Arbor.ChildNames<typeof(workspace.Origin)>
```

can become:

```txt
"DefaultModule1" | "DefaultModule2"
```

## What It Does Not Know

The analyzer-visible child metadata proves:

```txt
the child name exists
the child instance shape exists
```

It does not prove:

```txt
what require(childModule) returns
whether the module follows your runtime contract
whether a dynamic loader should be part of a public API
```

> [!CAUTION]
> Do not use `any` or casts to force module return types through the analyzer. Validate dynamic requires at the loader boundary.

## Extraction Caveat

Child metadata may depend on sourcemap/toolchain behavior.

Before publishing a package that relies on Arbor:

```txt
test VS Code/Luau LSP
test CLI/external analyzer
test extracted package layout
test package-manager layout if any
```
