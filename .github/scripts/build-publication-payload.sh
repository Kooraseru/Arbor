#!/usr/bin/env bash
set -euo pipefail

source_path="${1:?source path is required}"
destination="${2:?destination path is required}"
channel="${3:?channel is required}"
version="${4:?version is required}"
source_commit="${5:?source commit SHA is required}"
generated_at="${6:-}"

case "$channel" in
	pre-release|release) ;;
	*)
		echo "Unsupported publication channel: $channel" >&2
		exit 1
		;;
esac

if [[ ! "$source_commit" =~ ^[0-9a-f]{40}$ ]]; then
	echo "source commit must be a full 40-character SHA: $source_commit" >&2
	exit 1
fi

if [ -z "$version" ]; then
	echo "version is required" >&2
	exit 1
fi

if [ -z "$generated_at" ]; then
	generated_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
fi

if command -v python3 >/dev/null 2>&1; then
	python_cmd=python3
elif command -v python >/dev/null 2>&1; then
	python_cmd=python
elif command -v python.exe >/dev/null 2>&1; then
	python_cmd=python.exe
else
	echo "python3, python, or python.exe is required to build publication metadata" >&2
	exit 1
fi

rm -rf -- "$destination"
mkdir -p -- "$destination"

for publication_dir in .github content src; do
	if [ -d "$source_path/$publication_dir" ]; then
		cp -R "$source_path/$publication_dir" "$destination/$publication_dir"
	fi
done

rm -rf -- \
	"$destination/.github/disabled-workflows" \
	"$destination/.github/tools/rbxm-exporter/target" \
	"$destination/.github/scripts/__pycache__"

if [ -f "$source_path/.github/scripts/render-localized-content.py" ]; then
	rm -rf -- "$destination/content"
	mkdir -p -- "$destination/content"
	if [ -d "$source_path/content/assets" ]; then
		cp -R "$source_path/content/assets" "$destination/content/assets"
	fi
	"$python_cmd" "$source_path/.github/scripts/render-localized-content.py" \
		--content-root "$source_path/content" \
		--output-root "$destination/content"
fi

if [ -f "$source_path/.github/scripts/update-readme-language-links.py" ]; then
	"$python_cmd" "$source_path/.github/scripts/update-readme-language-links.py" \
		--mode publication \
		--source-root "$source_path" \
		--publication-root "$destination"
fi

default_language="$("$python_cmd" "$source_path/.github/scripts/render-localized-content.py" --content-root "$destination/content" --list-languages | head -n 1)"

for publication_file in CONTRIBUTING.md; do
	if [ -f "$destination/content/locales/$default_language/$publication_file" ]; then
		cp "$destination/content/locales/$default_language/$publication_file" "$destination/$publication_file"
	fi
done

if [ -f "$source_path/content/repo/LICENSE" ]; then
	cp "$source_path/content/repo/LICENSE" "$destination/LICENSE"
fi

rm -f -- \
	"$destination/content/locales/$default_language/README.md" \
	"$destination/content/locales/$default_language/CONTRIBUTING.md" \
	"$destination/content/locales/$default_language/LICENSE"

if [ -f "$source_path/.github/scripts/construct-changelog.py" ]; then
	"$python_cmd" "$source_path/.github/scripts/construct-changelog.py" \
		--release-notes-dir "$source_path/release-notes" \
		--content-root "$destination/content" \
		--language "$default_language" \
		--output "$destination/CHANGELOG.md"
fi

mkdir -p -- "$destination/.github"

"$python_cmd" - "$destination/.github/publication.json" "$channel" "$version" "$source_commit" "$generated_at" <<'PY'
import json
import sys

output_path, channel, version, source_commit, generated_at = sys.argv[1:]

with open(output_path, "w", encoding="utf-8", newline="\n") as output_file:
    json.dump(
        {
            "channel": channel,
            "version": version,
            "sourceCommit": source_commit,
            "generatedAt": generated_at,
        },
        output_file,
        indent=2,
    )
    output_file.write("\n")
PY

for source_only_path in .generated .gitattributes .gitignore .vscode docs tools AGENTS.md release-notes .github/disabled-workflows .github/tools/rbxm-exporter/target .github/scripts/__pycache__; do
	if [ -e "$destination/$source_only_path" ]; then
		echo "Generated publication output contains source-only path: $source_only_path" >&2
		exit 1
	fi
done

for required_path in .github content src README.md CONTRIBUTING.md LICENSE CHANGELOG.md .github/publication.json; do
	if [ ! -e "$destination/$required_path" ]; then
		echo "Generated publication output is missing required path: $required_path" >&2
		exit 1
	fi
done
