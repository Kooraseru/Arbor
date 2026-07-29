-- Arbor/Plugin/Preferences/PluginPreferences.luau
--!strict

local PluginPreferences = {}

--# Constants

const automaticGenerationKey = "automaticGeneration"
const generateOnOpenKey = "generateOnOpen"
const debounceSecondsKey = "debounceSeconds"
const logLevelKey = "logLevel"
const directiveStyleKey = "directiveStyle"
const aliasNamingStyleKey = "aliasNamingStyle"
const aliasCollisionPolicyKey = "aliasCollisionPolicy"
const settingsTemplate = [=[
-- Arbor plugin settings
-- This ModuleScript is temporary editor UI. Arbor saves these as user plugin settings.
-- Closing the tab removes this script from TestService.
--!strict

return {
	automaticGeneration = %s,
	generateOnOpen = %s,
	debounceSeconds = %s,
	logLevel = "%s",

	directiveStyle = "%s",
	aliasNamingStyle = "%s",
	aliasCollisionPolicy = "%s",
}
]=]
const defaultSettings = {
	automaticGeneration = true,
	generateOnOpen = true,
	debounceSeconds = 0.5,
	logLevel = "WARN",
	directiveStyle = "block",
	aliasNamingStyle = "camel",
	aliasCollisionPolicy = "skip",
}

--# Types

export type Settings = {
	automaticGeneration: boolean,
	generateOnOpen: boolean,
	debounceSeconds: number,
	logLevel: "ERROR" | "WARN" | "INFO",
	directiveStyle: "block" | "legacy",
	aliasNamingStyle: "preserve" | "camel" | "pascal" | "snake",
	aliasCollisionPolicy: "skip" | "suffix",
}

--# Helpers

local function readBoolean(plugin: Plugin?, key: string, fallback: boolean): boolean
	if not plugin then
		return fallback
	end

	local value = plugin:GetSetting(key)
	return if typeof(value) == "boolean" then value else fallback
end

local function readNumber(plugin: Plugin?, key: string, fallback: number): number
	if not plugin then
		return fallback
	end

	local value = plugin:GetSetting(key)
	return if typeof(value) == "number" then value else fallback
end

local function readLogLevel(plugin: Plugin?, key: string, fallback: "ERROR" | "WARN" | "INFO"): "ERROR" | "WARN" | "INFO"
	if not plugin then
		return fallback
	end

	local value = plugin:GetSetting(key)

	if value == "ERROR" or value == "WARN" or value == "INFO" then
		return value
	end

	return fallback
end

local function readDirectiveStyle(plugin: Plugin?, key: string, fallback: "block" | "legacy"): "block" | "legacy"
	if not plugin then
		return fallback
	end

	local value = plugin:GetSetting(key)

	if value == "block" or value == "legacy" then
		return value
	end

	return fallback
end

local function readAliasNamingStyle(plugin: Plugin?, key: string, fallback: "preserve" | "camel" | "pascal" | "snake"): "preserve" | "camel" | "pascal" | "snake"
	if not plugin then
		return fallback
	end

	local value = plugin:GetSetting(key)

	if value == "preserve" or value == "camel" or value == "pascal" or value == "snake" then
		return value
	end

	return fallback
end

local function readAliasCollisionPolicy(plugin: Plugin?, key: string, fallback: "skip" | "suffix"): "skip" | "suffix"
	if not plugin then
		return fallback
	end

	local value = plugin:GetSetting(key)

	if value == "skip" or value == "suffix" then
		return value
	end

	return fallback
end

local function findBoolean(source: string, key: string, fallback: boolean): boolean
	local rawValue = source:match(key .. "%s*=%s*(%a+)")

	if rawValue == "true" then
		return true
	elseif rawValue == "false" then
		return false
	end

	return fallback
end

local function findNumber(source: string, key: string, fallback: number): number
	local rawValue = source:match(key .. "%s*=%s*([%d%.]+)")

	if not rawValue then
		return fallback
	end

	local value = tonumber(rawValue)

	if not value or value < 0 then
		return fallback
	end

	return value
end

local function findLogLevel(source: string, key: string, fallback: "ERROR" | "WARN" | "INFO"): "ERROR" | "WARN" | "INFO"
	local value = source:match(key .. "%s*=%s*\"([^\"]+)\"")

	if value == "ERROR" or value == "WARN" or value == "INFO" then
		return value
	end

	return fallback
end

local function findDirectiveStyle(source: string, key: string, fallback: "block" | "legacy"): "block" | "legacy"
	local value = source:match(key .. "%s*=%s*\"([^\"]+)\"")

	if value == "block" or value == "legacy" then
		return value
	end

	return fallback
end

local function findAliasNamingStyle(source: string, key: string, fallback: "preserve" | "camel" | "pascal" | "snake"): "preserve" | "camel" | "pascal" | "snake"
	local value = source:match(key .. "%s*=%s*\"([^\"]+)\"")

	if value == "preserve" or value == "camel" or value == "pascal" or value == "snake" then
		return value
	end

	return fallback
end

local function findAliasCollisionPolicy(source: string, key: string, fallback: "skip" | "suffix"): "skip" | "suffix"
	local value = source:match(key .. "%s*=%s*\"([^\"]+)\"")

	if value == "skip" or value == "suffix" then
		return value
	end

	return fallback
end

--# Functions

function PluginPreferences.Load(plugin: Plugin?): Settings
	return {
		automaticGeneration = readBoolean(plugin, automaticGenerationKey, defaultSettings.automaticGeneration),
		generateOnOpen = readBoolean(plugin, generateOnOpenKey, defaultSettings.generateOnOpen),
		debounceSeconds = readNumber(plugin, debounceSecondsKey, defaultSettings.debounceSeconds),
		logLevel = readLogLevel(plugin, logLevelKey, defaultSettings.logLevel),
		directiveStyle = readDirectiveStyle(plugin, directiveStyleKey, defaultSettings.directiveStyle),
		aliasNamingStyle = readAliasNamingStyle(plugin, aliasNamingStyleKey, defaultSettings.aliasNamingStyle),
		aliasCollisionPolicy = readAliasCollisionPolicy(plugin, aliasCollisionPolicyKey, defaultSettings.aliasCollisionPolicy),
	}
end

function PluginPreferences.Save(plugin: Plugin, settings: Settings)
	plugin:SetSetting(automaticGenerationKey, settings.automaticGeneration)
	plugin:SetSetting(generateOnOpenKey, settings.generateOnOpen)
	plugin:SetSetting(debounceSecondsKey, settings.debounceSeconds)
	plugin:SetSetting(logLevelKey, settings.logLevel)
	plugin:SetSetting(directiveStyleKey, settings.directiveStyle)
	plugin:SetSetting(aliasNamingStyleKey, settings.aliasNamingStyle)
	plugin:SetSetting(aliasCollisionPolicyKey, settings.aliasCollisionPolicy)
end

function PluginPreferences.Format(settings: Settings): string
	return settingsTemplate:format(
		tostring(settings.automaticGeneration),
		tostring(settings.generateOnOpen),
		tostring(settings.debounceSeconds),
		settings.logLevel,
		settings.directiveStyle,
		settings.aliasNamingStyle,
		settings.aliasCollisionPolicy
	)
end

function PluginPreferences.Parse(source: string, fallback: Settings): Settings
	return {
		automaticGeneration = findBoolean(source, automaticGenerationKey, fallback.automaticGeneration),
		generateOnOpen = findBoolean(source, generateOnOpenKey, fallback.generateOnOpen),
		debounceSeconds = findNumber(source, debounceSecondsKey, fallback.debounceSeconds),
		logLevel = findLogLevel(source, logLevelKey, fallback.logLevel),
		directiveStyle = findDirectiveStyle(source, directiveStyleKey, fallback.directiveStyle),
		aliasNamingStyle = findAliasNamingStyle(source, aliasNamingStyleKey, fallback.aliasNamingStyle),
		aliasCollisionPolicy = findAliasCollisionPolicy(source, aliasCollisionPolicyKey, fallback.aliasCollisionPolicy),
	}
end

--# Return

return PluginPreferences
