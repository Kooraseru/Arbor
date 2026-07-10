#!/usr/bin/env bash
set -euo pipefail

output_root="${1:-.tmp/results/pages/pages-workflow-test}"
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
local_base_url="${ARBOR_PAGES_LOCAL_BASE_URL:-http://127.0.0.1:8000/}"

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

if ! "$python_cmd" -c 'import yaml' >/dev/null 2>&1; then
	"$python_cmd" -m pip install pyyaml
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
	local language="$3"
	local branch_path
	branch_path="$(dirname "$(dirname "$config_path")")"
	local site_url_arg=()
	local site_name_arg=()
	local alternate_site_url

	alternate_site_url="$local_base_url"
	if [ "$branch" != "main" ]; then
		alternate_site_url="${local_base_url%/}/$branch/"
	fi
	if [ "$language" = "en" ]; then
		site_url_arg=(--site-url "$alternate_site_url")
	else
		site_url_arg=(--site-url "${alternate_site_url%/}/$language/")
	fi
	if [ "$branch" = "canary" ]; then
		site_name_arg=(--site-name "Arbor Canary")
	elif [ "$branch" = "ci" ]; then
		site_name_arg=(--site-name "Arbor CI")
	fi

	(
		cd "$branch_path"
		"$python_cmd" .github/scripts/configure-mkdocs-language.py --config "$(python_path "$config_path")" --language "$language" "${site_name_arg[@]}" "${site_url_arg[@]}" --alternate-site-url "$alternate_site_url"
	)
}

language_site_path() {
	local base_path="$1"
	local language="$2"

	if [ "$language" = "en" ]; then
		printf '%s\n' "$base_path"
	else
		printf '%s/%s\n' "$base_path" "$language"
	fi
}

stage_docs_assets() {
	local branch_path="$1"
	local language="$2"
	local language_content_dir="$branch_path/content/$language/wiki"
	local shared_assets_dir="$branch_path/assets"
	local target_assets_dir="$language_content_dir/assets"

	if [ ! -d "$shared_assets_dir" ]; then
		echo "Missing shared docs assets: $shared_assets_dir" >&2
		exit 1
	fi

	rm -rf -- "$target_assets_dir"
	cp -R "$shared_assets_dir" "$target_assets_dir"
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

	config_path="$branch_path/.github/mkdocs.yml"
	if [ ! -f "$config_path" ]; then
		echo "Skipping docs build for $branch: no .github/mkdocs.yml"
		continue
	fi

	branch_site_path="$site_path"
	if [ "$branch" != "main" ]; then
		branch_site_path="$site_path/$branch"
	fi

	(
		cd "$branch_path"
		"$python_cmd" .github/scripts/construct-changelog.py
	)

	for language in en jp; do
		language_content_dir="$branch_path/content/$language/wiki"
		if [ ! -d "$language_content_dir" ]; then
			echo "Skipping $branch $language docs: no content/$language/wiki"
			continue
		fi

		language_config_path="$branch_path/.tmp/mkdocs-$language.yml"
		mkdir -p -- "$(dirname "$language_config_path")"
		cp "$config_path" "$language_config_path"

		stage_docs_assets "$branch_path" "$language"
		set_site_metadata "$language_config_path" "$branch" "$language"

		language_site_path="$(language_site_path "$branch_site_path" "$language")"

		echo "Building $branch $language docs -> $language_site_path"
		(
			cd "$branch_path"
			"$python_cmd" -m mkdocs build --config-file ".tmp/mkdocs-$language.yml" --site-dir "$(python_path "$language_site_path")"
		)
	done
done

if [ ! -d "$site_path" ]; then
	echo "Pages artifact directory was not created: $site_path" >&2
	exit 1
fi

if [ -z "$(find "$site_path" -name index.html -type f -print -quit)" ]; then
	echo "Pages artifact directory contains no index.html files: $site_path" >&2
	exit 1
fi

for rendered_example in \
	"$site_path/examples/direct-children/index.html" \
	"$site_path/jp/examples/direct-children/index.html" \
	"$site_path/canary/examples/direct-children/index.html" \
	"$site_path/canary/jp/examples/direct-children/index.html" \
	"$site_path/ci/examples/direct-children/index.html"
do
	if [ -f "$rendered_example" ] && ! grep -Eq "Arbor/content/(en|jp)/examples/direct-children/init.luau" "$rendered_example"; then
		echo "Rendered direct-children example is missing included init.luau source: $rendered_example" >&2
		exit 1
	fi
done

for rendered_index in \
	"$site_path/index.html" \
	"$site_path/jp/index.html" \
	"$site_path/canary/index.html" \
	"$site_path/canary/jp/index.html" \
	"$site_path/ci/index.html" \
	"$site_path/ci/jp/index.html"
do
	if [ -f "$rendered_index" ] && ! grep -q "md-select" "$rendered_index"; then
		echo "Rendered docs index is missing the Material language selector: $rendered_index" >&2
		exit 1
	fi
done

echo "Pages artifact shape OK: $site_path"
echo "Serve locally with: $python_cmd -m http.server 8000 --directory $(python_path "$site_path")"
