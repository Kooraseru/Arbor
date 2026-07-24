-- Arbor/src/examples/plugin-sandbox/ServiceTypes.luau
--!strict

--[[
@arbor-target version=1

kind = "tree-types"
source = "script.Parent.ServerServices"

requires = "managed"
types = "managed"
]]

-- <arbor-generated-requires>
-- arbor-region-fingerprint: requires 6ce11109
local Arbor = require(game:GetService("ReplicatedStorage").Shared.Packages.Arbor.src["arbor@1.1.0"])
-- </arbor-generated-requires>

-- <arbor-generated-types>
-- arbor-region-fingerprint: types 150e1601
export type Children = {
	dataservice: Arbor.RequiredChild<typeof(script.Parent.ServerServices), "DataService">,
	inventoryservice: Arbor.RequiredChild<typeof(script.Parent.ServerServices), "InventoryService">,
	playerservice: Arbor.RequiredChild<typeof(script.Parent.ServerServices), "PlayerService">,
}

export type dataservice = Arbor.RequiredChild<typeof(script.Parent.ServerServices), "DataService">

export type inventoryservice = Arbor.RequiredChild<typeof(script.Parent.ServerServices), "InventoryService">

export type playerservice = Arbor.RequiredChild<typeof(script.Parent.ServerServices), "PlayerService">
-- </arbor-generated-types>

return {}
