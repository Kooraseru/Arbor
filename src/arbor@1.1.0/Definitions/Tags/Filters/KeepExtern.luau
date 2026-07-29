-- Arbor/src/arbor@1.1.0/Definitions/Tags/Filters/KeepExtern.luau
--!strict

return {
	parameters = {},
	inputState = "PropertyEntrySet",
	outputState = "PropertyEntrySet",
	semantics = "Keeps entries whose read and write types are both externs.",
}
