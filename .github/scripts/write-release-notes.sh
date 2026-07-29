#!/usr/bin/env bash
set -euo pipefail

output_path="${1:-.generated/repo/release/notes.md}"
notes_source="${2:-release-notes/v1.0.1.toml}"
commit_sha="${3:-$(git rev-parse HEAD)}"
rbxm_path="${4:-.generated/repo/release/assets/Arbor.rbxm}"
commit_sha="$(git rev-parse "$commit_sha")"

if command -v python3 >/dev/null 2>&1; then
	python_cmd=python3
elif command -v python >/dev/null 2>&1; then
	python_cmd=python
elif command -v python.exe >/dev/null 2>&1; then
	python_cmd=python.exe
else
	echo "python3, python, or python.exe is required to render release notes" >&2
	exit 1
fi

mkdir -p -- "$(dirname -- "$output_path")"

if [ ! -f "$notes_source" ]; then
	echo "Missing release notes source: $notes_source" >&2
	exit 1
fi

short_sha="${commit_sha:0:7}"

"$python_cmd" .github/scripts/construct-changelog.py \
	--release-notes-dir release-notes \
	--content-root content \
	--release-metadata "$notes_source" \
	--output "$output_path"

cat >> "$output_path" <<NOTES

## Additional Information

- Commit: \`${commit_sha}\`
- Short commit: \`${short_sha}\`
- Package model: \`Arbor.rbxm\`
- Package root: \`ModuleScript Arbor\`
- Package source: \`src/\`
- Repository-only source is not bundled into the RBXM export.
NOTES

if [ -f "$rbxm_path" ]; then
	size_bytes="$(wc -c < "$rbxm_path" | tr -d ' ')"
	cat >> "$output_path" <<NOTES
- RBXM size: ${size_bytes} bytes
NOTES
fi

echo "Release notes written: $output_path"
