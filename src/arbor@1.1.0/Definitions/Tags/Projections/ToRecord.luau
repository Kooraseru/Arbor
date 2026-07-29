-- Arbor/src/arbor@1.1.0/Definitions/Tags/Projections/ToRecord.luau
--!strict

return {
	parameters = {
		value = {
			required = false,
			expects = "type",
		},
		valueFrom = {
			required = false,
			expects = "argField",
		},
		ReadValue = {
			required = false,
			expects = "tag",
		},
	},
	inputState = "PropertyEntrySet",
	outputState = "TypeValue",
	semantics = "Projects property entries into a table keyed by entry names.",
	produces = { "record" },
}
