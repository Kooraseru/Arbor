$ErrorActionPreference = "Stop"

$arborRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$analyzeScript = Join-Path $arborRoot "tools\luau-lsp\analyze.ps1"

if (-not (Test-Path -LiteralPath $analyzeScript)) {
	throw "Missing Arbor analyzer wrapper: $analyzeScript"
}

$targets = @(
	"src/arbor@1.1.0/init.luau",
	"src/examples/serialized-types/IdentifyType.luau",
	"src/examples/serialized-types/CheckRelations.luau",
	"src/examples/plugin-sandbox/ServiceTypes.luau"
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

Write-Host "Luau analyzer pass OK: Arbor source-tree examples via tools/luau-lsp"
