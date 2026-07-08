-- TypeManager/src/RuntimeLoaders/LoadModuleMap.luau
--!strict

local LoadModuleMap = {}

--# Types

export type ModuleValidator<T> = (value: unknown, moduleScript: ModuleScript) -> T

--# Helpers

local function collectModuleScripts(root: Instance): { ModuleScript }
	local modules = {}

	for _, child in root:GetChildren() do
		if child:IsA("ModuleScript") and child ~= root then
			modules[#modules + 1] = child
		end
	end

	table.sort(modules, function(left: ModuleScript, right: ModuleScript): boolean
		return left.Name < right.Name
	end)

	return modules
end

--# Functions

function LoadModuleMap.From<T>(root: Instance, validate: ModuleValidator<T>): { [string]: T }
	local map = {}
	local modules = collectModuleScripts(root)

	for _, moduleScript in modules do
		local ok, loaded = pcall(require, moduleScript)
		if not ok then
			error(string.format("[TypeManager.RuntimeLoaders.LoadModuleMap] failed to load %s: %s", moduleScript:GetFullName(), tostring(loaded)))
		end

		map[moduleScript.Name] = validate(loaded, moduleScript)
	end

	return map
end

return LoadModuleMap
