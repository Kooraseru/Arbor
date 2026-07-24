-- Arbor/src/arbor@1.1.0/Definitions/Tags/RelationshipChecks/ExternHasReadWriteProperty.luau
--!strict

return {
	parameters = {
		container = {
			required = true,
			expects = "extern",
		},
		read = {
			required = true,
			expects = "type",
		},
		write = {
			required = true,
			expects = "type",
		},
	},
	inputState = "none",
	outputState = "PassState",
	semantics = "Passes when container has a property with matching read and write types.",
	reads = { "container:properties()" },
	produces = { "passed" },
}
