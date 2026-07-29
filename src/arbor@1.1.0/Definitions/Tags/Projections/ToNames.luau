-- Arbor/src/arbor@1.1.0/Definitions/Tags/Projections/ToNames.luau
--!strict

return {
	parameters = {},
	inputState = "PropertyEntrySet",
	outputState = "TypeValue",
	semantics = "Projects property entries into a union of singleton names.",
	produces = { "nameUnion" },
}
