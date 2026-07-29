-- Arbor/src/arbor@1.1.0/Definitions/Tags/RelationshipChecks/ExternIsDirectChildOf.luau
--!strict

return {
	parameters = {
		instance = {
			required = true,
			expects = "extern",
		},
		parent = {
			required = true,
			expects = "extern",
		},
	},
	inputState = "none",
	outputState = "PassState",
	semantics = "Passes when parent has a property whose read and write types both equal instance.",
	reads = { "parent:properties()" },
	produces = { "passed" },
}
