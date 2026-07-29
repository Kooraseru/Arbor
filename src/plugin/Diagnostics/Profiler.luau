-- Arbor/Plugin/Diagnostics/Profiler.luau
--!strict

local Profiler = {}

--# Variables

local warnings: { [string]: boolean } = {}

--# Types

export type Diagnostic = {
	code: string,
	message: string,
	severity: "error" | "warning",
}

--# Functions

function Profiler.WarnOnce(key: string, message: string)
	if warnings[key] then
		return
	end

	warnings[key] = true
	warn(message)
end

function Profiler.ReportDiagnostics(module: ModuleScript, diagnostics: { Diagnostic })
	for _, diagnostic in diagnostics do
		warn(`Arbor {diagnostic.code} in {module:GetFullName()}: {diagnostic.message}`)
	end
end

--# Return

return Profiler
