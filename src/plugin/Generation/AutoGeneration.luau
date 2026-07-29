-- Arbor/Plugin/Generation/AutoGeneration.luau
--!strict

local AutoGeneration = {}

--# Modules

local ArborDiscovery = require(script.Parent.Parent.Discovery.ArborDiscovery)
local PluginPreferences = require(script.Parent.Parent.Preferences.PluginPreferences)
local Profiler = require(script.Parent.Parent.Diagnostics.Profiler)

--# Constants

local defaultTargetRoots = {
	game:GetService("ReplicatedStorage"),
	game:GetService("ServerScriptService"),
	game:GetService("StarterPlayer"),
}

--# Variables

local pendingTargets: { [ModuleScript]: boolean } = {}
local pendingScans: { [Instance]: boolean } = {}
local flushing = false
local scanning = false
local pluginHandle: Plugin? = nil
local activeInstallation: ArborDiscovery.ArborInstallation? = nil
local entryConnections: { RBXScriptConnection } = {}
local sourceConnections: { [ModuleScript]: { RBXScriptConnection } } = {}
local lastDiagnosticMessages: { [ModuleScript]: string } = {}
local lastEntryRequireExpression: string? = nil
local reconcilingEntryPath = false
local queueTarget: ((ModuleScript, number) -> ())? = nil

--# Helpers

local function resolveSimplePath(from: Instance, path: string): Instance?
	local current: Instance? = from

	for segment in string.gmatch(path, "[^%.]+") do
		if segment == "script" then
			current = from
		elseif segment == "Parent" then
			current = if current then current.Parent else nil
		elseif current then
			current = current:FindFirstChild(segment)
		else
			return nil
		end
	end

	return current
end

local function getSettings(): PluginPreferences.Settings
	return PluginPreferences.Load(pluginHandle)
end

local function disconnectSourceConnections(module: ModuleScript)
	local connections = sourceConnections[module]

	if not connections then
		return
	end

	for _, connection in connections do
		connection:Disconnect()
	end

	sourceConnections[module] = nil
end

local function attachSourceRootWatch(module: ModuleScript, sourceRoot: Instance)
	disconnectSourceConnections(module)

	local connections = {}

	local function queue()
		local queueTargetCallback = queueTarget

		if queueTargetCallback then
			queueTargetCallback(module, getSettings().debounceSeconds)
		end
	end

	local function watchChild(child: Instance)
		table.insert(connections, child:GetPropertyChangedSignal("Name"):Connect(queue))
		table.insert(connections, child.AncestryChanged:Connect(queue))
	end

	for _, child in sourceRoot:GetChildren() do
		watchChild(child)
	end

	table.insert(connections, sourceRoot.ChildAdded:Connect(function(child)
		watchChild(child)
		queue()
	end))

	table.insert(connections, sourceRoot.ChildRemoved:Connect(queue))
	table.insert(connections, module.AncestryChanged:Connect(function()
		if not module.Parent then
			disconnectSourceConnections(module)
		end
	end))

	sourceConnections[module] = connections
end

local function regenerateTarget(module: ModuleScript)
	local currentSource = ArborDiscovery.GetEditorSource(module)
	local installations = ArborDiscovery.GetInstallations()
	local preferredEntry = ArborDiscovery.ResolveGeneratedRequireEntry(currentSource, installations)
	local installation = ArborDiscovery.GetInstallation(preferredEntry)

	if not installation then
		return
	end

	if not activeInstallation or activeInstallation.Entry ~= installation.Entry then
		activeInstallation = installation
		AutoGeneration.ObserveActiveEntryPath(activeInstallation)
	else
		activeInstallation = installation
	end

	local target = ArborDiscovery.ParseTarget(installation.Api, currentSource)

	if not target or target.kind ~= "tree-types" or not target.source then
		return
	end

	local sourceRoot = resolveSimplePath(module, target.source)

	if not sourceRoot then
		warn(`Arbor could not resolve source root "{target.source}" for {module:GetFullName()}`)
		return
	end

	attachSourceRootWatch(module, sourceRoot)

	local sourceExpression = target.source
	local arborRequireExpression = ArborDiscovery.SerializeInstancePath(installation.Entry)
	local settings = getSettings()

	if not arborRequireExpression then
		warn(`Arbor could not serialize active entry path for {installation.Entry:GetFullName()}`)
		return
	end

	local ok, result = pcall(function()
		return installation.Api.Authoring.TypeFacadeGenerator.GenerateTreeSource(sourceRoot, currentSource, {
			sourceRootExpression = sourceExpression,
			arborRequireExpression = arborRequireExpression,
			aliasNamingStyle = settings.aliasNamingStyle,
			aliasCollisionPolicy = settings.aliasCollisionPolicy,
			useTargetMetadata = true,
		})
	end)

	if not ok then
		warn(`Arbor skipped writing {module:GetFullName()} because generation failed: {tostring(result)}`)
		return
	end

	if #result.diagnostics > 0 then
		local messages = {}
		local hasError = false

		for _, diagnostic in result.diagnostics do
			table.insert(messages, `{diagnostic.code}:{diagnostic.message}`)

			if diagnostic.severity == "error" then
				hasError = true
			end
		end

		local diagnosticKey = table.concat(messages, "\n")

		if lastDiagnosticMessages[module] ~= diagnosticKey then
			lastDiagnosticMessages[module] = diagnosticKey
			Profiler.ReportDiagnostics(module, result.diagnostics)
		end

		if hasError then
			return
		end
	else
		lastDiagnosticMessages[module] = nil
	end

	if target.requires == "managed" and ArborDiscovery.ReadGeneratedRequireExpression(result.source) == nil then
		warn(`Arbor skipped writing {module:GetFullName()} because {installation.Entry:GetFullName()} generated an empty managed requires region`)
		return
	end

	if result.changed then
		local latestSource = ArborDiscovery.GetEditorSource(module)

		if latestSource ~= currentSource then
			warn(`Arbor skipped writing {module:GetFullName()} because the source changed during generation`)
			return
		end

		ArborDiscovery.UpdateEditorSource(module, result.source)
		print(`Arbor regenerated {module:GetFullName()}`)
	end
end

queueTarget = function(module: ModuleScript, debounceSeconds: number)
	pendingTargets[module] = true

	if flushing then
		return
	end

	flushing = true

	task.defer(function()
		task.wait(debounceSeconds)

		local targets = pendingTargets
		pendingTargets = {}
		flushing = false

		for moduleScript in targets do
			if moduleScript.Parent then
				regenerateTarget(moduleScript)
			end
		end
	end)
end

local function isTreeTypeTarget(module: ModuleScript, installation: ArborDiscovery.ArborInstallation?): boolean
	if not installation then
		return false
	end

	local target = ArborDiscovery.ParseTarget(installation.Api, ArborDiscovery.GetEditorSource(module))
	return target ~= nil and target.kind == "tree-types"
end

local function scanTargets(root: Instance)
	local settings = getSettings()
	local queueTargetCallback = queueTarget

	if not queueTargetCallback then
		return
	end

	local installation = ArborDiscovery.GetInstallation(nil)

	for _, descendant in root:GetDescendants() do
		if
			descendant:IsA("ModuleScript")
			and not ArborDiscovery.IsInsideActiveImplementation(descendant)
			and isTreeTypeTarget(descendant, installation)
		then
			queueTargetCallback(descendant, settings.debounceSeconds)
		end
	end
end

local function queueScan(root: Instance)
	pendingScans[root] = true

	if scanning then
		return
	end

	scanning = true

	task.defer(function()
		task.wait(getSettings().debounceSeconds)

		local roots = pendingScans
		pendingScans = {}
		scanning = false

		for root in roots do
			if root.Parent or root == game then
				scanTargets(root)
			end
		end
	end)
end

local function disconnectEntryConnections()
	for _, connection in entryConnections do
		connection:Disconnect()
	end

	entryConnections = {}
end

local function queueTargetRepairScans()
	for _, root in defaultTargetRoots do
		queueScan(root)
	end
end

local function reconcileActiveEntryPath()
	local installation = activeInstallation

	if not installation or not installation.Entry.Parent then
		installation = ArborDiscovery.GetInstallation(nil)
	end

	if not installation then
		lastEntryRequireExpression = nil
		return
	end

	local expression = ArborDiscovery.SerializeInstancePath(installation.Entry)

	if not expression then
		lastEntryRequireExpression = nil
		return
	end

	if expression ~= lastEntryRequireExpression then
		lastEntryRequireExpression = expression
		queueTargetRepairScans()
	end
end

local function startEntryPathReconciler(debounceSeconds: number)
	if reconcilingEntryPath then
		return
	end

	reconcilingEntryPath = true

	task.spawn(function()
		while reconcilingEntryPath do
			task.wait(math.max(debounceSeconds, 1))
			reconcileActiveEntryPath()
		end
	end)
end

local function collectPathInstances(entry: ModuleScript): { Instance }
	local instances = {}
	local current: Instance? = entry

	while current and current ~= game do
		table.insert(instances, current)
		current = current.Parent
	end

	return instances
end

--# Functions

function AutoGeneration.ObserveActiveEntryPath(installation: ArborDiscovery.ArborInstallation?)
	disconnectEntryConnections()

	if not installation then
		return
	end

	for _, instance in collectPathInstances(installation.Entry) do
		table.insert(entryConnections, instance:GetPropertyChangedSignal("Name"):Connect(function()
			lastEntryRequireExpression = nil
			queueTargetRepairScans()
		end))

		table.insert(entryConnections, instance.AncestryChanged:Connect(function()
			task.defer(function()
				AutoGeneration.ObserveActiveEntryPath(activeInstallation)
				lastEntryRequireExpression = nil
				queueTargetRepairScans()
			end)
		end))
	end
end

function AutoGeneration.Start(plugin: Plugin, settings: PluginPreferences.Settings)
	pluginHandle = plugin
	activeInstallation = ArborDiscovery.GetInstallation(nil)
	AutoGeneration.ObserveActiveEntryPath(activeInstallation)
	startEntryPathReconciler(settings.debounceSeconds)

	if settings.automaticGeneration and settings.generateOnOpen then
		for _, root in defaultTargetRoots do
			queueScan(root)
		end
	end

	if settings.automaticGeneration then
		for _, root in defaultTargetRoots do
			root.DescendantAdded:Connect(function(descendant)
				if
					descendant:IsA("ModuleScript")
					and not ArborDiscovery.IsInsideActiveImplementation(descendant)
					and isTreeTypeTarget(descendant, ArborDiscovery.GetInstallation(nil))
				then
					local queueTargetCallback = queueTarget

					if queueTargetCallback then
						queueTargetCallback(descendant, getSettings().debounceSeconds)
					end

					return
				end
			end)
		end
	end
end

--# Return

return AutoGeneration
