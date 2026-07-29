-- Arbor/src/arbor@1.1.0/Definitions/Tags/Projections/ToReadTypes.luau
--!strict

return {
	parameters = {},
	inputState = "PropertyEntrySet",
	outputState = "TypeValue",
	semantics = "Projects property entries into a union of read types.",
	produces = { "readTypeUnion" },
}
