-- Arbor/Plugin/Discovery/ArborDiscovery.luau
--!strict

local ArborDiscovery = {}

--# Services

local ScriptEditorService = game:GetService("ScriptEditorService")

--# Modules

local Profiler = require(script.Parent.Parent.Diagnostics.Profiler)

--# Constants

const arborEntryProtocolVersion = 1
const arborEntrySignaturePattern = "^%s*%-%-%s*@arbor%-entry%s+(.+)$"
const generatedRequirePattern = "^%s*local%s+Arbor%s*=%s*require%s*%((.*)%)%s*$"
const requireStart = "-- <arbor-generated-requires>"
const requireEnd = "-- </arbor-generated-requires>"

--# Variables

local activeInstallation: ArborInstallation? = nil
local cachedCandidates: { EntryCandidate }? = nil
local cachedInstallations: { ArborInstallation }? = nil

--# Types

export type Diagnostic = Profiler.Diagnostic

export type Target = {
	version: string,
	kind: "arbor-root-facade" | "tree-types",
	source: string?,
	requires: "managed" | "detached" | "removed",
	types: "managed" | "detached" | "removed",
}

export type ArborApi = {
	Version: string?,
	EntryProtocolVersion: number?,
	Authoring: {
		TargetMetadata: {
			Parse: (source: string) -> Target?,
		},
		TypeFacadeGenerator: {
			SupportsArborRequireExpression: boolean?,
			GenerateTreeSource: (sourceRoot: Instance, currentSource: string, options: {
				sourceRootExpression: string,
				arborRequireExpression: string?,
				useTargetMetadata: boolean?,
			}) -> {
				source: string,
				changed: boolean,
				diagnostics: { Diagnostic },
			},
		},
	},
}

export type ArborInstallation = {
	Entry: ModuleScript,
	Version: string,
	ProtocolVersion: number,
	Api: ArborApi,
}

type EntryCandidate = {
	Entry: ModuleScript,
	ProtocolVersion: number,
}

--# Helpers

local function requireModule(module: ModuleScript): unknown?
	local ok, value = pcall(require, module)

	if ok then
		return value
	end

	warn(`Arbor plugin could not require {module:GetFullName()}:\n{tostring(value)}`)
	return nil
end

local function requireFreshModule(module: ModuleScript): unknown?
	local ok, clone = pcall(function()
		return module:Clone()
	end)

	if not ok then
		warn(`Arbor plugin could not clone {module:GetFullName()} before require:\n{tostring(clone)}`)
		return nil
	end

	local moduleClone = clone :: ModuleScript
	local value = requireModule(moduleClone)
	moduleClone:Destroy()

	return value
end

local function readModuleSource(module: ModuleScript): string
	local ok, source = pcall(function()
		return ScriptEditorService:GetEditorSource(module)
	end)

	if ok and typeof(source) == "string" then
		return source
	end

	return module.Source
end

local function readEntryProtocolVersion(module: ModuleScript): number?
	local source = readModuleSource(module)
	local lineCount = 0

	for line in string.gmatch(source, "([^\n]*)\n?") do
		lineCount += 1

		if lineCount > 40 then
			return nil
		end

		local attributes = string.match(line, arborEntrySignaturePattern)

		if attributes then
			local protocol = string.match(attributes, "protocol=(%d+)")
			return if protocol then tonumber(protocol) else nil
		end

		if line == "" and lineCount > 1 and string.sub(source, -1) ~= "\n" then
			break
		end
	end

	return nil
end

local function validateArborEntry(entry: ModuleScript, protocolVersion: number): ArborInstallation?
	if protocolVersion ~= arborEntryProtocolVersion then
		warn(`Arbor plugin found {entry:GetFullName()} with unsupported entry protocol {protocolVersion}`)
		return nil
	end

	local value = requireFreshModule(entry)

	if typeof(value) ~= "table" then
		warn(`Arbor plugin could not load Arbor public API from {entry:GetFullName()}`)
		return nil
	end

	local api = value :: ArborApi
	local ok, hasAuthoringContract = pcall(function()
		return api.Authoring.TargetMetadata.Parse
			and api.Authoring.TypeFacadeGenerator.SupportsArborRequireExpression
			and api.Authoring.TypeFacadeGenerator.GenerateTreeSource
			and typeof(api.Authoring.TargetMetadata.Parse) == "function"
			and api.Authoring.TypeFacadeGenerator.SupportsArborRequireExpression == true
			and typeof(api.Authoring.TypeFacadeGenerator.GenerateTreeSource) == "function"
	end)

	if not ok or hasAuthoringContract ~= true then
		warn(`Arbor plugin found signed entry {entry:GetFullName()} but its public authoring contract is invalid`)
		return nil
	end

	return {
		Entry = entry,
		Version = if api.Version then api.Version else "unknown",
		ProtocolVersion = protocolVersion,
		Api = api,
	}
end

local function discoverEntryCandidates(): { EntryCandidate }
	if cachedCandidates then
		return cachedCandidates
	end

	local candidates = {}

	for _, descendant in game:GetDescendants() do
		if descendant:IsA("ModuleScript") and string.sub(descendant.Name, 1, 6) == "arbor@" then
			local protocolVersion = readEntryProtocolVersion(descendant)

			if protocolVersion then
				table.insert(candidates, {
					Entry = descendant,
					ProtocolVersion = protocolVersion,
				})
			end
		end
	end

	cachedCandidates = candidates
	return candidates
end

local function validateCandidates(candidates: { EntryCandidate }): { ArborInstallation }
	if cachedInstallations then
		local isCurrent = true

		for _, installation in cachedInstallations do
			if not installation.Entry.Parent then
				isCurrent = false
				break
			end
		end

		if isCurrent then
			return cachedInstallations
		end

		cachedCandidates = nil
		cachedInstallations = nil
	end

	local installations = {}

	for _, candidate in candidates do
		local installation = validateArborEntry(candidate.Entry, candidate.ProtocolVersion)

		if installation then
			table.insert(installations, installation)
		end
	end

	cachedInstallations = installations
	return installations
end

local function findInstallationForEntry(installations: { ArborInstallation }, entry: ModuleScript): ArborInstallation?
	for _, installation in installations do
		if installation.Entry == entry then
			return installation
		end
	end

	return nil
end

local function isActiveInstallationValid(installations: { ArborInstallation }): boolean
	if not activeInstallation then
		return false
	end

	return findInstallationForEntry(installations, activeInstallation.Entry) ~= nil
end

local function selectInstallation(installations: { ArborInstallation }, preferredEntry: ModuleScript?): ArborInstallation?
	if preferredEntry then
		local preferred = findInstallationForEntry(installations, preferredEntry)

		if preferred then
			return preferred
		end
	end

	if isActiveInstallationValid(installations) then
		return activeInstallation
	end

	if #installations == 1 then
		return installations[1]
	end

	if #installations > 1 then
		Profiler.WarnOnce("multiple-arbor-entries", "Arbor plugin found multiple signed Arbor entries and cannot choose one without an active selection or matching generated require evidence")
		return nil
	end

	Profiler.WarnOnce("missing-arbor-entry", "Arbor plugin could not find a signed Arbor entry ModuleScript")
	return nil
end

local function isValidIdentifier(value: string): boolean
	return string.match(value, "^[A-Za-z_][A-Za-z0-9_]*$") ~= nil
end

local function trim(value: string): string
	local trimmed = string.gsub(value, "^%s*(.-)%s*$", "%1")
	return trimmed
end

local function escapeString(value: string): string
	local escaped = string.gsub(value, "\\", "\\\\")
	escaped = string.gsub(escaped, "\"", "\\\"")
	escaped = string.gsub(escaped, "\n", "\\n")
	escaped = string.gsub(escaped, "\r", "\\r")
	return escaped
end

local function appendPathSegment(expression: string, name: string): string
	if isValidIdentifier(name) then
		return expression .. "." .. name
	end

	return expression .. `["{escapeString(name)}"]`
end

local function findContainingService(instance: Instance): Instance?
	local current: Instance? = instance
	local service: Instance? = nil

	while current and current ~= game do
		service = current
		current = current.Parent
	end

	return if current == game then service else nil
end

local function readQuotedSegment(expression: string, index: number): (string?, number?)
	local quote = string.sub(expression, index, index)

	if quote ~= "\"" and quote ~= "'" then
		return nil, nil
	end

	local out = {}
	local cursor = index + 1

	while cursor <= #expression do
		local character = string.sub(expression, cursor, cursor)

		if character == "\\" then
			local nextCharacter = string.sub(expression, cursor + 1, cursor + 1)
			table.insert(out, nextCharacter)
			cursor += 2
			continue
		end

		if character == quote then
			return table.concat(out), cursor + 1
		end

		table.insert(out, character)
		cursor += 1
	end

	return nil, nil
end

local function resolveSerializedInstancePath(expression: string): Instance?
	local serviceName, cursor = string.match(expression, "^%s*game:GetService%(%s*\"([^\"]+)\"%s*%)(.*)$")

	if not serviceName then
		serviceName, cursor = string.match(expression, "^%s*game:GetService%(%s*'([^']+)'%s*%)(.*)$")
	end

	if not serviceName or not cursor then
		return nil
	end

	local resolvedServiceName = serviceName
	local ok, current = pcall(function()
		return game:GetService(resolvedServiceName)
	end)

	if not ok then
		return nil
	end

	local rest = cursor :: string
	local index = 1

	while index <= #rest do
		local character = string.sub(rest, index, index)

		if string.match(character, "%s") then
			index += 1
			continue
		end

		if character == "." then
			local first, last, name = string.find(rest, "^%.([A-Za-z_][A-Za-z0-9_]*)", index)

			if not first or not last or not name then
				return nil
			end

			current = current:FindFirstChild(name)
			index = last + 1
		elseif character == "[" then
			local quoteIndex = index + 1
			local name, nextIndex = readQuotedSegment(rest, quoteIndex)

			if not name or not nextIndex or string.sub(rest, nextIndex, nextIndex) ~= "]" then
				return nil
			end

			current = current:FindFirstChild(name)
			index = nextIndex + 1
		else
			return nil
		end

		if not current then
			return nil
		end
	end

	return current
end

--# Functions

function ArborDiscovery.GetEditorSource(module: ModuleScript): string
	return readModuleSource(module)
end

function ArborDiscovery.UpdateEditorSource(module: ModuleScript, source: string)
	local ok = pcall(function()
		ScriptEditorService:UpdateSourceAsync(module, function()
			return source
		end)
	end)

	if not ok then
		module.Source = source
	end
end

function ArborDiscovery.GetInstallation(preferredEntry: ModuleScript?): ArborInstallation?
	local installations = validateCandidates(discoverEntryCandidates())
	local selected = selectInstallation(installations, preferredEntry)

	if selected then
		activeInstallation = selected
	end

	return selected
end

function ArborDiscovery.GetInstallations(): { ArborInstallation }
	return validateCandidates(discoverEntryCandidates())
end

function ArborDiscovery.RefreshInstallations()
	cachedCandidates = nil
	cachedInstallations = nil
	activeInstallation = nil
end

function ArborDiscovery.FindInstallationForEntry(installations: { ArborInstallation }, entry: ModuleScript): ArborInstallation?
	return findInstallationForEntry(installations, entry)
end

function ArborDiscovery.IsInsideActiveImplementation(instance: Instance): boolean
	local installation = activeInstallation

	if not installation then
		return false
	end

	return instance == installation.Entry or instance:IsDescendantOf(installation.Entry)
end

function ArborDiscovery.ParseTarget(api: ArborApi, source: string): Target?
	local target = nil
	local ok = pcall(function()
		target = api.Authoring.TargetMetadata.Parse(source)
	end)

	if not ok then
		return nil
	end

	return target
end

function ArborDiscovery.SerializeInstancePath(instance: Instance): string?
	local service = findContainingService(instance)

	if not service then
		return nil
	end

	local segments = {}
	local current: Instance? = instance

	while current and current ~= service do
		table.insert(segments, 1, current.Name)
		current = current.Parent
	end

	local expression = `game:GetService("{escapeString(service.ClassName)}")`

	for _, segment in segments do
		expression = appendPathSegment(expression, segment)
	end

	return expression
end

function ArborDiscovery.ReadGeneratedRequireExpression(source: string): string?
	local startFirst, startLast = string.find(source, requireStart, 1, true)
	local endFirst = string.find(source, requireEnd, 1, true)

	if not startFirst or not startLast or not endFirst or endFirst < startFirst then
		return nil
	end

	local body = string.sub(source, startLast + 1, endFirst - 1)

	for line in string.gmatch(body, "([^\n]*)\n?") do
		local expression = string.match(line, generatedRequirePattern)

		if expression then
			return trim(expression)
		end
	end

	return nil
end

function ArborDiscovery.ResolveGeneratedRequireEntry(source: string, installations: { ArborInstallation }): ModuleScript?
	local expression = ArborDiscovery.ReadGeneratedRequireExpression(source)

	if not expression then
		return nil
	end

	local resolved = resolveSerializedInstancePath(expression)

	if not resolved or not resolved:IsA("ModuleScript") then
		return nil
	end

	return if findInstallationForEntry(installations, resolved) then resolved else nil
end

--# Return

return ArborDiscovery
