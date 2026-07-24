-- Arbor/src/arbor@1.1.0/Definitions/TypeFunctions/Descendants/Checks/IsDescendantOf.luau
--!strict

--# Modules

local Define = require("../../../Define")

--# Return

return Define.TypeFunction(function<Descendant, Ancestor>(descendant: Descendant, ancestor: Ancestor)
	return Define.Chain({
		ExternIsDescendantOf = {
			instance = descendant,
			ancestor = ancestor,
		},
		ReturnCheck = {},
	})
end)
