#!/usr/bin/env bash
set -euo pipefail

output_root="${1:-.tmp/pages-workflow-test}"
branches=("${@:2}")

if [ "${#branches[@]}" -eq 0 ]; then
	branches=(main canary ci)
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/../.." && pwd)"
output_root_path="$repo_root/$output_root"
workspace_path="$output_root_path/workspace"
site_path="$output_root_path/result"
current_branch="$(git -C "$repo_root" branch --show-current)"

if command -v python3 >/dev/null 2>&1 && python3 -m pip --version >/dev/null 2>&1; then
	python_cmd=python3
elif command -v python >/dev/null 2>&1; then
	python_cmd=python
elif command -v python.exe >/dev/null 2>&1; then
	python_cmd=python.exe
else
	echo "python3, python, or python.exe is required to run the Pages workflow test" >&2
	exit 1
fi

python_path() {
	local path="$1"

	if [[ "$python_cmd" == *.exe ]] && command -v wslpath >/dev/null 2>&1; then
		wslpath -w "$path"
	else
		printf '%s\n' "$path"
	fi
}

case "$output_root_path" in
	"$repo_root"/*) ;;
	*)
		echo "Refusing to remove path outside repository: $output_root_path" >&2
		exit 1
		;;
esac

rm -rf -- "$output_root_path"
mkdir -p -- "$workspace_path"

if ! "$python_cmd" -m mkdocs --version >/dev/null 2>&1; then
	"$python_cmd" -m pip install mkdocs-material
fi

copy_working_tree() {
	local destination="$1"

	mkdir -p -- "$destination"
	tar \
		--exclude=.git \
		--exclude=.tmp \
		-cf - \
		-C "$repo_root" \
		. \
		| tar -xf - -C "$destination"
}

export_branch() {
	local branch="$1"
	local destination="$2"

	mkdir -p -- "$destination"
	git -C "$repo_root" archive "$branch" | tar -xf - -C "$destination"
}

set_site_metadata() {
	local config_path="$1"
	local branch="$2"

	if [ "$branch" = "main" ]; then
		return
	fi

	"$python_cmd" - "$(python_path "$config_path")" "$branch" <<'PY'
from pathlib import Path
import sys

config = Path(sys.argv[1])
branch = sys.argv[2]
text = config.read_text(encoding="utf-8")
display_name = {
	"canary": "Arbor Canary",
	"ci": "Arbor CI",
}.get(branch, "Arbor")
text = text.replace("site_name: Arbor", f"site_name: {display_name}")
text = text.replace(
	"site_url: https://kooraseru.github.io/Arbor/",
	f"site_url: https://kooraseru.github.io/Arbor/{branch}/",
)
config.write_text(text, encoding="utf-8")
PY
}

for branch in "${branches[@]}"; do
	branch_path="$workspace_path/$branch"

	if ! git -C "$repo_root" rev-parse --verify --quiet "$branch" >/dev/null; then
		echo "Skipping missing branch: $branch"
		continue
	fi

	if [ "$branch" = "$current_branch" ]; then
		copy_working_tree "$branch_path"
	else
		export_branch "$branch" "$branch_path"
	fi

	config_path="$branch_path/mkdocs.yml"
	if [ ! -f "$config_path" ]; then
		echo "Skipping docs build for $branch: no mkdocs.yml"
		continue
	fi

	set_site_metadata "$config_path" "$branch"

	branch_site_path="$site_path"
	if [ "$branch" != "main" ]; then
		branch_site_path="$site_path/$branch"
	fi

	echo "Building $branch docs -> $branch_site_path"
	"$python_cmd" -m mkdocs build --config-file "$(python_path "$config_path")" --site-dir "$(python_path "$branch_site_path")"
done

if [ ! -d "$site_path" ]; then
	echo "Pages artifact directory was not created: $site_path" >&2
	exit 1
fi

if ! find "$site_path" -name index.html -type f | grep -q .; then
	echo "Pages artifact directory contains no index.html files: $site_path" >&2
	exit 1
fi

echo "Pages artifact shape OK: $site_path"
