#!/usr/bin/env bash
set -euo pipefail

publication_path="${1:?publication payload path is required}"
remote_url="${2:?remote URL is required}"
channel="${3:?channel is required}"
version="${4:?version is required}"
source_commit="${5:?source commit SHA is required}"
github_output="${6:-}"

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

if [ ! -d "$publication_path" ]; then
	echo "Missing publication payload path: $publication_path" >&2
	exit 1
fi

publication_path="$(cd -- "$publication_path" && pwd)"

worktree_path="$(mktemp -d)"

cleanup() {
	rm -rf -- "$worktree_path"
}

trap cleanup EXIT

git clone --quiet --no-checkout "$remote_url" "$worktree_path"
cd "$worktree_path"

if [ -z "$(git config user.name || true)" ] || [ -z "$(git config user.email || true)" ]; then
	echo "Git user.name and user.email must be configured before publishing generated branches." >&2
	exit 1
fi

if git ls-remote --exit-code origin "refs/heads/$channel" >/dev/null 2>&1; then
	branch_exists=true
	git fetch --quiet origin "$channel"
	git checkout --quiet --orphan "generated-$channel" "origin/$channel"
else
	branch_exists=false
	git checkout --quiet --orphan "generated-$channel"
fi

git rm -rf . >/dev/null 2>&1 || true
find . -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
cp -R "$publication_path"/. .

git add -A
git commit -m "Generate Arbor $channel $version" -m "Source commit: $source_commit"

if [ "$branch_exists" = "true" ]; then
	git push --quiet origin "HEAD:refs/heads/$channel" --force-with-lease
else
	git push --quiet origin "HEAD:refs/heads/$channel" --force
fi

git fetch --quiet origin "$channel" --depth=1
generated_commit="$(git rev-parse "origin/$channel")"

if [ -n "$github_output" ]; then
	echo "generated_commit=$generated_commit" >> "$github_output"
fi

echo "Published $channel $version at generated commit $generated_commit from source $source_commit"
