-- Arbor/src/arbor@1.1.0/Definitions/Tags/ReturnControl/ErrorOnEmpty.luau
--!strict

return {
	parameters = {
		message = {
			required = true,
			expects = "stringSingleton",
		},
	},
	inputState = "TypeValue",
	outputState = "Returned",
	semantics = "Raises a type-function error when the current result is empty.",
}
