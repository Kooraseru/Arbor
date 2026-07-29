-- Arbor/src/arbor@1.1.0/Authoring/FacadeGenerator.luau
--!strict
-- arbor-facade-export Authoring.FacadeGenerator

local FacadeGenerator = {}

--# Modules

local RegionPatcher = require("./RegionPatcher")

--# Constants

const requireStart = "-- <arbor-facade-requires>"
const requireEnd = "-- </arbor-facade-requires>"
const publicStart = "-- <arbor-facade-public>"
const publicEnd = "-- </arbor-facade-public>"
const typeStart = "-- <arbor-facade-types>"
const typeEnd = "-- </arbor-facade-types>"
const luauKeywords = {
	["and"] = true,
	["break"] = true,
	["do"] = true,
	["else"] = true,
	["elseif"] = true,
	["end"] = true,
	["export"] = true,
	["false"] = true,
	["for"] = true,
	["function"] = true,
	["if"] = true,
	["in"] = true,
	["local"] = true,
	["nil"] = true,
	["not"] = true,
	["or"] = true,
	["repeat"] = true,
	["return"] = true,
	["then"] = true,
	["true"] = true,
	["type"] = true,
	["until"] = true,
	["while"] = true,
}

--# Types

type Facade = {
	category: string,
	name: string,
	path: string,
	parameters: { string },
}

type PublicExport = {
	path: { string },
	name: string,
	requirePath: string,
}

type PublicAlias = {
	name: string,
	source: { string },
}

type SupportRequire = {
	name: string,
	requirePath: string,
}

export type GenerationResult = RegionPatcher.Result

export type GenerateOptions = {
	requiresRegion: RegionPatcher.RegionState?,
	typesRegion: RegionPatcher.RegionState?,
}

--# Helpers

local function trim(value: string): string
	local trimmed = string.gsub(value, "^%s*(.-)%s*$", "%1")
	return trimmed
end

local function splitParameters(parameters: string): { string }
	local out = {}

	for parameter in string.gmatch(parameters, "([^,]+)") do
		table.insert(out, trim(parameter))
	end

	return out
end

local function splitPath(path: string): { string }
	local out = {}

	for segment in string.gmatch(path, "([^.]+)") do
		table.insert(out, segment)
	end

	return out
end

local function readLines(source: string): { string }
	local lines = {}

	for line in string.gmatch(source, "([^\n]*)\n?") do
		if line == "" and #lines > 0 and string.sub(source, -1) ~= "\n" then
			break
		end

		table.insert(lines, line)
	end

	return lines
end

local function isValidIdentifier(value: string): boolean
	return string.match(value, "^[A-Za-z_][A-Za-z0-9_]*$") ~= nil and not luauKeywords[value]
end

local function relativeSegments(root: Instance, descendant: Instance): { string }?
	local segments = {}
	local current: Instance? = descendant

	while current and current ~= root do
		table.insert(segments, 1, current.Name)
		current = current.Parent
	end

	if current ~= root then
		return nil
	end

	return segments
end

local function buildRequirePath(segments: { string }): string
	return "@self/" .. table.concat(segments, "/")
end

local function buildTypeLine(facade: Facade): string
	local moldArguments = table.clone(facade.parameters)

	if #moldArguments == 1 then
		table.insert(moldArguments, "never")
	elseif #moldArguments ~= 2 then
		error(`FacadeGenerator currently supports one or two type parameters: {facade.name}`)
	end

	return `export type {facade.name}<{table.concat(facade.parameters, ", ")}> = Run.Resolve<Mold.Resolve<typeof({facade.name}), {table.concat(moldArguments, ", ")}>>`
end

local function collectFacades(sourceRoot: ModuleScript): { Facade }
	local facades = {}
	local typeFunctionsRoot = sourceRoot:FindFirstChild("Definitions")

	if typeFunctionsRoot then
		typeFunctionsRoot = typeFunctionsRoot:FindFirstChild("TypeFunctions")
	end

	if not typeFunctionsRoot then
		return facades
	end

	local descendants = typeFunctionsRoot:GetDescendants()
	local seenNames = {}
	table.sort(descendants, function(left: Instance, right: Instance)
		return left:GetFullName() < right:GetFullName()
	end)

	for _, descendant in descendants do
		if not descendant:IsA("ModuleScript") then
			continue
		end

		local segments = relativeSegments(sourceRoot, descendant)

		if not segments or #segments < 4 then
			continue
		end

		local parameters = nil

		for _, line in readLines(descendant.Source) do
			parameters = string.match(line, "function%s*<([^>]+)>%s*%(")

			if parameters then
				break
			end
		end

		if not parameters then
			continue
		end

		if not isValidIdentifier(descendant.Name) then
			error(`Cannot generate Arbor facade "{descendant:GetFullName()}": "{descendant.Name}" is not a valid Luau identifier`)
		end

		if seenNames[descendant.Name] then
			error(`Cannot generate Arbor facade "{descendant.Name}": duplicate exported type name`)
		end

		seenNames[descendant.Name] = true

		table.insert(facades, {
			category = segments[3],
			name = descendant.Name,
			path = buildRequirePath(segments),
			parameters = splitParameters(parameters),
		})
	end

	table.sort(facades, function(left: Facade, right: Facade)
		if left.category == right.category then
			return left.name < right.name
		end

		return left.category < right.category
	end)

	return facades
end

local function collectPublicSurface(sourceRoot: ModuleScript): ({ PublicExport }, { PublicAlias }, { SupportRequire })
	local exports = {}
	local aliases = {}
	local supportRequires = {}
	local seenExports = {}
	local seenAliases = {}
	local seenSupportRequires = {}
	local descendants = sourceRoot:GetDescendants()

	table.sort(descendants, function(left: Instance, right: Instance)
		return left:GetFullName() < right:GetFullName()
	end)

	for _, descendant in descendants do
		if not descendant:IsA("ModuleScript") then
			continue
		end

		local segments = relativeSegments(sourceRoot, descendant)

		if not segments then
			continue
		end

		for _, line in readLines(descendant.Source) do
			local exportPath = string.match(line, "^%s*%-%-%s*arbor%-facade%-export%s+([A-Za-z_][A-Za-z0-9_%.]*)%s*$")

			if exportPath then
				if seenExports[exportPath] then
					error(`Cannot generate Arbor public facade "{descendant:GetFullName()}": duplicate export {exportPath}`)
				end

				local path = splitPath(exportPath)
				seenExports[exportPath] = true
				table.insert(exports, {
					path = path,
					name = path[#path],
					requirePath = buildRequirePath(segments),
				})
				continue
			end

			local aliasName, aliasSource = string.match(line, "^%s*%-%-%s*arbor%-facade%-alias%s+([A-Za-z_][A-Za-z0-9_]*)%s*=%s*([A-Za-z_][A-Za-z0-9_%.]*)%s*$")

			if aliasName and aliasSource then
				if seenAliases[aliasName] then
					error(`Cannot generate Arbor public facade "{descendant:GetFullName()}": duplicate alias {aliasName}`)
				end

				seenAliases[aliasName] = true
				table.insert(aliases, {
					name = aliasName,
					source = splitPath(aliasSource),
				})
				continue
			end

			local supportName, supportPath = string.match(line, "^%s*%-%-%s*arbor%-facade%-require%s+([A-Za-z_][A-Za-z0-9_]*)%s+\"([^\"]+)\"%s*$")

			if supportName and supportPath then
				if seenSupportRequires[supportName] then
					error(`Cannot generate Arbor public facade "{descendant:GetFullName()}": duplicate support require {supportName}`)
				end

				seenSupportRequires[supportName] = true
				table.insert(supportRequires, {
					name = supportName,
					requirePath = supportPath,
				})
			end
		end
	end

	table.sort(exports, function(left: PublicExport, right: PublicExport)
		return table.concat(left.path, ".") < table.concat(right.path, ".")
	end)
	table.sort(aliases, function(left: PublicAlias, right: PublicAlias)
		return left.name < right.name
	end)
	table.sort(supportRequires, function(left: SupportRequire, right: SupportRequire)
		return left.name < right.name
	end)

	return exports, aliases, supportRequires
end

local function insertCategoryHeader(lines: { string }, currentCategory: string?, nextCategory: string): string
	if currentCategory ~= nextCategory then
		if #lines > 0 then
			table.insert(lines, "")
		end

		table.insert(lines, `--# {nextCategory}`)
	end

	return nextCategory
end

local function buildRequireLines(facades: { Facade }): { string }
	local lines = {}
	local currentCategory = nil

	for _, facade in facades do
		currentCategory = insertCategoryHeader(lines, currentCategory, facade.category)
		table.insert(lines, `local {facade.name} = require("{facade.path}")`)
	end

	return lines
end

local function appendPublicRequireLines(lines: { string }, exports: { PublicExport }, supportRequires: { SupportRequire })
	if (#exports > 0 or #supportRequires > 0) and #lines > 0 then
		table.insert(lines, "")
	end

	for _, supportRequire in supportRequires do
		table.insert(lines, `local {supportRequire.name} = require("{supportRequire.requirePath}")`)
	end

	for _, export in exports do
		table.insert(lines, `local {export.name} = require("{export.requirePath}")`)
	end
end

local function joinPath(path: { string }, count: number?): string
	local last = count or #path
	local parts = {}

	for index = 1, last do
		table.insert(parts, path[index])
	end

	return table.concat(parts, ".")
end

local function buildPublicLines(exports: { PublicExport }, aliases: { PublicAlias }): { string }
	local lines = {}
	local initialized = {}

	for _, export in exports do
		for depth = 1, #export.path - 1 do
			local prefix = joinPath(export.path, depth)

			if initialized[prefix] then
				continue
			end

			table.insert(lines, "Arbor." .. prefix .. " = {}")
			initialized[prefix] = true
		end

		table.insert(lines, `Arbor.{joinPath(export.path)} = {export.name}`)
	end

	if #aliases > 0 and #lines > 0 then
		table.insert(lines, "")
	end

	for _, alias in aliases do
		table.insert(lines, `Arbor.{alias.name} = Arbor.{joinPath(alias.source)}`)
	end

	return lines
end

local function buildTypeLines(facades: { Facade }): { string }
	local lines = {}
	local currentCategory = nil

	for _, facade in facades do
		currentCategory = insertCategoryHeader(lines, currentCategory, facade.category)
		table.insert(lines, buildTypeLine(facade))

		if facade.name == "Child" then
			table.insert(lines, "export type RequiredChild<Parent, Name> = Child<{ Parent: Parent, Name: Name, Mode: \"required\" }>")
		end
	end

	if #lines > 0 then
		table.insert(lines, "")
	end

	table.insert(lines, "export type Mold<Schema, First, Second> = Mold.Resolve<Schema, First, Second>")
	table.insert(lines, "export type Run<Molded> = Run.Resolve<Molded>")
	table.insert(lines, "export type Resolve1<Definition, First> = Run.Resolve<Mold.Resolve<Definition, First, never>>")
	table.insert(lines, "export type Resolve2<Definition, First, Second> = Run.Resolve<Mold.Resolve<Definition, First, Second>>")

	return lines
end

local function generateSource(sourceRoot: ModuleScript, currentSource: string, options: GenerateOptions?): GenerationResult
	local facades = collectFacades(sourceRoot)
	local publicExports, publicAliases, supportRequires = collectPublicSurface(sourceRoot)
	local requireLines = buildRequireLines(facades)
	local requiresState = if options and options.requiresRegion then options.requiresRegion else "managed"
	local typesState = if options and options.typesRegion then options.typesRegion else "managed"

	appendPublicRequireLines(requireLines, publicExports, supportRequires)

	return RegionPatcher.Patch(currentSource, {
		{
			name = "requires",
			startMarker = requireStart,
			endMarker = requireEnd,
			state = requiresState,
			lines = requireLines,
		},
		{
			name = "public",
			startMarker = publicStart,
			endMarker = publicEnd,
			state = requiresState,
			lines = buildPublicLines(publicExports, publicAliases),
		},
		{
			name = "types",
			startMarker = typeStart,
			endMarker = typeEnd,
			state = typesState,
			lines = buildTypeLines(facades),
		},
	})
end

--# Functions

function FacadeGenerator.GenerateSource(sourceRoot: ModuleScript, currentSource: string, options: GenerateOptions?): GenerationResult
	return generateSource(sourceRoot, currentSource, options)
end

function FacadeGenerator.Generate(sourceRoot: ModuleScript): string
	local result = FacadeGenerator.GenerateSource(sourceRoot, sourceRoot.Source)

	if result.changed then
		sourceRoot.Source = result.source
	end

	return result.source
end

function FacadeGenerator.Preview(sourceRoot: ModuleScript): string
	return FacadeGenerator.GenerateSource(sourceRoot, sourceRoot.Source).source
end

--# Return

return FacadeGenerator
