---
title: Analyzer Fixtures
---

# Analyzer Fixtures

Status: documented fixture contract

The checked examples under `content/en/examples/` are the current analyzer proof fixtures.

They are small on purpose. Each fixture should prove one analyzer-facing claim
without smuggling in unrelated package behavior.

The source-tree content/en/examples are the analyzer proof surface. Exported package
artifacts are checked for package shape, not for Arbor's source-tree type-solving
behavior.

## Fixture Set

| Fixture | Claim |
| --- | --- |
| `direct-children/` | Direct child names, named child lookup, and child-keyed records come from analyzer-visible direct children. |
| `class-filtered-children/` | Class-filtered child tables include analyzer-visible direct children matching the requested class. |
| `runtime-loader/` | Dynamic module loading keeps raw require results at an `unknown` validator boundary. |
| `extracted-package/` | Exported package shape keeps `Arbor` as the public root and excludes content/en/examples. |

## Required Analyzer Checks

The checked-in wrapper validates Arbor's source-tree content/en/examples through the
Packages workspace analyzer setup:

```powershell
powershell -ExecutionPolicy Bypass -File .github/scripts/analyze-luau.ps1
```

Run source-tree analyzer validation with:

```powershell
wsl fish .luau-lsp/analyze.fish src/Shared/Packages/Arbor/src/init.luau src/Shared/Packages/Arbor/content/en/examples/direct-children/init.luau src/Shared/Packages/Arbor/content/en/examples/class-filtered-children/init.luau src/Shared/Packages/Arbor/content/en/examples/runtime-loader/init.luau
```

That command runs from the Packages workspace root and uses the single
workspace-level `.luau-lsp/globalTypes.d.luau` and `.luau-lsp/sourcemap.json`.
Do not create a second global types file in Arbor.

The workspace analyzer lane checks:

```txt
content/en/examples/direct-children/init.luau
content/en/examples/class-filtered-children/init.luau
content/en/examples/runtime-loader/init.luau
src/init.luau
src/InstanceTree/*.luau
src/RuntimeLoaders/*.luau
```

## Manual Negative Checks

These checks are useful for screenshots and toolchain validation, but should not
be committed as failing source:

- assign `"Nope"` to `Arbor.ChildNames<typeof(script)>` in
  `content/en/examples/direct-children/init.luau`
- assign `{}` to `Arbor.ChildrenOfClass<typeof(script), ModuleScript>` in
  `content/en/examples/class-filtered-children/init.luau` and confirm the analyzer reports
  missing `Ban` and `Kick`
- temporarily return a non-string from one runtime-loader child module and
  confirm `validateAction` raises the boundary error

## Current Limitation

Do not replace this with exported-package analyzer validation unless a separate
consuming-workspace sourcemap is intentionally defined later.

Exported-package validation should stay focused on artifact shape unless a
separate consuming-workspace sourcemap is intentionally defined later.
```
