-- Arbor/src/arbor@1.1.0/Definitions/Tags/Filters/KeepWriteType.luau
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
	semantics = "Keeps entries whose write type equals the provided value.",
}
