-- Arbor/src/arbor@1.1.0/Definitions/TypeFunctions/Children/Records/ChildRecord.luau
--!strict

--# Modules

local Define = require("../../../Define")

--# Return

return Define.TypeFunction(function<Parent, Value>(parent: Parent, value: Value)
	return Define.Chain({
		ExternChildren = {
			of = parent,
		},
		DropName = {
			name = "Parent",
		},
		KeepExtern = {},
		ToRecord = {
			value = value,
		},
	})
end)
