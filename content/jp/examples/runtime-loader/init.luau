-- Arbor/content/en/examples/runtime-loader/init.luau
--!strict

local Arbor = require("../../../src")

local LoadModuleMap = Arbor.RuntimeLoaders.LoadModuleMap

--# Types

export type ActionDefinition = {
	Run: (playerName: string) -> (),
}

export type ActionMap = Arbor.ChildRecord<typeof(script), ActionDefinition>

--# Helpers

local function validateAction(value: unknown, moduleScript: ModuleScript): ActionDefinition
	if type(value) ~= "string" then
		error(`{moduleScript:GetFullName()} must return an action name`)
	end

	local actionName = value

	return {
		Run = function(playerName: string)
			print(`{actionName} {playerName}`)
		end,
	}
end

--# Variables

local actions: ActionMap = LoadModuleMap.From(script, validateAction)

actions.Kick.Run("Builder")
actions.Ban.Run("Spammer")

--# Return

return actions
