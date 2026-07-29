-- Arbor/src/arbor@1.1.0/Definitions/Tags/ReturnControl/Return.luau
--!strict

return {
	parameters = {
		value = {
			required = true,
			expects = "type",
		},
	},
	inputState = "any",
	outputState = "Returned",
	semantics = "Returns the provided value.",
}
