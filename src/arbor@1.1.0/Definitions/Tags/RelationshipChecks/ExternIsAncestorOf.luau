-- Arbor/src/arbor@1.1.0/Definitions/Tags/RelationshipChecks/ExternIsAncestorOf.luau
--!strict

return {
	parameters = {
		instance = {
			required = true,
			expects = "extern",
		},
		descendant = {
			required = true,
			expects = "extern",
		},
	},
	inputState = "none",
	outputState = "PassState",
	semantics = "Passes when descendant appears under instance through recursive child-like extern properties.",
	reads = { "instance:properties()", "child:properties()" },
	produces = { "passed" },
}
