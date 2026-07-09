#!/usr/bin/env bash
set -euo pipefail

source_root="${1:-src}"
output_path="${2:-.tmp/rbxm-export/result/Arbor.rbxm}"
package_name="${3:-Arbor}"

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/../.." && pwd)"
exporter_root="$repo_root/.github/tools/rbxm-exporter"

cargo_cmd=cargo
if ! command -v cargo >/dev/null 2>&1; then
	if command -v cargo.exe >/dev/null 2>&1; then
		cargo_cmd=cargo.exe
	else
		echo "cargo is required to run the RBXM exporter" >&2
		exit 1
	fi
fi

tool_path() {
	local path="$1"

	if [[ "$cargo_cmd" == *.exe ]] && command -v wslpath >/dev/null 2>&1; then
		wslpath -w "$path"
	else
		printf '%s\n' "$path"
	fi
}

cd "$repo_root"
"$cargo_cmd" run --quiet --manifest-path "$(tool_path "$exporter_root/Cargo.toml")" -- "$(tool_path "$repo_root/$source_root")" "$(tool_path "$repo_root/$output_path")" "$package_name"
"$cargo_cmd" run --quiet --manifest-path "$(tool_path "$exporter_root/Cargo.toml")" -- verify "$(tool_path "$repo_root/$output_path")" "$package_name"
