#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/../.." && pwd)"

cd "$repo_root"

python_cmd=""
if command -v python3 >/dev/null 2>&1; then
	python_cmd="python3"
elif command -v python >/dev/null 2>&1; then
	python_cmd="python"
else
	echo "error: missing Python. Expected python3 or python on PATH." >&2
	exit 1
fi

"$python_cmd" tools/luau-lsp/scripts/generate-sourcemap.py --output tools/luau-lsp/generated/sourcemap.json

files=("$@")

if [[ ${#files[@]} -eq 0 ]]; then
	mapfile -t files < <(find src -type f \( -name '*.luau' -o -name '*.lua' \) | sed 's|^\./||')
fi

if [[ ${#files[@]} -eq 0 ]]; then
	echo "error: no Luau files found" >&2
	exit 1
fi

lsp="tools/luau-lsp/bin/luau-lsp.exe"
if [[ ! -x "$lsp" ]]; then
	if command -v luau-lsp >/dev/null 2>&1; then
		lsp="luau-lsp"
	else
		echo "error: missing luau-lsp. Expected tools/luau-lsp/bin/luau-lsp.exe or luau-lsp on PATH." >&2
		exit 1
	fi
fi

echo "Analyzing ${#files[@]} files"

output_file="$(mktemp)"
cleanup() {
	rm -f "$output_file"
}
trap cleanup EXIT

set +e
"$lsp" analyze \
	--settings tools/luau-lsp/analyze-settings.json \
	--definitions tools/luau-lsp/definitions/roblox.globaltypes \
	--sourcemap tools/luau-lsp/generated/sourcemap.json \
	--platform roblox \
	--ignore "src/plugin/UI/Packages/@jsdotlua/**" \
	--ignore "src/plugin/UI/Packages/symbol-luau/**" \
	"${files[@]}" 2>&1 | sed "s|$repo_root/||g" | tee "$output_file"
analyze_status=${PIPESTATUS[0]}
set -e

if [[ $analyze_status -ne 0 ]]; then
	exit "$analyze_status"
fi

if grep -Eq '\([0-9]+,[0-9]+\): (TypeError|SyntaxError|Lint|ParseError):' "$output_file"; then
	exit 1
fi
