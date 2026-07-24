-- Arbor/Plugin/Toolbar.luau
--!strict

local Toolbar = {}

--# Services

local ScriptEditorService = game:GetService("ScriptEditorService")
local TestService = game:GetService("TestService")

--# Modules

local PluginPreferences = require(script.Parent.Preferences.PluginPreferences)

--# Constants

const settingsModuleName = "Arbor_Settings"
const autoGenerationOnIcon = "rbxassetid://116319727911709"
const autoGenerationOffIcon = "rbxassetid://135306070656822"
const settingsIcon = "rbxassetid://90235148908494"

--# Types

export type Settings = PluginPreferences.Settings

--# Functions

function Toolbar.Initialize(plugin: Plugin, settings: Settings): Settings
	local currentSettings = table.clone(settings) :: Settings
	local settingsModule: ModuleScript? = nil
	local settingsConnections = {} :: { RBXScriptConnection }
	local toolbar = plugin:CreateToolbar("Arbor")
	local autoButton = toolbar:CreateButton("Auto Generation", "Toggle Arbor automatic generation", autoGenerationOnIcon)
	local settingsButton = toolbar:CreateButton("Settings", "Open Arbor plugin settings", settingsIcon)

	local function disconnectSettingsConnections()
		for _, connection in settingsConnections do
			connection:Disconnect()
		end

		table.clear(settingsConnections)
	end

	local function refreshButtons()
		autoButton:SetActive(currentSettings.automaticGeneration)
		autoButton.Icon = if currentSettings.automaticGeneration then autoGenerationOnIcon else autoGenerationOffIcon
		settingsButton:SetActive(settingsModule ~= nil)
	end

	local function applySettingsSource(source: string)
		currentSettings = PluginPreferences.Parse(source, currentSettings)
		PluginPreferences.Save(plugin, currentSettings)
		refreshButtons()
	end

	local function destroySettingsModule()
		local module = settingsModule
		settingsModule = nil
		disconnectSettingsConnections()
		refreshButtons()

		if module and module.Parent then
			module:Destroy()
		end
	end

	local function openSettingsModule(module: ModuleScript)
		local ok, result = pcall(function()
			return ScriptEditorService:OpenScriptDocumentAsync(module)
		end)

		if not ok then
			warn(`Arbor could not open plugin settings: {result}`)
		end
	end

	autoButton.Click:Connect(function()
		currentSettings.automaticGeneration = not currentSettings.automaticGeneration
		PluginPreferences.Save(plugin, currentSettings)
		refreshButtons()
		warn("Arbor plugin setting changed. Reload the plugin for automatic generation changes to fully apply.")
	end)

	settingsButton.Click:Connect(function()
		if settingsModule and settingsModule.Parent then
			openSettingsModule(settingsModule)
			return
		end

		local existing = TestService:FindFirstChild(settingsModuleName)

		if existing then
			existing:Destroy()
		end

		local module = Instance.new("ModuleScript")
		module.Name = settingsModuleName
		module.Source = PluginPreferences.Format(currentSettings)
		module.Parent = TestService
		settingsModule = module

		table.insert(settingsConnections, ScriptEditorService.TextDocumentDidChange:Connect(function(document: ScriptDocument)
			if document:GetScript() == module then
				applySettingsSource(document:GetText())
			end
		end))

		table.insert(settingsConnections, ScriptEditorService.TextDocumentDidClose:Connect(function(document: ScriptDocument)
			if document:GetScript() == module then
				applySettingsSource(document:GetText())
				destroySettingsModule()
			end
		end))

		refreshButtons()
		openSettingsModule(module)
	end)

	plugin.Unloading:Connect(destroySettingsModule)

	refreshButtons()
	return currentSettings
end

--# Return

return Toolbar
