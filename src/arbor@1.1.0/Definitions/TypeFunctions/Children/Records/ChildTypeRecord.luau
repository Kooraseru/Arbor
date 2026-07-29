-- Arbor/src/arbor@1.1.0/Definitions/TypeFunctions/Children/Records/ChildTypeRecord.luau
--!strict

--# Modules

local Define = require("../../../Define")

--# Return

return Define.TypeFunction(function<Parent>(parent: Parent)
	return Define.Chain({
		ExternChildren = {
			of = parent,
		},
		DropName = {
			name = "Parent",
		},
		KeepExtern = {},
		ToRecord = {
			ReadValue = {},
		},
	})
end)
