-- Arbor/tools/lune/generate-root-facade.luau
--!strict

local fs = require("@lune/fs")
local process = require("@lune/process")

--# Constants

local requireStart = "-- <arbor-facade-requires>"
local requireEnd = "-- </arbor-facade-requires>"
local publicStart = "-- <arbor-facade-public>"
local publicEnd = "-- </arbor-facade-public>"
local typeStart = "-- <arbor-facade-types>"
local typeEnd = "-- </arbor-facade-types>"
local functionParameters = "function%s*<([^>]+)>%s*%("
local publicExportPattern = "^%s*%-%-%s*arbor%-facade%-export%s+([A-Za-z_][A-Za-z0-9_%.]*)%s*$"
local publicAliasPattern = "^%s*%-%-%s*arbor%-facade%-alias%s+([A-Za-z_][A-Za-z0-9_]*)%s*=%s*([A-Za-z_][A-Za-z0-9_%.]*)%s*$"
local supportRequirePattern = "^%s*%-%-%s*arbor%-facade%-require%s+([A-Za-z_][A-Za-z0-9_]*)%s+\"([^\"]+)\"%s*$"
local luauKeywords = {
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
	requirePath: string,
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

local function splitPublicPath(path: string): { string }
	local out = {}

	for segment in string.gmatch(path, "[^.]+") do
		table.insert(out, segment)
	end

	return out
end

local function isValidIdentifier(value: string): boolean
	return string.match(value, "^[A-Za-z_][A-Za-z0-9_]*$") ~= nil and not luauKeywords[value]
end

local function joinPath(parts: { string }): string
	return table.concat(parts, "/")
end

local function stem(path: string): string
	local name = string.match(path, "([^/]+)$") or path
	return string.gsub(name, "%.luau$", "")
end

local function readDirRecursive(root: string): { string }
	local out = {}

	if not fs.isDir(root) then
		return out
	end

	for _, child in fs.readDir(root) do
		local path = root .. "/" .. child

		if fs.isDir(path) then
			for _, descendant in readDirRecursive(path) do
				table.insert(out, descendant)
			end
		elseif string.sub(path, -5) == ".luau" then
			table.insert(out, path)
		end
	end

	table.sort(out)
	return out
end

local function relativeParts(root: string, path: string): { string }
	local relative = string.sub(path, #root + 2)
	local parts = {}

	for part in string.gmatch(relative, "[^/]+") do
		local cleanPart = string.gsub(part, "%.luau$", "")
		table.insert(parts, cleanPart)
	end

	return parts
end

local function collectFacades(srcRoot: string): { Facade }
	local typeFunctionsRoot = srcRoot .. "/Definitions/TypeFunctions"
	local facades = {}
	local seenNames = {}

	for _, path in readDirRecursive(typeFunctionsRoot) do
		local parts = relativeParts(srcRoot, path)

		if #parts < 4 then
			continue
		end

		local source = fs.readFile(path)
		local parameters = string.match(source, functionParameters)
		local name = stem(path)

		if not parameters then
			continue
		end

		if not isValidIdentifier(name) then
			error(`Cannot generate Arbor facade "{path}": "{name}" is not a valid Luau identifier`)
		end

		if seenNames[name] then
			error(`Cannot generate Arbor facade "{name}": duplicate exported type name`)
		end

		seenNames[name] = true

		table.insert(facades, {
			category = parts[3],
			name = name,
			requirePath = "@self/" .. joinPath(parts),
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

local function collectPublicSurface(srcRoot: string): ({ PublicExport }, { PublicAlias }, { SupportRequire })
	local exports = {}
	local aliases = {}
	local supportRequires = {}
	local seenExports = {}
	local seenAliases = {}
	local seenSupportRequires = {}

	for _, path in readDirRecursive(srcRoot) do
		if string.sub(path, -10) == "/init.luau" then
			continue
		end

		local source = fs.readFile(path)
		local parts = relativeParts(srcRoot, path)

		for line in string.gmatch(source, "([^\n]*)\n?") do
			local exportPath = string.match(line, publicExportPattern)

			if exportPath then
				if seenExports[exportPath] then
					error(`Cannot generate Arbor public facade "{path}": duplicate export {exportPath}`)
				end

				local publicPath = splitPublicPath(exportPath)
				seenExports[exportPath] = true
				table.insert(exports, {
					path = publicPath,
					name = publicPath[#publicPath],
					requirePath = "@self/" .. joinPath(parts),
				})
				continue
			end

			local aliasName, aliasSource = string.match(line, publicAliasPattern)

			if aliasName and aliasSource then
				if seenAliases[aliasName] then
					error(`Cannot generate Arbor public facade "{path}": duplicate alias {aliasName}`)
				end

				seenAliases[aliasName] = true
				table.insert(aliases, {
					name = aliasName,
					source = splitPublicPath(aliasSource),
				})
				continue
			end

			local supportName, supportPath = string.match(line, supportRequirePattern)

			if supportName and supportPath then
				if seenSupportRequires[supportName] then
					error(`Cannot generate Arbor public facade "{path}": duplicate support require {supportName}`)
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

local function buildTypeLine(facade: Facade): string
	local moldArguments = table.clone(facade.parameters)

	if #moldArguments == 1 then
		table.insert(moldArguments, "never")
	elseif #moldArguments ~= 2 then
		error(`FacadeGenerator currently supports one or two type parameters: {facade.name}`)
	end

	return `export type {facade.name}<{table.concat(facade.parameters, ", ")}> = Run.Resolve<Mold.Resolve<typeof({facade.name}), {table.concat(moldArguments, ", ")}>>`
end

local function appendCategory(lines: { string }, current: string?, category: string): string
	if current ~= category then
		if #lines > 0 then
			table.insert(lines, "")
		end

		table.insert(lines, `--# {category}`)
	end

	return category
end

local function buildRequireLines(facades: { Facade }): { string }
	local lines = {}
	local current = nil

	for _, facade in facades do
		current = appendCategory(lines, current, facade.category)
		table.insert(lines, `local {facade.name} = require("{facade.requirePath}")`)
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

local function joinPublicPath(path: { string }, count: number?): string
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
			local prefix = joinPublicPath(export.path, depth)

			if initialized[prefix] then
				continue
			end

			table.insert(lines, "Arbor." .. prefix .. " = {}")
			initialized[prefix] = true
		end

		table.insert(lines, `Arbor.{joinPublicPath(export.path)} = {export.name}`)
	end

	if #aliases > 0 and #lines > 0 then
		table.insert(lines, "")
	end

	for _, alias in aliases do
		table.insert(lines, `Arbor.{alias.name} = Arbor.{joinPublicPath(alias.source)}`)
	end

	return lines
end

local function buildTypeLines(facades: { Facade }): { string }
	local lines = {}
	local current = nil

	for _, facade in facades do
		current = appendCategory(lines, current, facade.category)
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

local function replaceBlock(source: string, startMarker: string, endMarker: string, lines: { string }): string
	local startFirst = string.find(source, startMarker, 1, true)
	local endFirst, endLast = string.find(source, endMarker, 1, true)

	if not startFirst or not endFirst or not endLast or endFirst < startFirst then
		error(`Missing generated block markers: {startMarker} / {endMarker}`)
	end

	local block = table.concat({ startMarker, table.concat(lines, "\n"), endMarker }, "\n")
	return string.sub(source, 1, startFirst - 1) .. block .. string.sub(source, endLast + 1)
end

local function generate(srcRoot: string, check: boolean): number
	local initPath = srcRoot .. "/init.luau"
	local source = fs.readFile(initPath)
	local facades = collectFacades(srcRoot)
	local publicExports, publicAliases, supportRequires = collectPublicSurface(srcRoot)
	local requireLines = buildRequireLines(facades)
	appendPublicRequireLines(requireLines, publicExports, supportRequires)

	local generated = replaceBlock(source, requireStart, requireEnd, requireLines)
	generated = replaceBlock(generated, publicStart, publicEnd, buildPublicLines(publicExports, publicAliases))
	generated = replaceBlock(generated, typeStart, typeEnd, buildTypeLines(facades))

	if check then
		if generated ~= source then
			warn(`{initPath} is stale. Run the Lune root facade generator.`)
			return 1
		end

		return 0
	end

	fs.writeFile(initPath, generated)
	print(`Updated {initPath} with {#facades} facade type function(s).`)

	return 0
end

--# Main

local srcRoot = "src/arbor@1.1.0"
local check = false

for index, argument in process.args do
	if argument == "--src" then
		srcRoot = process.args[index + 1] or srcRoot
	elseif argument == "--check" then
		check = true
	end
end

process.exit(generate(srcRoot, check))
