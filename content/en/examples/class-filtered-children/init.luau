-- Arbor/content/en/examples/class-filtered-children/init.luau
--!strict

local Arbor = require("../../../src")

--# Types

export type ModuleChildren = Arbor.ChildrenOfClass<typeof(script), ModuleScript>

--# Variables

local moduleChildren: ModuleChildren = {
	Kick = script.Kick,
	Ban = script.Ban,
}

--# Return

return {
	moduleChildren = moduleChildren,
}
