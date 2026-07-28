#!/usr/bin/env bash
set -euo pipefail

output_root="${1:-.generated}"
source_ref="${2:-HEAD}"

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/../.." && pwd)"
output_root_path="$repo_root/$output_root"
repo_path="$output_root_path/repo"
shared_generated_path="$output_root_path/shared/content/generated"
source_commit="$(git -C "$repo_root" rev-parse "$source_ref")"
remote_path="$output_root_path/shared/test/publish-remote.git"

case "$output_root_path" in
	"$repo_root"/*) ;;
	*)
		echo "Refusing to write outside repository: $output_root_path" >&2
		exit 1
		;;
esac

if [[ ! "$source_commit" =~ ^[0-9a-f]{40}$ ]]; then
	echo "source_ref did not resolve to a full source commit SHA: $source_ref" >&2
	exit 1
fi

if ! git -C "$repo_root" branch --contains "$source_commit" --format='%(refname:short)' | grep -Eq '^(source|HEAD)$'; then
	echo "Warning: local source_ref is not currently contained by a local source branch: $source_commit" >&2
fi

bash "$repo_root/.github/scripts/build-publication-payload.sh" "$repo_root" "$repo_path/pre-release" pre-release "1.1.0-beta.2" "$source_commit" "2026-07-27T00:00:00Z"
bash "$repo_root/.github/scripts/build-publication-payload.sh" "$repo_root" "$repo_path/release" release "1.1.0" "$source_commit" "2026-07-27T00:00:00Z"

rm -rf -- "$remote_path"
mkdir -p -- "$(dirname -- "$remote_path")"
git -c init.defaultBranch=source init --bare "$remote_path" >/dev/null
bash "$repo_root/.github/scripts/publish-generated-branch.sh" "$repo_path/pre-release" "$remote_path" pre-release "1.1.0-beta.2" "$source_commit" "v1.1.0-beta.2" >/dev/null
bash "$repo_root/.github/scripts/publish-generated-branch.sh" "$repo_path/release" "$remote_path" release "1.1.0" "$source_commit" "v1.1.0" >/dev/null
bash "$repo_root/.github/scripts/publish-generated-branch.sh" "$repo_path/pre-release" "$remote_path" pre-release "1.1.0-beta.2" "$source_commit" "v1.1.0-beta.2" >/dev/null
bash "$repo_root/.github/scripts/publish-generated-branch.sh" "$repo_path/release" "$remote_path" release "1.1.0" "$source_commit" "v1.1.0" >/dev/null

mkdir -p -- "$shared_generated_path"
python_cmd=python3
if ! command -v "$python_cmd" >/dev/null 2>&1; then
	if command -v python >/dev/null 2>&1; then
		python_cmd=python
	elif command -v python.exe >/dev/null 2>&1; then
		python_cmd=python.exe
	else
		echo "python3, python, or python.exe is required to test publication manifests" >&2
		exit 1
	fi
fi

python_path() {
	local path="$1"

	if [[ "$python_cmd" == *.exe ]] && command -v wslpath >/dev/null 2>&1; then
		wslpath -w "$path"
	else
		printf '%s\n' "$path"
	fi
}

"$python_cmd" "$(python_path "$repo_root/.github/scripts/collect-publication-manifests.py")" \
	--release-manifest "$(python_path "$repo_path/release/.github/publication.json")" \
	--pre-release-manifest "$(python_path "$repo_path/pre-release/.github/publication.json")" \
	--output "$(python_path "$shared_generated_path/publications.json")"

"$python_cmd" - "$repo_path" "$shared_generated_path/publications.json" "$source_commit" <<'PY'
import json
import sys
from pathlib import Path

repo_path = Path(sys.argv[1])
publications_path = Path(sys.argv[2])
source_commit = sys.argv[3]
expected_root = [".github", "CHANGELOG.md", "content", "CONTRIBUTING.md", "LICENSE", "README.md", "src"]

for lane, version in [("pre-release", "1.1.0-beta.2"), ("release", "1.1.0")]:
    root = repo_path / lane
    names = sorted(path.name for path in root.iterdir())
    if names != sorted(expected_root):
        raise SystemExit(f"{lane} root mismatch: {names}")

    manifest = json.loads((root / ".github/publication.json").read_text(encoding="utf-8"))
    if manifest["channel"] != lane:
        raise SystemExit(f"{lane} manifest channel mismatch: {manifest}")
    if manifest["version"] != version:
        raise SystemExit(f"{lane} manifest version mismatch: {manifest}")
    if manifest["sourceCommit"] != source_commit:
        raise SystemExit(f"{lane} manifest sourceCommit mismatch: {manifest}")

    for forbidden in [
        "content/pages",
        "content/repo",
        "content/locales/en/README.md",
        "content/locales/en/CONTRIBUTING.md",
        "content/locales/en/LICENSE",
        "content/locales/ja/LICENSE",
        ".github/tools/rbxm-exporter/target",
        ".github/scripts/__pycache__",
        "release-notes",
    ]:
        if (root / forbidden).exists():
            raise SystemExit(f"{lane} still contains {forbidden}")

    changelog = (root / "CHANGELOG.md").read_text(encoding="utf-8")
    if "# Changelog" not in changelog:
        raise SystemExit(f"{lane} changelog was not generated")

publications = json.loads(publications_path.read_text(encoding="utf-8"))
if publications["release"]["version"] != "1.1.0":
    raise SystemExit("release publication version mismatch")
if publications["preRelease"]["version"] != "1.1.0-beta.2":
    raise SystemExit("pre-release publication version mismatch")

print("Publish workflow simulation OK")
PY

git --git-dir="$remote_path" rev-parse refs/heads/pre-release >/dev/null
git --git-dir="$remote_path" rev-parse refs/heads/release >/dev/null
git --git-dir="$remote_path" rev-parse refs/tags/v1.1.0-beta.2 >/dev/null
git --git-dir="$remote_path" rev-parse refs/tags/v1.1.0 >/dev/null

"$python_cmd" - "$remote_path" "$source_commit" <<'PY'
import json
import subprocess
import sys

remote_path = sys.argv[1]
source_commit = sys.argv[2]
expected_root = [".github", "CHANGELOG.md", "CONTRIBUTING.md", "LICENSE", "README.md", "content", "src"]


def git(*args: str) -> str:
    return subprocess.check_output(["git", f"--git-dir={remote_path}", *args], text=True).strip()


for lane, tag, version in [("pre-release", "v1.1.0-beta.2", "1.1.0-beta.2"), ("release", "v1.1.0", "1.1.0")]:
    branch_commit = git("rev-parse", f"refs/heads/{lane}")
    tag_commit = git("rev-parse", f"refs/tags/{tag}")
    if branch_commit != tag_commit:
        raise SystemExit(f"{tag} does not point at generated {lane} commit")

    root_names = sorted(git("ls-tree", "--name-only", f"refs/heads/{lane}").splitlines())
    if root_names != sorted(expected_root):
        raise SystemExit(f"{lane} remote root mismatch: {root_names}")

    manifest_text = git("show", f"refs/heads/{lane}:.github/publication.json")
    manifest = json.loads(manifest_text)
    if manifest["channel"] != lane:
        raise SystemExit(f"{lane} remote manifest channel mismatch: {manifest}")
    if manifest["version"] != version:
        raise SystemExit(f"{lane} remote manifest version mismatch: {manifest}")
    if manifest["sourceCommit"] != source_commit:
        raise SystemExit(f"{lane} remote manifest sourceCommit mismatch: {manifest}")

    commit_body = git("show", "-s", "--format=%B", f"refs/heads/{lane}")
    if f"Source commit: {source_commit}" not in commit_body:
        raise SystemExit(f"{lane} generated commit is missing source provenance")

    for forbidden in [
        ".generated",
        ".gitattributes",
        ".gitignore",
        ".vscode",
        "AGENTS.md",
        "docs",
        "tools",
        ".github/tools/rbxm-exporter/target",
        ".github/scripts/__pycache__",
    ]:
        result = subprocess.run(
            ["git", f"--git-dir={remote_path}", "cat-file", "-e", f"refs/heads/{lane}:{forbidden}"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        if result.returncode == 0:
            raise SystemExit(f"{lane} remote branch still contains {forbidden}")

print("Published branch and tag refs OK")
PY
