-- Arbor/src/arbor@1.1.0/Definitions/Tags/Sources/ExternDescendants.luau
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
	semantics = "Produces recursive child-like extern properties under the given extern type.",
	reads = { "of:properties()", "child:properties()" },
	produces = { "entries.name", "entries.read", "entries.write", "entries.depth" },
}
