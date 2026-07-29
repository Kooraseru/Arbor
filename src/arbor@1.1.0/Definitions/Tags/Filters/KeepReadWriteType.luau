-- Arbor/src/arbor@1.1.0/Definitions/Tags/Filters/KeepReadWriteType.luau
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
	semantics = "Keeps entries whose read and write types both equal the provided value.",
}
