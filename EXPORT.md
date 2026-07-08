# TypeManager Export Checklist

This file tracks what the standalone GitHub repository should contain when TypeManager is exported as an independent package.

> [!NOTE]
> This is export setup, not runtime package API.

## Repository Shape

Current repository layout:

```txt
TypeManager/
  .github/
    ISSUE_TEMPLATE/
      bug_report.md
      feature_request.md
    workflows/
      ci.yml
    PULL_REQUEST_TEMPLATE.md
    FUNDING.yml
  src/
    init.luau
    InstanceTree/
    RuntimeLoaders/
  .gitignore
  Badges.md
  README.md
  CHANGELOG.md
  CONTRIBUTING.md
  LICENSE
  wiki/
```

> [!TIP]
> Repository metadata lives at the root. Runtime/analyzer-facing Luau source lives under `src/`.

## GitHub Metadata

Repository about text:

```txt
Analyzer-facing type helpers for Luau/Roblox package surfaces.
```

Suggested topics:

```txt
luau
roblox
types
type-functions
static-analysis
packages
```

Initial release title:

```txt
TypeManager 0.1.0
```

> [!WARNING]
> Do not publish a semver-stable `1.0.0` until analyzer parity and extraction behavior are confirmed outside the development workspace.

## GitHub Wiki

Prepare the standalone repository wiki from:

```txt
wiki/
```

Live wiki:

```txt
https://github.com/Kooraseru/TypeManager/wiki
```

Suggested wiki pages:

```txt
Home.md
Install.md
Analyzer-Model.md
Type-Functions.md
Runtime-Loaders.md
Package-Boundaries.md
Export-And-CI.md
FAQ.md
```

> [!TIP]
> Keep README focused on install, quick start, and API. Put the longer explanations, analyzer caveats, and package-authoring recipes in the package-local `wiki/` folder before pushing them to GitHub's wiki remote.

## CI Expectations

CI should check:

```txt
Luau analysis for package files
no rooted game-specific requires
no `any` or casts in public package surfaces
no dynamic require outside RuntimeLoaders
README examples remain analyzer-valid where possible
```

Minimum workflow jobs:

```txt
lint markdown/package metadata
run Luau analyzer
run architecture/rules validator
run extraction smoke test
```

> [!IMPORTANT]
> The exported repository needs its own tooling story. Do not rely on a development workspace's `tools/` path unless the export process copies the needed tools too.

## Extraction Smoke Test

Before release:

```txt
copy package into .tmp/package-extraction/TypeManager
run analyzer on copied package
verify root facade require works
verify focused module require works
verify ChildNames/ChildRecord examples compile
verify no rooted game-specific require paths exist
```

## GitHub Templates

`.github/` is already package-local and should live at the standalone repository root.

Issue templates should ask for:

```txt
Luau analyzer version
Roblox Studio/LSP environment
install layout
minimal instance tree
expected type result
actual diagnostic/result
```

Pull request template should ask for:

```txt
changed helper/function
analyzer behavior proved
focused validation command
package boundary impact
docs updated
```

## Release Blockers

```txt
external analyzer parity tested
package extraction smoke test passing
README quick start validated outside the development workspace
CI workflow runs real Luau analysis instead of the placeholder job
```
