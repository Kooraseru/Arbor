# Contributing

TypeManager is intentionally small. Changes should preserve the split between compile-time type knowledge and runtime behavior.

> [!IMPORTANT]
> Runtime discovery and compile-time typing are separate concerns. Do not add runtime behavior here just because it helps a local package load modules.

## Local Expectations

- Read `RULES.md` before editing package source.
- Keep type functions focused on analyzer-visible facts.
- Do not add runtime registry, boot, serialization, dispatch, or descriptor behavior here.
- Prefer root exported type aliases for package-facing type surfaces.
- Keep focused modules available when a direct analyzer path is clearer.

## Validation

Run focused validation before proposing a change:

```powershell
wsl fish .luau-lsp/analyze.fish src/init.luau src/InstanceTree/ChildNames.luau src/InstanceTree/ChildRecord.luau src/InstanceTree/ChildOf.luau src/InstanceTree/ChildrenOfClass.luau src/RuntimeLoaders/LoadModuleMap.luau
powershell -ExecutionPolicy Bypass -File tools/rules/run-architecture-validator.ps1 -Root .
```

For repository CI, mirror these checks with paths relative to the package root.

## Design Notes

Runtime discovery does not create static public API by itself. If a caller needs compile-time key checks, use analyzer-visible child-name discovery, generated surfaces, or another explicit typed surface.

> [!CAUTION]
> Do not use `any` or casts to force dynamic loaders through the analyzer. Use `unknown` at the dynamic boundary and validate.
