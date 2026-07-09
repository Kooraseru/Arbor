-- Arbor/examples/direct-children/init.luau
--!strict

local Arbor = require("../src")

--# Types

export type ActionDefinition = {
	Run: (playerName: string) -> (),
}

export type ActionId = Arbor.ChildNames<typeof(script)>
export type KickModule = Arbor.ChildOf<typeof(script), "Kick">
export type ActionRecord = Arbor.ChildRecord<typeof(script), ActionDefinition>

--# Variables

local kickId: ActionId = "Kick"
local banId: ActionId = "Ban"

local actions: ActionRecord = {
	Kick = require(script.Kick),
	Ban = require(script.Ban),
}

--# Return

return {
	kickId = kickId,
	banId = banId,
	actions = actions,
}
