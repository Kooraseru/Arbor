# Direct Children Example

This example proves Arbor's baseline shared behavior:

- `ChildNames<typeof(script)>` extracts direct child names.
- `ChildOf<typeof(script), "Kick">` returns the analyzer-visible child instance type.
- `ChildRecord<typeof(script), ActionDefinition>` creates a table shape keyed by direct child names.

Screenshot targets:

- Explorer tree showing `direct-children` with `Kick` and `Ban` as direct child ModuleScripts.
- `init.luau` showing the exported Arbor types.
- Analyzer accepting `"Kick"` and `"Ban"` as `ActionId`.
- Analyzer rejecting an unrelated name if temporarily tested in the workspace.

Do not commit the intentionally rejected test line. Capture it as a screenshot only.
