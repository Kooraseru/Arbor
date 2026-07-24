[CmdletBinding()]
param(
	[string] $Root = "",

	[Parameter(ValueFromRemainingArguments = $true)]
	[string[]] $Files = @()
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = if ($Root -ne "") {
	Resolve-Path $Root
}
else {
	Resolve-Path (Join-Path $scriptDir "..\..")
}
$lsp = Join-Path $scriptDir "bin\luau-lsp.exe"
$settings = Join-Path $scriptDir "analyze-settings.json"
$sourcemap = Join-Path $scriptDir "generated\sourcemap.json"
$definitions = Join-Path $scriptDir "definitions\roblox.globaltypes"
$generator = Join-Path $scriptDir "scripts\generate-sourcemap.py"

if (-not (Test-Path $lsp)) {
	$pathLsp = Get-Command luau-lsp -ErrorAction SilentlyContinue
	if ($null -ne $pathLsp) {
		$lsp = $pathLsp.Source
	}
	else {
		throw "Missing luau-lsp binary. Expected tools\luau-lsp\bin\luau-lsp.exe or luau-lsp on PATH."
	}
}

if (-not (Test-Path $definitions)) {
	throw "Missing Roblox definitions at $definitions. Download JohnnyMorganz/luau-lsp scripts/globalTypes.d.lua to tools\luau-lsp\definitions\roblox.globaltypes."
}

Push-Location $repoRoot
try {
	python $generator --output tools/luau-lsp/generated/sourcemap.json

	if ($Files.Count -eq 0) {
		$Files = Get-ChildItem -Recurse -File -Path src -Include *.luau,*.lua |
			ForEach-Object { Resolve-Path -Relative $_.FullName }
	}

	if ($Files.Count -eq 0) {
		throw "No Luau files found."
	}

	Write-Host "Analyzing $($Files.Count) files"

	$previousErrorActionPreference = $ErrorActionPreference
	$ErrorActionPreference = "Continue"
	$output = & $lsp analyze `
		--settings $settings `
		--sourcemap $sourcemap `
		--definitions $definitions `
		--platform roblox `
		--ignore "src/plugin/UI/Packages/@jsdotlua/**" `
		--ignore "src/plugin/UI/Packages/symbol-luau/**" `
		@Files 2>&1
	$analyzeStatus = $LASTEXITCODE
	$ErrorActionPreference = $previousErrorActionPreference

	$outputText = $output -join [Environment]::NewLine
	$outputText = $outputText.Replace("$repoRoot\", "")
	Write-Output $outputText

	if ($analyzeStatus -ne 0) {
		exit $analyzeStatus
	}

	if ($outputText -match "\([0-9]+,[0-9]+\): (TypeError|SyntaxError|Lint|ParseError):") {
		exit 1
	}
}
finally {
	Pop-Location
}
