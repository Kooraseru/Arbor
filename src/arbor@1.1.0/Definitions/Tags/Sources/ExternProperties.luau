-- Arbor/src/arbor@1.1.0/Definitions/Tags/Sources/ExternProperties.luau
--!strict

return {
	parameters = {
		of = {
			required = true,
			expects = "extern",
		},
	},
	inputState = "none",
	outputState = "PropertyEntrySet",
	semantics = "Produces all properties exposed by the given extern type.",
	reads = { "of:properties()" },
	produces = { "entries.name", "entries.read", "entries.write" },
}
