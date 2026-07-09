# Runtime Loader Example

This example proves Arbor's runtime loader boundary:

- `LoadModuleMap.From(script, validateAction)` requires direct ModuleScript children.
- Raw `require` results enter as `unknown`.
- The validator owns the conversion from raw loaded action names to `ActionDefinition`.
- Call sites receive a typed map after validation.

Screenshot targets:

- Explorer tree showing `Kick` and `Ban` as direct child ModuleScripts.
- `init.luau` showing `LoadModuleMap.From` and `validateAction`.
- Runtime output for a successful load.
- Runtime error after temporarily returning a non-string value from one child module.

Do not commit the broken module shape. Capture it only as a validation-boundary screenshot.
