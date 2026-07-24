-- Arbor/src/arbor@1.1.0/Definitions/Tags/Projections/ToUnion.luau
--!strict

return {
	parameters = {},
	inputState = "TypeSet",
	outputState = "TypeValue",
	semantics = "Projects the current selected type set into a union.",
	produces = { "typeUnion" },
}
