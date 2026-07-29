-- Arbor/src/arbor@1.1.0/Definitions/TypeFunctions/Children/Instances/ChildOf.luau
--!strict

--# Modules

local Define = require("../../../Define")

--# Return

return Define.TypeFunction(function<Child, Parent>(child: Child, parent: Parent)
	return Define.Chain({
		ExternIsDirectChildOf = {
			instance = child,
			parent = parent,
		},
		ReturnOnPass = {
			value = child,
		},
	})
end)
