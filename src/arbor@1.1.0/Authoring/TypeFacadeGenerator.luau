-- Arbor/src/arbor@1.1.0/Authoring/TypeFacadeGenerator.luau
--!strict
-- arbor-facade-export Authoring.TypeFacadeGenerator

local TypeFacadeGenerator = {}
TypeFacadeGenerator.SupportsArborRequireExpression = true

--# Modules

local RegionPatcher = require("./RegionPatcher")
local TargetMetadata = require("./TargetMetadata")

--# Constants

const requireStart = "-- <arbor-generated-requires>"
const requireEnd = "-- </arbor-generated-requires>"
const typeStart = "-- <arbor-generated-types>"
const typeEnd = "-- </arbor-generated-types>"

const reservedNames = {
	Children = true,
}

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

export type FromTreeOptions = {
	sourceRootExpression: string,
	arborRequireExpression: string?,
	aliasNamingStyle: "preserve" | "camel" | "pascal" | "snake"?,
	aliasCollisionPolicy: "skip" | "suffix"?,
	includeChildrenRecord: boolean?,
	childrenRecordName: string?,
	requiresRegion: RegionPatcher.RegionState?,
	typesRegion: RegionPatcher.RegionState?,
	useTargetMetadata: boolean?,
	writeFingerprints: boolean?,
}

export type GenerationResult = RegionPatcher.Result

type ChildAlias = {
	name: string,
	childName: string,
}

type ChildAliasResult = {
	aliases: { ChildAlias },
	diagnostics: { RegionPatcher.Diagnostic },
}

--# Helpers

local function isValidIdentifier(value: string): boolean
	return string.match(value, "^[A-Za-z_][A-Za-z0-9_]*$") ~= nil and not luauKeywords[value]
end

local function splitNameWords(value: string): { string }
	local words = {}

	for word in string.gmatch(value, "[A-Za-z0-9]+") do
		table.insert(words, word)
	end

	return words
end

local function upperFirst(value: string): string
	if value == "" then
		return value
	end

	return string.upper(string.sub(value, 1, 1)) .. string.sub(value, 2)
end

local function lowerFirst(value: string): string
	if value == "" then
		return value
	end

	return string.lower(string.sub(value, 1, 1)) .. string.sub(value, 2)
end

local function normalizeWord(word: string): string
	return upperFirst(string.lower(word))
end

local function buildAliasName(childName: string, style: "preserve" | "camel" | "pascal" | "snake"): string?
	if style == "preserve" then
		return childName
	end

	local words = splitNameWords(childName)

	if #words == 0 then
		return nil
	end

	if style == "snake" then
		local out = {}

		for _, word in words do
			table.insert(out, string.lower(word))
		end

		return table.concat(out, "_")
	end

	local out = {}

	for index, word in words do
		local normalized = normalizeWord(word)

		if style == "camel" and index == 1 then
			table.insert(out, lowerFirst(normalized))
		else
			table.insert(out, normalized)
		end
	end

	return table.concat(out, "")
end

local function sortedDirectChildAliasesWithOptions(sourceRoot: Instance, recordName: string, options: FromTreeOptions?): ChildAliasResult
	local aliases = {}
	local diagnostics = {}
	local seenAliases = {}
	local aliasCounts = {}
	local children = sourceRoot:GetChildren()
	local namingStyle = if options and options.aliasNamingStyle then options.aliasNamingStyle else "preserve"
	local collisionPolicy = if options and options.aliasCollisionPolicy then options.aliasCollisionPolicy else "skip"

	table.sort(children, function(left: Instance, right: Instance)
		return left.Name < right.Name
	end)

	for _, child in children do
		local alias = buildAliasName(child.Name, namingStyle)

		if alias then
			aliasCounts[alias] = if aliasCounts[alias] then aliasCounts[alias] + 1 else 1
		end
	end

	for _, child in children do
		local alias = buildAliasName(child.Name, namingStyle)

		if not alias or not isValidIdentifier(alias) then
			table.insert(diagnostics, {
				code = "ARBOR_CHILD_ALIAS_SKIPPED",
				message = `Skipped child "{child:GetFullName()}": could not derive a valid Luau alias from "{child.Name}"`,
				severity = "warning",
			} :: RegionPatcher.Diagnostic)
			continue
		end

		if alias == recordName or reservedNames[alias] then
			table.insert(diagnostics, {
				code = "ARBOR_CHILD_ALIAS_SKIPPED",
				message = `Skipped child "{child:GetFullName()}": alias "{alias}" is reserved`,
				severity = "warning",
			} :: RegionPatcher.Diagnostic)
			continue
		end

		if aliasCounts[alias] > 1 then
			if collisionPolicy == "suffix" then
				local suffix = 2
				local candidate = alias .. tostring(suffix)

				while seenAliases[candidate] or candidate == recordName or reservedNames[candidate] do
					suffix += 1
					candidate = alias .. tostring(suffix)
				end

				table.insert(diagnostics, {
					code = "ARBOR_CHILD_ALIAS_RENAMED",
					message = `Generated alias "{candidate}" for "{child:GetFullName()}" because "{alias}" collided`,
					severity = "warning",
				} :: RegionPatcher.Diagnostic)
				alias = candidate
			else
				if not seenAliases[alias] then
					table.insert(diagnostics, {
						code = "ARBOR_CHILD_ALIAS_SKIPPED",
						message = `Skipped alias "{alias}": multiple children under "{sourceRoot:GetFullName()}" resolve to it`,
						severity = "warning",
					} :: RegionPatcher.Diagnostic)
					seenAliases[alias] = true
				end

				continue
			end
		end

		if seenAliases[alias] then
			continue
		end

		seenAliases[alias] = true
		table.insert(aliases, {
			name = alias,
			childName = child.Name,
		})
	end

	return {
		aliases = aliases,
		diagnostics = diagnostics,
	}
end

local function resolveSourceRootExpression(_sourceRoot: Instance, options: FromTreeOptions?): string
	if options and options.sourceRootExpression then
		return options.sourceRootExpression
	end

	error("TypeFacadeGenerator.FromTree requires options.sourceRootExpression")
end

local function buildRequireLines(options: FromTreeOptions?): { string }
	if not options or not options.arborRequireExpression then
		return {}
	end

	return {
		`local Arbor = require({options.arborRequireExpression})`,
	}
end

local function buildTypeLines(sourceRoot: Instance, options: FromTreeOptions?, diagnostics: { RegionPatcher.Diagnostic }): { string }
	local sourceRootExpression = resolveSourceRootExpression(sourceRoot, options)
	local includeChildrenRecord = if options and options.includeChildrenRecord ~= nil then options.includeChildrenRecord else true
	local recordName = if options and options.childrenRecordName then options.childrenRecordName else "Children"
	local aliasResult = sortedDirectChildAliasesWithOptions(sourceRoot, recordName, options)
	local aliases = aliasResult.aliases
	local lines = {}

	for _, diagnostic in aliasResult.diagnostics do
		table.insert(diagnostics, diagnostic)
	end

	if includeChildrenRecord then
		if not isValidIdentifier(recordName) then
			error(`Cannot generate Arbor children record "{recordName}": name is not a valid Luau identifier`)
		end

		table.insert(lines, "export type " .. recordName .. " = {")

		for _, alias in aliases do
			table.insert(lines, "	" .. alias.name .. ": Arbor.RequiredChild<typeof(" .. sourceRootExpression .. '), "' .. alias.childName .. '">,')
		end

		table.insert(lines, "}")

		if #aliases > 0 then
			table.insert(lines, "")
		end
	end

	for index, alias in aliases do
		table.insert(lines, `export type {alias.name} = Arbor.RequiredChild<typeof({sourceRootExpression}), "{alias.childName}">`)

		if index < #aliases then
			table.insert(lines, "")
		end
	end

	return lines
end

local function generateSource(sourceRoot: Instance, currentSource: string, options: FromTreeOptions?): GenerationResult
	local target = if options and options.useTargetMetadata then TargetMetadata.Require(currentSource) else nil
	local requiresState = if options and options.requiresRegion then options.requiresRegion elseif target then target.requires else "managed"
	local typesState = if options and options.typesRegion then options.typesRegion elseif target then target.types else "managed"
	local writeFingerprints = if options and options.writeFingerprints ~= nil then options.writeFingerprints else target ~= nil
	local diagnostics = {}

	local result = RegionPatcher.Patch(currentSource, {
		{
			name = "requires",
			startMarker = requireStart,
			endMarker = requireEnd,
			state = requiresState,
			lines = buildRequireLines(options),
			writeFingerprint = writeFingerprints,
		},
		{
			name = "types",
			startMarker = typeStart,
			endMarker = typeEnd,
			state = typesState,
			lines = buildTypeLines(sourceRoot, options, diagnostics),
			writeFingerprint = writeFingerprints,
		},
	})

	for _, diagnostic in diagnostics do
		table.insert(result.diagnostics, diagnostic)
	end

	return result
end

local function buildFailureResult(currentSource: string, message: string): GenerationResult
	local result = RegionPatcher.BuildResult(currentSource, currentSource)
	local diagnostic: RegionPatcher.Diagnostic = {
		code = "ARBOR_GENERATION_BLOCKED",
		message = message,
		severity = "warning",
	}

	table.insert(result.diagnostics, diagnostic)

	return result
end

--# Functions

function TypeFacadeGenerator.GenerateTreeSource(sourceRoot: Instance, currentSource: string, options: FromTreeOptions?): GenerationResult
	local ok, result = pcall(function()
		return generateSource(sourceRoot, currentSource, options)
	end)

	if ok then
		return result
	end

	return buildFailureResult(currentSource, tostring(result))
end

function TypeFacadeGenerator.FromTree(sourceRoot: Instance, outputModule: ModuleScript, options: FromTreeOptions?): string
	local result = TypeFacadeGenerator.GenerateTreeSource(sourceRoot, outputModule.Source, options)

	if result.changed then
		outputModule.Source = result.source
	end

	return result.source
end

function TypeFacadeGenerator.PreviewTree(sourceRoot: Instance, outputModule: ModuleScript, options: FromTreeOptions?): string
	return TypeFacadeGenerator.GenerateTreeSource(sourceRoot, outputModule.Source, options).source
end

--# Return

return TypeFacadeGenerator
