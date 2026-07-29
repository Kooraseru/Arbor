$ErrorActionPreference = "Stop"

$arborRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$analyzeScript = Join-Path $arborRoot "tools\luau-lsp\analyze.ps1"

if (-not (Test-Path -LiteralPath $analyzeScript)) {
	throw "Missing Arbor analyzer wrapper: $analyzeScript"
}

$targets = @(
	"src/arbor@1.1.0/init.luau",
	"src/arbor@1.1.0/Definitions/TypeFunctions/Children/Names/ChildNames.luau",
	"src/arbor@1.1.0/Definitions/TypeFunctions/Children/Records/ChildRecord.luau",
	"src/arbor@1.1.0/Definitions/TypeFunctions/Children/Checks/IsChildOf.luau",
	"src/arbor@1.1.0/Definitions/TypeFunctions/Ancestors/Checks/IsAncestorOf.luau",
	"src/arbor@1.1.0/Definitions/TypeFunctions/Descendants/Checks/IsDescendantOf.luau",
	"src/arbor@1.1.0/RuntimeLoaders/LoadModuleMap.luau"
)

Push-Location $arborRoot
try {
	& $analyzeScript -Root $arborRoot @targets
	if ($LASTEXITCODE -ne 0) {
		exit $LASTEXITCODE
	}
}
finally {
	Pop-Location
}

Write-Host "Luau analyzer pass OK: Arbor package source via tools/luau-lsp"
