-- Arbor/src/arbor@1.1.0/Definitions/TypeFunctions/Descendants/Instances/DescendantOf.luau
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
		ReturnOnPass = {
			value = descendant,
		},
	})
end)
