-- Arbor/src/arbor@1.1.0/Definitions/Tags/RelationshipChecks/ExternIsDescendantOf.luau
--!strict

return {
	parameters = {
		instance = {
			required = true,
			expects = "extern",
		},
		ancestor = {
			required = true,
			expects = "extern",
		},
	},
	inputState = "none",
	outputState = "PassState",
	semantics = "Passes when instance appears under ancestor through recursive child-like extern properties.",
	reads = { "ancestor:properties()", "child:properties()" },
	produces = { "passed" },
}
