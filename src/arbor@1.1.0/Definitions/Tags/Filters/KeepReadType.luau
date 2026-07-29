-- Arbor/src/arbor@1.1.0/Definitions/Tags/Filters/KeepReadType.luau
--!strict

return {
	parameters = {
		value = {
			required = true,
			expects = "type",
		},
	},
	inputState = "PropertyEntrySet",
	outputState = "PropertyEntrySet",
	semantics = "Keeps entries whose read type equals the provided value.",
}
