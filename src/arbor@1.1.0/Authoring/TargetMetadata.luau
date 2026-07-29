-- Arbor/src/arbor@1.1.0/Authoring/TargetMetadata.luau
--!strict
-- arbor-facade-export Authoring.TargetMetadata

local TargetMetadata = {}

--# Constants

const blockStartPattern = "^%s*%-%-%[%[%s*$"
const blockEndPattern = "^%s*%]%]%s*$"
const blockTargetPattern = "^%s*@arbor%-target%s+version=([%w%.%-]+)%s*$"
const oldStartPattern = "^%s*%-%-%s*<arbor%-target%s+version=\"([^\"]+)\">%s*$"
const endPattern = "^%s*%-%-%s*</arbor%-target>%s*$"
const commentFieldPattern = "^%s*%-%-%s*([%w%-_]+)%s*=%s*\"([^\"]*)\"%s*$"
const blockFieldPattern = "^%s*([%w%-_]+)%s*=%s*\"([^\"]*)\"%s*$"

--# Types

export type RegionState = "managed" | "detached" | "removed"

export type TargetKind = "arbor-root-facade" | "tree-types"

export type Target = {
	version: string,
	kind: TargetKind,
	source: string?,
	requires: RegionState,
	types: RegionState,
}

--# Helpers

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

local function parseRegionState(value: string?, fallback: RegionState): RegionState
	if value == nil or value == "" then
		return fallback
	end

	if value == "managed" or value == "detached" or value == "removed" then
		return value
	end

	error(`Unsupported Arbor target region state "{value}"`)
end

local function parseTargetKind(value: string?): TargetKind
	if value == "arbor-root-facade" or value == "tree-types" then
		return value
	end

	error(`Unsupported Arbor target kind "{if value then value else ""}"`)
end

local function buildTarget(version: string?, fields: { [string]: string }): Target
	local kind = parseTargetKind(fields.kind)

	return {
		version = version or "",
		kind = kind,
		source = fields.source,
		requires = parseRegionState(fields.requires, "managed"),
		types = parseRegionState(fields.types, "managed"),
	}
end

local function parseBlockTarget(lines: { string }, startIndex: number): (Target?, number?)
	local targetVersion: string? = nil
	local fields = {}
	local lineIndex = startIndex + 1

	while lineIndex <= #lines do
		local line = lines[lineIndex]

		if string.match(line, blockEndPattern) then
			if targetVersion then
				return buildTarget(targetVersion, fields), lineIndex
			end

			return nil, lineIndex
		end

		if not targetVersion then
			targetVersion = string.match(line, blockTargetPattern)
		else
			local key, value = string.match(line, blockFieldPattern)

			if key and value then
				fields[key] = value
			end
		end

		lineIndex += 1
	end

	if targetVersion then
		error("Unclosed Arbor target metadata block")
	end

	return nil, nil
end

local function parseLineCommentTarget(lines: { string }, startIndex: number, version: string): Target
	local fields = {}

	for lineIndex = startIndex + 1, #lines do
		local line = lines[lineIndex]

		if string.match(line, endPattern) then
			return buildTarget(version, fields)
		end

		local key, value = string.match(line, commentFieldPattern)

		if key and value then
			fields[key] = value
		end
	end

	error("Unclosed Arbor target metadata block")
end

--# Functions

function TargetMetadata.Parse(source: string): Target?
	local lines = readLines(source)

	for lineIndex, line in lines do
		if string.match(line, blockStartPattern) then
			local target = parseBlockTarget(lines, lineIndex)

			if target then
				return target
			end

			continue
		end

		local version = string.match(line, oldStartPattern)

		if version then
			return parseLineCommentTarget(lines, lineIndex, version)
		end
	end

	return nil
end

function TargetMetadata.Require(source: string): Target
	local target = TargetMetadata.Parse(source)

	if not target then
		error("Missing Arbor target metadata block")
	end

	return target
end

--# Return

return TargetMetadata
