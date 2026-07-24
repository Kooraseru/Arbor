-- Arbor/src/arbor@1.1.0/Definitions/Tags/Sources/ExternAncestors.luau
--!strict

return {
	parameters = {
		of = {
			required = true,
			expects = "extern",
		},
	},
	inputState = "none",
	outputState = "TypeSet",
	semantics = "Produces the extern parent chain for the given extern type.",
	reads = { "of:readparent()" },
	produces = { "types" },
}
