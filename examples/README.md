# Arbor Examples

These examples are the source material for Arbor proof screenshots and docs references.

They are intentionally small. Open them in a workspace using the new Luau type solver, inspect the analyzer behavior, then capture screenshots from the actual example files instead of making one-off snippets.

Reference flow:

```txt
Code example
-> example details and explanation markdown
-> docs source
-> footnote manager/assigner
-> final exported docs
```

Do not hand-link these examples into final docs before export. The export pipeline owns stable footnotes and final reference ids.

## Examples

- `direct-children/` proves direct child names, direct child lookup, and child-keyed records.
- `class-filtered-children/` proves class-filtered direct child helpers.
- `runtime-loader/` proves dynamic ModuleScript loading with explicit validation.
- `extracted-package/` shows how the same examples should be checked when Arbor is consumed as an extracted package.
