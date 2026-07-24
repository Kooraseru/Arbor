-- Arbor/src/arbor@1.1.0/Definitions/TypeFunctions/Children/Records/ChildrenOfClass.luau
--!strict

--# Modules

local Define = require("../../../Define")

--# Return

return Define.TypeFunction(function<Parent, ClassType>(parent: Parent, classType: ClassType)
	return Define.Chain({
		ExternChildren = {
			of = parent,
		},
		DropName = {
			name = "Parent",
		},
		KeepClass = {
			class = classType,
		},
		ToRecord = {
			ReadValue = {},
		},
	})
end)
