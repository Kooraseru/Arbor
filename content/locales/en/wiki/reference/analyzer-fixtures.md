---
title: Analyzer Fixtures
---

# Analyzer Fixtures

Status: documented fixture contract

The checked package source files are the current analyzer proof fixtures.

They are small on purpose. Each fixture should prove one analyzer-facing claim without smuggling in unrelated package behavior.

The source-tree package files are the analyzer proof surface. Exported package artifacts are checked for package shape, not for Arbor's source-tree type-solving behavior.

## Fixture Set

| Fixture | Claim |
| --- | --- |
| `src/arbor@1.1.0/Definitions/TypeFunctions/Children/Names/ChildNames.luau` | Direct child names and child-keyed records come from analyzer-visible direct children. |
| `src/arbor@1.1.0/Definitions/TypeFunctions/Children/Checks/IsChildOf.luau` | Child, ancestor, and descendant relation helpers resolve against analyzer-visible fixture children. |
| `src/plugin/` | Plugin-facing source remains outside the package payload. |
| generated publication payload | Exported package shape keeps `Arbor` as the public root and excludes repository-only source. |

## Required Analyzer Checks

The checked-in wrapper validates Arbor package source through the Packages workspace analyzer setup:

```powershell
powershell -ExecutionPolicy Bypass -File .github/scripts/analyze-luau.ps1
```

Run source-tree analyzer validation with:

```powershell
powershell -ExecutionPolicy Bypass -File .github\scripts\analyze-luau.ps1
```

That command uses Arbor's visible `tools/luau-lsp/` handler, including its settings, generated sourcemap, and Roblox global types.

The focused analyzer lane checks Arbor source such as:

```txt
src/arbor@1.1.0/init.luau
src/arbor@1.1.0/Definitions/TypeFunctions/**/*.luau
src/arbor@1.1.0/RuntimeLoaders/*.luau
```

## Manual Negative Checks

These checks are useful for screenshots and toolchain validation, but should not be committed as failing source:

- assign an impossible name to a `ChildNames` proof and confirm the analyzer rejects it
- assign a non-child type to an `IsChildOf` proof and confirm the analyzer rejects the expectation

## Current Limitation

Exported-package validation should stay focused on artifact shape unless a separate consuming-workspace sourcemap is intentionally defined later.
