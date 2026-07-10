#!/usr/bin/env bash
set -euo pipefail

output_path="${1:-.tmp/results/release/notes.md}"
notes_source="${2:-release-notes/Stable/v1.0.0.md}"
commit_sha="${3:-$(git rev-parse HEAD)}"
rbxm_path="${4:-.tmp/results/release/assets/Arbor.rbxm}"
commit_sha="$(git rev-parse "$commit_sha")"

mkdir -p -- "$(dirname -- "$output_path")"

if [ ! -f "$notes_source" ]; then
	echo "Missing release notes source: $notes_source" >&2
	exit 1
fi

short_sha="${commit_sha:0:7}"

cat > "$output_path" <<NOTES
$(cat "$notes_source")

## Additional Information

- Commit: \`${commit_sha}\`
- Short commit: \`${short_sha}\`
- Package model: \`Arbor.rbxm\`
- Package root: \`ModuleScript Arbor\`
- Package source: \`src/\`
- Examples are not bundled into the RBXM export; they remain repository fixtures.
NOTES

if [ -f "$rbxm_path" ]; then
	size_bytes="$(wc -c < "$rbxm_path" | tr -d ' ')"
	cat >> "$output_path" <<NOTES
- RBXM size: ${size_bytes} bytes
NOTES
fi

echo "Release notes written: $output_path"
