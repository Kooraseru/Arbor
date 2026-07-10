# Class Filtered Children Example

This example proves Arbor's class-filtered direct child behavior:

- `ChildrenOfClass<typeof(script), ModuleScript>` returns a table shape of matching direct child instances.

Screenshot targets:

- Explorer tree showing ModuleScript children plus at least one non-ModuleScript direct child in the workspace.
- `init.luau` showing `ModuleChildren`.
- Analyzer accepting `Kick` and `Ban` as class-filtered child instance keys.
- Analyzer rejecting a non-ModuleScript child key if temporarily tested in the workspace.

The checked-in filesystem version includes ModuleScript children. For the rejection screenshot, add a temporary non-ModuleScript child in Studio or the workspace view, capture the analyzer result, then discard that local test object.
