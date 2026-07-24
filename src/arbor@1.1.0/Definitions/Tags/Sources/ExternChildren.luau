-- Arbor/src/arbor@1.1.0/Definitions/Tags/Sources/ExternChildren.luau
--!strict

--# Modules

local Define = require("../../Define")

--# Return

return Define.Tag({
	parameters = {
		of = {
			required = true,
			expects = "extern",
		},
	},
	inputState = "none",
	outputState = "PropertyEntrySet",
	semantics = "Produces direct child-like extern properties of the given extern type.",
	reads = { "of:properties()" },
	produces = { "entries.name", "entries.read", "entries.write" },
})
