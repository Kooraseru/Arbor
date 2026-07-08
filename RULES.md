# Arbor Rules

Canonical: Yes

These rules are intentionally small. Arbor is a standalone Luau package, not a whole game repository.

## Purpose

Arbor is named after the Latin word for tree. It answers one question:

```txt
What static structure does the Luau analyzer know about an owned instance tree?
```

It owns analyzer-facing tree helpers, typed lookup conventions, and tiny validation-friendly loader primitives.

It does not own runtime registries, boot sequencing, serialization, dispatch parsing, descriptor identity, pipeline order, or package lookup.

## Package Shape

- Keep Luau source under `src/`.
- Keep repository metadata, docs, workflows, and wiki drafts at the repository root.
- Keep `src/init.luau` as the root facade.
- Keep focused helpers public under `src/InstanceTree/` and `src/RuntimeLoaders/`.
- Do not add package dependencies unless Arbor cannot perform its core job without them.

## Type Safety

- Do not use `any` in public types, public function parameters, public returns, or loader contracts.
- Do not use `:: any` or `require(...) :: any`.
- Use `unknown` at raw dynamic boundaries, then validate.
- Do not cast dynamic requires through the analyzer.
- If the analyzer cannot interpret a public shape, redesign the type helper or API surface.

## Dynamic Loading

- Dynamic `require` belongs only in explicit runtime loader helpers.
- Runtime loaders must validate loaded values.
- Runtime child discovery proves runtime children exist, not their static public API.
- Typed child-name discovery may prove owned child names when the active analyzer exposes direct children as literal extern properties.
- Typed child-name discovery does not prove ModuleScript return types.

## Luau Style

- Every Luau file starts with a path label and `--!strict`.
- Use relative or package-local requires for local source modules.
- Do not use rooted game aliases such as `@game`, `@Shared`, `@Client`, or `@Server`.
- Use `const` for named policy, identity, limit, default, or shared configuration values.
- Use `camelCase` for ordinary locals and constants.
- Use `PascalCase` for required module bindings, exported types, and public module functions.
- Avoid `table.freeze` by default. Use it only for a deliberate immutability boundary.

## Module Shape

- Use a named module table when the file defines module-level functions or state.
- Return a table literal when the file only composes values or re-exports modules.
- The practical barrier is functions: defining functions means a named module table is usually clearer.

## Docs And Releases

- Keep README focused on install, quick start, and public API.
- Put longer explanations in `wiki/*.md`.
- Do not copy `wiki/README.md` to the GitHub wiki.
- Update `CHANGELOG.md` for package milestones.
- Use version slots as `[core release].[implementation].[bug-fix/patch]`.
- Continuous releases may be generated for every commit, but stable version notes belong in the changelog.
