-- Arbor/src/arbor@1.1.0/RuntimeLoaders/LoadModuleMap.luau
--!strict
-- arbor-facade-export RuntimeLoaders.LoadModuleMap
-- arbor-facade-alias LoadModules = RuntimeLoaders.LoadModuleMap.From

local LoadModuleMap = {}

--# Types

export type ModuleValidator<T> = (value: unknown, moduleScript: ModuleScript) -> T

--# Functions

function LoadModuleMap.From<T>(root: Instance, validate: ModuleValidator<T>): { [string]: T }
	local modules = {}
	local seenNames = {}
	local children = root:GetChildren()

	table.sort(children, function(left: Instance, right: Instance)
		return left.Name < right.Name
	end)

	for _, child in children do
		if not child:IsA("ModuleScript") then
			continue
		end

		if seenNames[child.Name] then
			error(`Duplicate ModuleScript "{child.Name}" under {root:GetFullName()}`)
		end

		seenNames[child.Name] = true

		local ok, value = pcall(require, child)

		if not ok then
			error(`Failed to require {child:GetFullName()}: {tostring(value)}`)
		end

		local valid, result = pcall(validate, value, child)

		if not valid then
			error(`Validation failed for {child:GetFullName()}: {tostring(result)}`)
		end

		modules[child.Name] = result
	end

	return modules
end

--# Return

return LoadModuleMap
