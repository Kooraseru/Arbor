-- Arbor/src/examples/plugin-sandbox/setup-sandbox.server.luau
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function ensureFolder(parent: Instance, name: string): Folder
	local existing = parent:FindFirstChild(name)

	if existing and existing:IsA("Folder") then
		return existing
	end

	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent

	return folder
end

local function ensureModule(parent: Instance, name: string, source: string): ModuleScript
	local existing = parent:FindFirstChild(name)

	if existing and existing:IsA("ModuleScript") then
		if existing.Source == "" then
			existing.Source = source
		end

		return existing
	end

	local module = Instance.new("ModuleScript")
	module.Name = name
	module.Source = source
	module.Parent = parent

	return module
end

local sandbox = ensureFolder(ReplicatedStorage, "ArborPluginSandbox")
local services = ensureFolder(sandbox, "ServerServices")

for _, name in { "InventoryService", "PlayerService", "DataService" } do
	ensureModule(services, name, "--!strict\n\nreturn {}\n")
end

local generated = ensureFolder(sandbox, "Generated")

ensureModule(generated, "ServiceTypes", [=[--!strict

--[[
@arbor-target version=1

kind = "tree-types"
source = "script.Parent.Parent.ServerServices"

requires = "managed"
types = "managed"
]]

-- <arbor-generated-requires>
-- </arbor-generated-requires>

-- <arbor-generated-types>
-- </arbor-generated-types>

return {}
]=])

print("Created ReplicatedStorage.ArborPluginSandbox")
