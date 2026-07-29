-- Arbor/src/arbor@1.1.0/Definitions/TypeFunctions/Children/Instances/Child.luau
--!strict

--# Modules

local Define = require("../../../Define")

--# Return

return Define.TypeFunction(function<Args>(args: Args)
	return {
		propertyOf = args,
	}
end)
