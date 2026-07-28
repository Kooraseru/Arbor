#!/usr/bin/env bash
set -euo pipefail

output_root="${1:-.generated}"
branches=("${@:2}")

if [ "${#branches[@]}" -eq 0 ]; then
	branches=(source pre-release release)
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/../.." && pwd)"
output_root_path="$repo_root/$output_root"
site_path="$output_root_path/shared/pages"
shared_content_path="$output_root_path/shared/content"
repo_path="$output_root_path/repo"
current_branch="$(git -C "$repo_root" branch --show-current)"
local_base_url="${ARBOR_PAGES_LOCAL_BASE_URL:-http://127.0.0.1:8000/}"
workspace_path="$(mktemp -d)"
source_commit="$(git -C "$repo_root" rev-parse HEAD)"

cleanup() {
	rm -rf -- "$workspace_path"
}

trap cleanup EXIT

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
mkdir -p -- "$site_path" "$shared_content_path" "$repo_path/pre-release" "$repo_path/release"

if ! "$python_cmd" -m mkdocs --version >/dev/null 2>&1; then
	"$python_cmd" -m pip install mkdocs-material
fi

if ! "$python_cmd" -c 'import yaml' >/dev/null 2>&1; then
	"$python_cmd" -m pip install pyyaml
fi

export_branch() {
	local branch="$1"
	local destination="$2"

	mkdir -p -- "$destination"
	git -C "$repo_root" archive --worktree-attributes "$branch" | tar -xf - -C "$destination"
}

export_worktree_source() {
	local destination="$1"

	mkdir -p -- "$destination"
	tar \
		--exclude='./.git' \
		--exclude='.git' \
		--exclude='./.generated' \
		--exclude='.generated' \
		--exclude='./docs' \
		--exclude='docs' \
		--exclude='./tools' \
		--exclude='tools' \
		--exclude='./AGENTS.md' \
		--exclude='AGENTS.md' \
		-C "$repo_root" \
		-cf - . | tar -xf - -C "$destination"
}

stage_publication_payload() {
	local source_path="$1"
	local lane="$2"
	local destination="$repo_path/$lane"
	local version

	version="local-$lane"
	bash "$repo_root/.github/scripts/build-publication-payload.sh" "$source_path" "$destination" "$lane" "$version" "$source_commit"
	verify_publication_filter "$destination"
}

verify_publication_filter() {
	local branch_path="$1"

	for source_only_path in .generated .gitattributes .gitignore .vscode docs tools AGENTS.md release-notes .github/tools/rbxm-exporter/target .github/scripts/__pycache__; do
		if [ -e "$branch_path/$source_only_path" ]; then
			echo "Generated publication output contains source-only path: $source_only_path" >&2
			exit 1
		fi
	done

	for required_path in .github content src README.md CONTRIBUTING.md LICENSE CHANGELOG.md .github/publication.json; do
		if [ ! -e "$branch_path/$required_path" ]; then
			echo "Generated publication output is missing required path: $required_path" >&2
			exit 1
		fi
	done
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

	branch_path="$(cd -- "$(dirname -- "$config_path")/.." && pwd)"
	alternate_site_url="$local_base_url"
	if [ "$branch" = "pre-release" ]; then
		alternate_site_url="${local_base_url%/}/$branch/"
	fi
	if [ "$language" = "en" ]; then
		site_url_arg=(--site-url "$alternate_site_url")
	else
		site_url_arg=(--site-url "${alternate_site_url%/}/$language/")
	fi
	if [ "$branch" = "pre-release" ]; then
		site_name_arg=(--site-name "Arbor Pre-release")
	fi

	(
		cd "$branch_path"
		"$python_cmd" .github/scripts/configure-mkdocs-language.py --config "$(python_path "$config_path")" --content-root .generated/shared/content --language "$language" "${site_name_arg[@]}" "${site_url_arg[@]}" --alternate-site-url "$alternate_site_url"
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

wiki_languages() {
	local branch_path="$1"
	local default_language
	local language
	local locale_file
	local languages=()

	default_language="$(
		cd "$branch_path"
		"$python_cmd" .github/scripts/render-localized-content.py --content-root .generated/shared/content --list-languages | head -n 1
	)"

	for locale_file in "$branch_path"/.generated/shared/content/locales/*/locale.toml; do
		if [ ! -f "$locale_file" ]; then
			continue
		fi

		language="$(basename "$(dirname "$locale_file")")"
		if [ -d "$branch_path/.generated/shared/content/locales/$language/wiki" ]; then
			languages+=("$language")
		fi
	done

	if printf '%s\n' "${languages[@]}" | grep -Fxq "$default_language"; then
		printf '%s\n' "$default_language"
	fi

	printf '%s\n' "${languages[@]}" | grep -Fxv "$default_language" | sort
}

stage_docs_assets() {
	local branch_path="$1"
	local language="$2"
	local language_content_dir="$branch_path/.generated/shared/content/locales/$language/wiki"
	local shared_assets_dir="$branch_path/content/assets"
	local target_assets_dir="$language_content_dir/assets"

	if [ ! -d "$shared_assets_dir" ]; then
		echo "Missing shared docs assets: $shared_assets_dir" >&2
		exit 1
	fi

	rm -rf -- "$target_assets_dir"
	cp -R "$shared_assets_dir" "$target_assets_dir"
}

build_language_docs() {
	local branch_path="$1"
	local branch="$2"
	local language="$3"
	local output_path="$4"
	local config_path="$branch_path/.github/mkdocs.yml"
	local language_content_dir="$branch_path/.generated/shared/content/locales/$language/wiki"
	local language_config_path="$branch_path/.generated/mkdocs-$branch-$language.yml"

	if [ ! -f "$config_path" ]; then
		echo "Skipping docs build for $branch: no .github/mkdocs.yml"
		return
	fi

	if [ ! -d "$language_content_dir" ]; then
		echo "Skipping $branch $language docs: no generated localized wiki"
		return
	fi

	mkdir -p -- "$(dirname "$language_config_path")"
	cp "$config_path" "$language_config_path"

	stage_docs_assets "$branch_path" "$language"
	set_site_metadata "$language_config_path" "$branch" "$language"

	echo "Building $branch $language docs -> $output_path"
	(
		cd "$branch_path"
		export ARBOR_WIKI_LANGUAGE="$language"
		export ARBOR_CONTENT_ROOT=".generated/shared/content"
		if [ ! -f "$branch_path/.github/mkdocs_extensions/api_links.py" ]; then
			echo "Missing MkDocs extension in staged source: $branch_path/.github/mkdocs_extensions/api_links.py" >&2
			exit 1
		fi
		"$python_cmd" .github/scripts/run-mkdocs.py build --config-file "$(python_path "$language_config_path")" --site-dir "$(python_path "$output_path")"
	)
}

source_path="$workspace_path/source"
export_worktree_source "$source_path"
source_requested=false

for branch in "${branches[@]}"; do
	if [ "$branch" = "source" ]; then
		source_requested=true
	else
		stage_publication_payload "$source_path" "$branch"
		echo "Staged $branch repo payload -> $repo_path/$branch"
	fi
done

if [ "$source_requested" = "true" ]; then

	branch_path="$source_path"

	rm -rf -- "$shared_content_path"
	mkdir -p -- "$shared_content_path"
	(
		cd "$branch_path"
		"$python_cmd" .github/scripts/render-localized-content.py --output-root .generated/shared/content
	)
	cp -R "$branch_path/.generated/shared/content"/. "$shared_content_path"

	(
		cd "$branch_path"
		"$python_cmd" .github/scripts/construct-changelog.py --content-root .generated/shared/content --output .generated/shared/content/generated/CHANGELOG.md
	)
	mkdir -p -- "$shared_content_path/generated"
	cp "$branch_path/.generated/shared/content/generated/CHANGELOG.md" "$shared_content_path/generated/CHANGELOG.md"
	"$python_cmd" "$(python_path "$repo_root/.github/scripts/collect-publication-manifests.py")" \
		--release-manifest "$(python_path "$repo_path/release/.github/publication.json")" \
		--pre-release-manifest "$(python_path "$repo_path/pre-release/.github/publication.json")" \
		--output "$(python_path "$shared_content_path/generated/publications.json")"
	mkdir -p -- "$branch_path/.generated/shared/content/generated"
	cp "$shared_content_path/generated/CHANGELOG.md" "$branch_path/.generated/shared/content/generated/CHANGELOG.md"
	cp "$shared_content_path/generated/publications.json" "$branch_path/.generated/shared/content/generated/publications.json"

	mapfile -t discovered_languages < <(wiki_languages "$branch_path")
	echo "Discovered wiki languages: ${discovered_languages[*]}"

	for language in "${discovered_languages[@]}"; do
		language="${language%$'\r'}"
		if [ -z "$language" ]; then
			continue
		fi
		(
			cd "$branch_path"
			"$python_cmd" .github/scripts/construct-changelog.py \
				--content-root .generated/shared/content \
				--language "$language" \
				--output ".generated/shared/content/locales/$language/wiki/reference/changelog.md"
		)
		language_site_path="$(language_site_path "$site_path" "$language")"
		build_language_docs "$branch_path" "release" "$language" "$language_site_path"
		build_language_docs "$branch_path" "pre-release" "$language" "$(language_site_path "$site_path/pre-release" "$language")"
	done
fi

if [ ! -d "$site_path" ]; then
	echo "Pages artifact directory was not created: $site_path" >&2
	exit 1
fi

if [ -z "$(find "$site_path" -name index.html -type f -print -quit)" ]; then
	echo "Pages artifact directory contains no index.html files: $site_path" >&2
	exit 1
fi

for rendered_index in \
	"$site_path/index.html" \
	"$site_path/pre-release/index.html"
do
	if [ -f "$rendered_index" ] && ! grep -q "md-select" "$rendered_index"; then
		echo "Rendered docs index is missing the Material language selector: $rendered_index" >&2
		exit 1
	fi
done

for required_asset in \
	"$site_path/assets/brand/Billboard.svg" \
	"$site_path/assets/brand/Icon.svg" \
	"$site_path/assets/javascripts/type-tooltips.js" \
	"$site_path/assets/stylesheets/brand.css" \
	"$site_path/pre-release/assets/brand/Billboard.svg" \
	"$site_path/pre-release/assets/brand/Icon.svg" \
	"$site_path/pre-release/assets/javascripts/type-tooltips.js" \
	"$site_path/pre-release/assets/stylesheets/brand.css"
do
	if [ ! -f "$required_asset" ]; then
		echo "Rendered docs output is missing required shared asset: $required_asset" >&2
		exit 1
	fi
done

echo "Pages artifact shape OK: $site_path"
echo "Serve locally with: $python_cmd -m http.server 8000 --directory $(python_path "$site_path")"
