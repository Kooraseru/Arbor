#!/usr/bin/env python3
from __future__ import annotations

import re
from pathlib import Path


def require(text: str, pattern: str, description: str, *, flags: int = 0) -> None:
    if not re.search(pattern, text, flags):
        raise SystemExit(f"Workflow contract missing: {description}")


def main() -> None:
    publish = Path(".github/workflows/publish.yml").read_text(encoding="utf-8")
    pages = Path(".github/workflows/pages.yml").read_text(encoding="utf-8")
    generated_branch_publisher = Path(".github/scripts/publish-generated-branch.sh").read_text(encoding="utf-8")

    require(publish, r"name:\s+Publish", "Publish workflow name")
    require(publish, r"workflow_dispatch:", "Publish manual dispatch")
    require(publish, r"channel:\s*\n(?:.*\n){0,8}\s+- pre-release\s*\n\s+- release", "Publish channel choices")
    require(publish, r"source_ref:", "Publish source_ref input")
    require(publish, r"if \[ \"\$GITHUB_REF_NAME\" != \"source\" \]", "Publish source dispatch guard")
    require(publish, r"git fetch origin source:refs/remotes/origin/source", "Publish source branch containment fetch")
    require(publish, r"git branch -r --contains \"\$source_commit\"", "Publish source commit containment check")
    require(publish, r"build-publication-payload\.sh", "Publish shared payload builder")
    require(publish, r"\.generated/repo/\$CHANNEL", "Publish generated branch payload path")
    require(publish, r"publish-generated-branch\.sh", "Publish shared branch/tag publisher")
    require(publish, r"TOKEN: \$\{\{ secrets\.RELEASE_TOKEN \}\}", "Publish requires RELEASE_TOKEN")
    if "github.token" in publish:
        raise SystemExit("Workflow contract violation: Publish must not fall back to github.token")
    require(generated_branch_publisher, r"Source commit: \$source_commit", "Publish generated commit provenance")
    require(generated_branch_publisher, r"git -c tag\.gpgSign=false tag \"\$tag\" \"\$generated_commit\"", "Published tag points at generated commit with unsigned lightweight tag")
    require(publish, r"\"v\$VERSION\"", "Publish tag uses version tag")

    require(pages, r"name:\s+Pages", "Pages workflow name")
    require(pages, r"branches:\s*\n\s+- source\s*\n\s+- pre-release\s*\n\s+- release", "Pages branch triggers")
    require(pages, r"collect-publication-manifests\.py", "Pages manifest collector")
    require(pages, r"publication-release/\.github/publication\.json", "Pages release manifest read")
    require(pages, r"publication-pre-release/\.github/publication\.json", "Pages pre-release manifest read")
    require(pages, r"steps\.manifests\.outputs\.release_source_commit \|\| 'source'", "Pages release fallback to source")
    require(pages, r"steps\.manifests\.outputs\.pre_release_source_commit != ''", "Pages pre-release manifest guard")
    require(pages, r"site_dir=\"\$GITHUB_WORKSPACE/_site/pre-release\"", "Pages pre-release default language output")
    require(pages, r"site_dir=\"\$GITHUB_WORKSPACE/_site/pre-release/\$language\"", "Pages pre-release localized language output")

    print("Workflow contracts OK")


if __name__ == "__main__":
    main()
