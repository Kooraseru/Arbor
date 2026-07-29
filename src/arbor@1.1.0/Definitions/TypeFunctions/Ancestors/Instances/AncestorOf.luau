-- Arbor/src/arbor@1.1.0/Definitions/TypeFunctions/Ancestors/Instances/AncestorOf.luau
--!strict

--# Modules

local Define = require("../../../Define")

--# Return

return Define.TypeFunction(function<Ancestor, Descendant>(ancestor: Ancestor, descendant: Descendant)
	return Define.Chain({
		ExternIsAncestorOf = {
			instance = ancestor,
			descendant = descendant,
		},
		ReturnOnPass = {
			value = ancestor,
		},
	})
end)
