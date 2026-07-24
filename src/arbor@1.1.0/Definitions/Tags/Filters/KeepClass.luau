-- Arbor/src/arbor@1.1.0/Definitions/Tags/Filters/KeepClass.luau
--!strict

return {
	parameters = {
		class = {
			required = true,
			expects = "extern",
		},
	},
	inputState = "PropertyEntrySet",
	outputState = "PropertyEntrySet",
	semantics = "Keeps entries whose read type equals or extends the provided extern class.",
	reads = { "entry.read:readparent()" },
}
