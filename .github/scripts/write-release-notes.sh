#!/usr/bin/env bash
set -euo pipefail

output_path="${1:-.tmp/release/notes.md}"
commit_sha="${2:-$(git rev-parse HEAD)}"
rbxm_path="${3:-.tmp/rbxm-export/result/Arbor.rbxm}"
commit_sha="$(git rev-parse "$commit_sha")"

mkdir -p -- "$(dirname -- "$output_path")"

latest_section="$(awk '
	/^## / {
		if (seen) {
			exit
		}
		seen = 1
	}
	seen {
		print
	}
' CHANGELOG.md)"

short_sha="${commit_sha:0:7}"

cat > "$output_path" <<NOTES
${latest_section}

## Additional Information

- Commit: \`${commit_sha}\`
- Commit tag: \`commit-${short_sha}\`
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
