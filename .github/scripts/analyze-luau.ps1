$ErrorActionPreference = "Stop"

$arborRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$workspaceRoot = Resolve-Path (Join-Path $arborRoot "..\..\..\..")
$analyzeScript = Join-Path $workspaceRoot ".luau-lsp\analyze.fish"

if (-not (Test-Path -LiteralPath $analyzeScript)) {
	throw "Missing workspace analyzer wrapper: $analyzeScript"
}

$targets = @(
	"src/Shared/Packages/Arbor/src/init.luau",
	"src/Shared/Packages/Arbor/content/en/examples/direct-children/init.luau",
	"src/Shared/Packages/Arbor/content/en/examples/class-filtered-children/init.luau",
	"src/Shared/Packages/Arbor/content/en/examples/runtime-loader/init.luau"
)

Push-Location $workspaceRoot
try {
	& wsl fish .luau-lsp/analyze.fish @targets
	if ($LASTEXITCODE -ne 0) {
		exit $LASTEXITCODE
	}
}
finally {
	Pop-Location
}

Write-Host "Luau analyzer pass OK: Arbor source-tree content/en/examples via workspace .luau-lsp"
