-- Arbor/Plugin/init.luau
--!strict

--[[
	Arbor reactive generation plugin source.

	This file is intentionally outside `src/` so Arbor's runtime package does not
	depend on Plugin APIs. Studio validation is still required before treating this
	as release-ready plugin code.
]]

--# Modules

local Toolbar = require(script.Toolbar)
local AutoGeneration = require(script.Generation.AutoGeneration)
local PluginPreferences = require(script.Preferences.PluginPreferences)

--# Initialization

local settings = PluginPreferences.Load()

settings = Toolbar.Initialize(plugin, settings)
AutoGeneration.Start(plugin, settings)
