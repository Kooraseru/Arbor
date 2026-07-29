#!/usr/bin/env python3
from __future__ import annotations

import re
from pathlib import Path


def require(text: str, pattern: str, description: str, *, flags: int = 0) -> None:
    if not re.search(pattern, text, flags):
        raise SystemExit(f"Workflow contract missing: {description}")


def workflow_choice_options(text: str, input_name: str) -> list[str]:
    match = re.search(rf"^\s{{6}}{re.escape(input_name)}:\n(?P<body>(?:^\s{{8,}}.*\n)+)", text, re.MULTILINE)
    if not match:
        raise SystemExit(f"Workflow contract missing: {input_name} input")

    return re.findall(r"^\s{10}-\s+(.+?)\s*$", match.group("body"), re.MULTILINE)


def main() -> None:
    publish = Path(".github/workflows/publish.yml").read_text(encoding="utf-8")
    pages = Path(".github/workflows/pages.yml").read_text(encoding="utf-8")
    generated_branch_publisher = Path(".github/scripts/publish-generated-branch.sh").read_text(encoding="utf-8")
    release_note_versions = sorted(path.stem.removeprefix("v") for path in Path("release-notes").glob("v*.toml"))

    require(publish, r"name:\s+Publish", "Publish workflow name")
    require(publish, r"environment:\s+release", "Publish job uses release environment")
    require(publish, r"workflow_dispatch:", "Publish manual dispatch")
    require(publish, r"channel:\s*\n(?:.*\n){0,8}\s+- pre-release\s*\n\s+- release", "Publish channel choices")
    require(publish, r"version:\s*\n(?:.*\n){0,8}\s+type:\s+choice", "Publish version dropdown")
    version_choices = workflow_choice_options(publish, "version")
    if version_choices != release_note_versions:
        raise SystemExit(
            "Workflow contract violation: Publish version choices must match "
            f"release-notes/v*.toml; expected {release_note_versions}, got {version_choices}"
        )
    if "source_ref" in publish:
        raise SystemExit("Workflow contract violation: Publish must not expose source_ref")
    require(publish, r"ref:\s+source", "Publish checks out source directly")
    require(publish, r"if \[ \"\$GITHUB_REF_NAME\" != \"source\" \]", "Publish source dispatch guard")
    require(publish, r"name:\s+Require release token", "Publish early release token preflight")
    require(publish, r"Missing RELEASE_TOKEN repository secret", "Publish missing release token message")
    require(publish, r"git fetch origin source:refs/remotes/origin/source", "Publish source branch containment fetch")
    require(publish, r"git branch -r --contains \"\$source_commit\"", "Publish source commit containment check")
    require(publish, r"release-notes/v\$VERSION\.toml", "Publish selected version must have release notes")
    require(publish, r"build-publication-payload\.sh", "Publish shared payload builder")
    require(publish, r"\.generated/repo/\$CHANNEL", "Publish generated branch payload path")
    require(publish, r"publish-generated-branch\.sh", "Publish shared branch/tag publisher")
    require(publish, r"id:\s+generated", "Publish captures generated branch commit")
    require(publish, r"name:\s+Create or update GitHub Release", "Publish creates or updates GitHub Release")
    require(publish, r"GENERATED_COMMIT: \$\{\{ steps\.generated\.outputs\.generated_commit \}\}", "Publish consumes generated branch commit")
    require(publish, r"release_label_args=\(\)", "Publish selects GitHub Release label arguments")
    require(publish, r"release_label_args=\(--prerelease\)", "Publish labels pre-release GitHub Releases")
    require(publish, r"release_label_args=\(--latest\)", "Publish labels stable GitHub Releases as latest")
    require(publish, r"export-rbxm\.sh src/arbor@1\.1\.0", "Publish exports versioned Arbor package root")
    require(publish, r"gh release edit \"\$tag\"", "Publish edits existing GitHub Release")
    require(publish, r"gh release upload \"\$tag\" \"\$asset_path\" --clobber", "Publish overwrites generated release asset")
    require(publish, r"gh release create \"\$tag\" \"\$asset_path\"", "Publish creates release with generated asset")
    require(publish, r"--target \"\$GENERATED_COMMIT\"", "Publish creates missing release tag at generated commit")
    require(publish, r"git -c tag\.gpgSign=false tag \"\$tag\" \"\$GENERATED_COMMIT\"", "Publish recreates existing release tag after release update")
    require(publish, r"gh workflow run pages\.yml --ref source", "Publish refreshes Pages from source workflow")
    require(publish, r"TOKEN: \$\{\{ secrets\.RELEASE_TOKEN \}\}", "Publish requires RELEASE_TOKEN")
    if "github.token" in publish:
        raise SystemExit("Workflow contract violation: Publish must not fall back to github.token")
    require(generated_branch_publisher, r"Source commit: \$source_commit", "Publish generated commit provenance")
    require(generated_branch_publisher, r"generated_commit=.*git rev-parse", "Publish generated branch resolves generated commit")
    require(generated_branch_publisher, r"generated_commit=\$generated_commit", "Publish generated branch writes generated commit output")
    if "refs/tags" in generated_branch_publisher or "git -c tag.gpgSign=false tag" in generated_branch_publisher:
        raise SystemExit("Workflow contract violation: generated branch publisher must not create release tags")
    require(publish, r"\"v\$VERSION\"", "Publish tag uses version tag")

    require(pages, r"name:\s+Pages", "Pages workflow name")
    require(pages, r"branches:\s*\n\s+- source\s*(?:\n\s+paths:|\n)", "Pages only runs from source branch pushes")
    if re.search(r"branches:\s*\n(?:\s+- .+\n)*\s+- (?:pre-release|release)", pages):
        raise SystemExit("Workflow contract violation: Pages must not run from generated branch pushes")
    require(pages, r"collect-publication-manifests\.py", "Pages manifest collector")
    require(pages, r"name:\s+Fetch publication metadata", "Pages fetches optional generated branch metadata without checkout retries")
    require(pages, r"git ls-remote --exit-code --heads \"\$remote_url\" \"\$branch\"", "Pages checks optional generated branch existence")
    require(pages, r"No generated \$branch branch yet; skipping publication metadata", "Pages skips missing generated branches")
    require(pages, r"publication-release/\.github/publication\.json", "Pages release manifest read")
    require(pages, r"publication-pre-release/\.github/publication\.json", "Pages pre-release manifest read")
    require(pages, r"steps\.manifests\.outputs\.release_source_commit \|\| 'source'", "Pages release fallback to source")
    require(pages, r"steps\.manifests\.outputs\.pre_release_source_commit != ''", "Pages pre-release manifest guard")
    require(pages, r"site_dir=\"\$GITHUB_WORKSPACE/_site/pre-release\"", "Pages pre-release default language output")
    require(pages, r"site_dir=\"\$GITHUB_WORKSPACE/_site/pre-release/\$language\"", "Pages pre-release localized language output")

    print("Workflow contracts OK")


if __name__ == "__main__":
    main()
