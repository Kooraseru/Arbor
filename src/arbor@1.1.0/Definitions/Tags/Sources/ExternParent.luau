-- Arbor/src/arbor@1.1.0/Definitions/Tags/Sources/ExternParent.luau
--!strict

return {
	parameters = {
		of = {
			required = true,
			expects = "extern",
		},
	},
	inputState = "none",
	outputState = "TypeValue",
	semantics = "Produces the direct extern parent of the given extern type.",
	reads = { "of:readparent()" },
	produces = { "type" },
}
