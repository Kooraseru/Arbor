#!/usr/bin/env bash
set -euo pipefail

publication_path="${1:?publication payload path is required}"
remote_url="${2:?remote URL is required}"
channel="${3:?channel is required}"
version="${4:?version is required}"
source_commit="${5:?source commit SHA is required}"
tag="${6:?tag is required}"

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

if [[ ! "$tag" =~ ^v[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z][0-9A-Za-z.-]*)?$ ]]; then
	echo "tag must look like v1.1.0 or v1.1.0-beta.2: $tag" >&2
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
git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

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
git commit -m "Generate Arbor $channel $tag" -m "Source commit: $source_commit"

if [ "$branch_exists" = "true" ]; then
	git push --quiet origin "HEAD:refs/heads/$channel" --force-with-lease
else
	git push --quiet origin "HEAD:refs/heads/$channel" --force
fi

git fetch --quiet origin "$channel" --depth=1
generated_commit="$(git rev-parse "origin/$channel")"

if git ls-remote --exit-code --tags origin "refs/tags/$tag" >/dev/null 2>&1; then
	git push --quiet origin --delete "$tag"
fi

if git rev-parse --verify --quiet "refs/tags/$tag" >/dev/null; then
	git tag -d "$tag" >/dev/null
fi

git -c tag.gpgSign=false tag "$tag" "$generated_commit"
git push --quiet origin "refs/tags/$tag:refs/tags/$tag"

echo "Published $channel $tag at generated commit $generated_commit from source $source_commit"
