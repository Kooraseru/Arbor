-- Arbor/src/arbor@1.1.0/Definitions/Tags/ReturnControl/ReturnOnPass.luau
--!strict

return {
	parameters = {
		value = {
			required = true,
			expects = "type",
		},
	},
	inputState = "PassState",
	outputState = "Returned",
	semantics = "Returns the provided value when the current pass state is true; otherwise returns never.",
}
