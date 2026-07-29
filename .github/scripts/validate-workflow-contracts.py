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
    validate = Path(".github/workflows/validate.yml").read_text(encoding="utf-8")
    generated_branch_publisher = Path(".github/scripts/publish-generated-branch.sh").read_text(encoding="utf-8")
    release_note_versions = sorted(path.stem.removeprefix("v") for path in Path("release-notes").glob("v*.toml"))

    require(publish, r"name:\s+Publish", "Publish workflow name")
    require(publish, r"actions:\s+write", "Publish can dispatch Pages with GITHUB_TOKEN")
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
    require(publish, r"Missing RELEASE_SIGNING_KEY environment secret", "Publish missing release signing key message")
    require(publish, r"git fetch origin source:refs/remotes/origin/source", "Publish source branch containment fetch")
    require(publish, r"git branch -r --contains \"\$source_commit\"", "Publish source commit containment check")
    require(publish, r"release-notes/v\$VERSION\.toml", "Publish selected version must have release notes")
    require(publish, r"build-publication-payload\.sh", "Publish shared payload builder")
    require(publish, r"\.generated/repo/\$CHANNEL", "Publish generated branch payload path")
    require(publish, r"publish-generated-branch\.sh", "Publish shared branch/tag publisher")
    require(publish, r"name:\s+Configure release signing", "Publish configures release signing")
    require(publish, r"gpg --batch --import", "Publish imports release signing key")
    require(publish, r"user\.name \"Kooraseru\"", "Publish uses maintainer commit identity")
    require(publish, r"user\.email \"kooraseru\.social@gmail\.com\"", "Publish uses maintainer commit email")
    require(publish, r"user\.signingkey \"2043BE65B39C7DC5\"", "Publish uses maintainer signing key")
    require(publish, r"commit\.gpgsign true", "Publish signs generated commits")
    require(publish, r"tag\.gpgSign true", "Publish signs generated tags")
    require(publish, r"id:\s+generated", "Publish captures generated branch commit")
    require(publish, r"name:\s+Replace GitHub Release", "Publish replaces GitHub Release")
    require(publish, r"GENERATED_COMMIT: \$\{\{ steps\.generated\.outputs\.generated_commit \}\}", "Publish consumes generated branch commit")
    require(publish, r"release_label_args=\(\)", "Publish selects GitHub Release label arguments")
    require(publish, r"release_label_args=\(--draft=false --prerelease --latest=false\)", "Publish atomically publishes pre-release GitHub Releases")
    require(publish, r"release_label_args=\(--draft=false --prerelease=false --latest\)", "Publish atomically publishes stable GitHub Releases")
    require(publish, r"export-rbxm\.sh src/arbor@1\.1\.0", "Publish exports versioned Arbor package root")
    require(publish, r"gh release view \"\$tag\"", "Publish checks for an existing GitHub Release")
    require(publish, r"gh release delete \"\$tag\" --yes", "Publish deletes an existing GitHub Release")
    require(publish, r"git ls-remote --exit-code --tags \"\$remote_url\" \"refs/tags/\$tag\"", "Publish checks for an existing release tag")
    require(publish, r"git push --quiet \"\$remote_url\" \":refs/tags/\$tag\"", "Publish deletes an existing release tag")
    require(publish, r"gh release create \"\$tag\" \"\$asset_path\"", "Publish creates release with generated asset")
    require(publish, r"--verify-tag", "Publish requires the signed tag before release creation")
    require(publish, r"git fetch \"\$remote_url\" \"refs/heads/\$CHANNEL\" --depth=1", "Publish fetches generated commit before tagging")
    require(publish, r"git cat-file -e \"\$GENERATED_COMMIT\^\{commit\}\"", "Publish verifies generated commit object before tagging")
    require(publish, r"git verify-commit \"\$GENERATED_COMMIT\"", "Publish verifies generated commit signature before release")
    require(publish, r"git tag -s -m \"\$tag\" \"\$tag\" \"\$GENERATED_COMMIT\"", "Publish recreates release tags as signed annotated tags")
    require(publish, r"git verify-tag \"\$tag\"", "Publish verifies signed release tag before pushing")
    if "gh release edit" in publish or "gh release upload" in publish:
        raise SystemExit("Workflow contract violation: Publish must replace releases instead of mutating existing records")
    replacement_order = [
        'gh release view "$tag"',
        'gh release delete "$tag" --yes',
        'git ls-remote --exit-code --tags "$remote_url" "refs/tags/$tag"',
        'git push --quiet "$remote_url" ":refs/tags/$tag"',
        'git tag -s -m "$tag" "$tag" "$GENERATED_COMMIT"',
        'git push --quiet "$remote_url" "refs/tags/$tag:refs/tags/$tag"',
        'gh release create "$tag" "$asset_path"',
    ]
    replacement_positions = [publish.index(command) for command in replacement_order]
    if replacement_positions != sorted(replacement_positions):
        raise SystemExit("Workflow contract violation: Publish release replacement steps are out of order")
    require(publish, r"gh workflow run pages\.yml --ref source", "Publish refreshes Pages from source workflow")
    require(publish, r"GH_TOKEN: \$\{\{ github\.token \}\}", "Publish dispatches Pages with GITHUB_TOKEN")
    require(publish, r"TOKEN: \$\{\{ secrets\.RELEASE_TOKEN \}\}", "Publish requires RELEASE_TOKEN")
    if re.search(r"^\s+TOKEN:\s+\$\{\{\s*github\.token\s*\}\}", publish, re.MULTILINE):
        raise SystemExit("Workflow contract violation: Publish must not use github.token for branch/tag publishing")
    if not re.search(r"^\s+GH_TOKEN:\s+\$\{\{\s*github\.token\s*\}\}", publish, re.MULTILINE):
        raise SystemExit("Workflow contract violation: Publish may only use github.token for Pages workflow_dispatch")
    require(generated_branch_publisher, r"Source commit: \$source_commit", "Publish generated commit provenance")
    require(generated_branch_publisher, r"Git user\.name and user\.email must be configured", "Publish generated branch refuses missing git identity")
    require(generated_branch_publisher, r"generated_commit=.*git rev-parse", "Publish generated branch resolves generated commit")
    require(generated_branch_publisher, r"generated_commit=\$generated_commit", "Publish generated branch writes generated commit output")
    if "refs/tags" in generated_branch_publisher or "git tag" in generated_branch_publisher:
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

    require(validate, r"name:\s+Validate", "Validate workflow name")
    require(validate, r"pull_request:", "Validate runs for pull requests")
    require(validate, r"push:\s*\n\s+branches:\s*\n\s+- source", "Validate runs for source pushes")
    require(validate, r"name:\s+Tooling Contracts", "Validate tooling stage")
    require(validate, r"name:\s+Package Build", "Validate package build stage")
    require(validate, r"name:\s+Documentation Build", "Validate documentation build stage")
    require(validate, r"name:\s+Luau Analysis", "Validate Luau analysis stage")
    require(validate, r"name:\s+Install Luau LSP", "Validate installs Luau LSP before analysis")
    require(validate, r'LUAU_LSP_VERSION:\s+"1\.66\.0"', "Validate pins the Luau LSP version")
    require(validate, r"luau-lsp-win64\.zip", "Validate installs the Windows Luau LSP binary")
    require(validate, r"python tools/test-generate-facade\.py", "Validate owns facade generation tests")
    require(validate, r"python \.github/scripts/validate-python-scripts\.py", "Validate owns Python syntax validation")
    require(validate, r"python \.github/scripts/validate-workflow-contracts\.py", "Validate owns workflow contract validation")
    require(validate, r"bash \.github/scripts/export-rbxm\.sh src/arbor@1\.1\.0", "Validate owns package export validation")
    require(validate, r"python \.github/scripts/run-mkdocs\.py build", "Validate owns docs build validation")
    require(validate, r"\.github/scripts/analyze-luau\.ps1", "Validate owns Luau analyzer validation")
    if "ref: source" in validate:
        raise SystemExit("Workflow contract violation: Validate must check the current commit, not hardcoded source")

    print("Workflow contracts OK")


if __name__ == "__main__":
    main()
