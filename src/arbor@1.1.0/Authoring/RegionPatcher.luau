-- Arbor/src/arbor@1.1.0/Authoring/RegionPatcher.luau
--!strict
-- arbor-facade-export Authoring.RegionPatcher

local RegionPatcher = {}

--# Types

export type Diagnostic = {
	code: string,
	message: string,
	severity: "error" | "warning",
}

export type Result = {
	source: string,
	changed: boolean,
	diagnostics: { Diagnostic },
	fingerprint: string?,
	dependencies: { string }?,
}

export type RegionState = "managed" | "detached" | "removed"

export type Region = {
	name: string,
	startMarker: string,
	endMarker: string,
	state: RegionState?,
	lines: { string },
	expectedFingerprint: string?,
	writeFingerprint: boolean?,
}

--# Helpers

local function buildBlock(startMarker: string, endMarker: string, lines: { string }): string
	local blockLines = { startMarker }

	for _, line in lines do
		table.insert(blockLines, line)
	end

	table.insert(blockLines, endMarker)

	return table.concat(blockLines, "\n")
end

local function buildFingerprintLine(name: string, value: string): string
	return `-- arbor-region-fingerprint: {name} {value}`
end

local function fingerprint(value: string): string
	local hash = 5381

	for index = 1, #value do
		hash = (hash * 33 + string.byte(value, index)) % 4294967296
	end

	return string.format("%08x", hash)
end

local function linesFingerprint(lines: { string }): string
	return fingerprint(table.concat(lines, "\n"))
end

local function findBlock(source: string, startMarker: string, endMarker: string): (number, number, number, number)
	local startFirst, startLast = string.find(source, startMarker, 1, true)
	local endFirst, endLast = string.find(source, endMarker, 1, true)

	if not startFirst or not startLast or not endFirst or not endLast or endFirst < startFirst then
		error(`Missing generated block markers: {startMarker} / {endMarker}`)
	end

	return startFirst, startLast, endFirst, endLast
end

local function readBlock(source: string, startMarker: string, endMarker: string): string
	local startFirst, _, _, endLast = findBlock(source, startMarker, endMarker)
	return string.sub(source, startFirst, endLast)
end

local function readRegionLines(source: string, startMarker: string, endMarker: string): { string }
	local _, startLast, endFirst = findBlock(source, startMarker, endMarker)
	local body = string.sub(source, startLast + 1, endFirst - 1)
	local lines = {}

	for line in string.gmatch(body, "([^\n]*)\n?") do
		if line == "" and #lines == 0 then
			continue
		end

		if line == "" and #lines > 0 and string.sub(body, -1) ~= "\n" then
			break
		end

		if string.match(line, "^%s*%-%-%s*arbor%-region%-fingerprint:") then
			continue
		end

		table.insert(lines, line)
	end

	while #lines > 0 and lines[#lines] == "" do
		table.remove(lines)
	end

	return lines
end

local function readRegionFingerprint(source: string, startMarker: string, endMarker: string, name: string): string?
	local block = readBlock(source, startMarker, endMarker)
	local pattern = "%-%-%s*arbor%-region%-fingerprint:%s*" .. name .. "%s+([%x]+)"
	local value = string.match(block, pattern)
	return value
end

local function buildManagedBlock(region: Region): string
	if not region.writeFingerprint then
		return buildBlock(region.startMarker, region.endMarker, region.lines)
	end

	local lines = table.clone(region.lines)
	table.insert(lines, 1, buildFingerprintLine(region.name, linesFingerprint(region.lines)))

	return buildBlock(region.startMarker, region.endMarker, lines)
end

--# Functions

function RegionPatcher.Fingerprint(value: string): string
	return fingerprint(value)
end

function RegionPatcher.FingerprintBlock(source: string, startMarker: string, endMarker: string): string
	return fingerprint(readBlock(source, startMarker, endMarker))
end

function RegionPatcher.FingerprintLines(lines: { string }): string
	return linesFingerprint(lines)
end

function RegionPatcher.ReplaceBlock(source: string, startMarker: string, endMarker: string, lines: { string }): string
	local startFirst, _, _, endLast = findBlock(source, startMarker, endMarker)

	local before = string.sub(source, 1, startFirst - 1)
	local after = string.sub(source, endLast + 1)

	return before .. buildBlock(startMarker, endMarker, lines) .. after
end

function RegionPatcher.ApplyRegion(source: string, region: Region, diagnostics: { Diagnostic }?): string
	local state = if region.state then region.state else "managed"

	if state == "detached" then
		findBlock(source, region.startMarker, region.endMarker)
		return source
	end

	if state == "removed" then
		local startFirst, _, _, endLast = findBlock(source, region.startMarker, region.endMarker)
		local before = string.sub(source, 1, startFirst - 1)
		local after = string.sub(source, endLast + 1)

		return before .. after
	end

	local expectedFingerprint = region.expectedFingerprint

	if not expectedFingerprint and region.writeFingerprint then
		expectedFingerprint = readRegionFingerprint(source, region.startMarker, region.endMarker, region.name)
	end

	if expectedFingerprint then
		local currentFingerprint = linesFingerprint(readRegionLines(source, region.startMarker, region.endMarker))

		if currentFingerprint ~= expectedFingerprint then
			if diagnostics then
				local diagnostic: Diagnostic = {
					code = "ARBOR_GENERATION_CONFLICT",
					message = `Managed Arbor region "{region.name}" changed since the last generated fingerprint`,
					severity = "error",
				}

				table.insert(diagnostics, diagnostic)
			end

			return source
		end
	end

	local startFirst, _, _, endLast = findBlock(source, region.startMarker, region.endMarker)
	local before = string.sub(source, 1, startFirst - 1)
	local after = string.sub(source, endLast + 1)

	return before .. buildManagedBlock(region) .. after
end

function RegionPatcher.ApplyRegions(source: string, regions: { Region }): string
	local out = source

	for _, region in regions do
		out = RegionPatcher.ApplyRegion(out, region)
	end

	return out
end

function RegionPatcher.Patch(source: string, regions: { Region }): Result
	local out = source
	local diagnostics = {}

	for _, region in regions do
		out = RegionPatcher.ApplyRegion(out, region, diagnostics)
	end

	return {
		source = out,
		changed = out ~= source,
		diagnostics = diagnostics,
		fingerprint = fingerprint(out),
		dependencies = nil,
	}
end

function RegionPatcher.BuildResult(source: string, previousSource: string): Result
	return {
		source = source,
		changed = source ~= previousSource,
		diagnostics = {},
		fingerprint = fingerprint(source),
		dependencies = nil,
	}
end

--# Return

return RegionPatcher
