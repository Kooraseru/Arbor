-- Arbor/src/arbor@1.1.0/Definitions/Tags/Filters/DropName.luau
--!strict

return {
	parameters = {
		name = {
			required = true,
			expects = "stringSingleton",
		},
	},
	inputState = "PropertyEntrySet",
	outputState = "PropertyEntrySet",
	semantics = "Drops entries whose name equals the provided singleton string.",
}
