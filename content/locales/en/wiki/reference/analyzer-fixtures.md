---
title: Analyzer Fixtures
---

# Analyzer Fixtures

Status: documented fixture contract

The checked examples under `examples/` are the current analyzer proof fixtures.

They are small on purpose. Each fixture should prove one analyzer-facing claim
without smuggling in unrelated package behavior.

The source-tree `examples/` folder is the analyzer proof surface. Exported package
artifacts are checked for package shape, not for Arbor's source-tree type-solving
behavior.

## Fixture Set

| Fixture | Claim |
| --- | --- |
| `direct-children/` | Direct child names, named child lookup, and child-keyed records come from analyzer-visible direct children. |
| `class-filtered-children/` | Class-filtered child tables include analyzer-visible direct children matching the requested class. |
| `function-types/` | Function parameter and return extraction work for modules that return functions. |
| `extracted-package/` | Exported package shape keeps `Arbor` as the public root and excludes repository example fixtures. |

## Required Analyzer Checks

The checked-in wrapper validates Arbor's source-tree `examples/` through the
Packages workspace analyzer setup:

```powershell
powershell -ExecutionPolicy Bypass -File .github/scripts/analyze-luau.ps1
```

Run source-tree analyzer validation with:

```powershell
powershell -ExecutionPolicy Bypass -File .github\scripts\analyze-luau.ps1
```

That command uses Arbor's visible `tools/luau-lsp/` handler, including its
settings, generated sourcemap, and Roblox global types.

The workspace analyzer lane checks:

```txt
examples/function-types/init.luau
src/examples/serialized-types/IdentifyType.luau
src/examples/serialized-types/CheckRelations.luau
src/init.luau
src/FunctionTypes/*.luau
src/InstanceTree/*.luau
```

## Manual Negative Checks

These checks are useful for screenshots and toolchain validation, but should not
be committed as failing source:

- assign `123` to `Arbor.ParameterOf<typeof(LengthOf)>` in
  `examples/function-types/init.luau`
- assign `"Nope"` to `Arbor.ChildNames<typeof(script)>` in
  `src/examples/serialized-types/IdentifyType.luau`
- assign `{}` to `Arbor.ChildrenOfClass<typeof(script), ModuleScript>` in
  `src/examples/serialized-types/CheckRelations.luau` and confirm the analyzer reports
  missing `Ban` and `Kick`

## Current Limitation

Exported-package validation should stay focused on artifact shape unless a
separate consuming-workspace sourcemap is intentionally defined later.
