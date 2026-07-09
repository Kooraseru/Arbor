---
title: Export And CI
---

# Export And CI

## Repository Shape

```txt
Arbor/
  src/
    init.luau
    InstanceTree/
    RuntimeLoaders/
  docs/
  README.md
  CHANGELOG.md
  CONTRIBUTING.md
  LICENSE
```

## CI Checks

CI should verify:

```txt
Luau analysis passes
no game-rooted require aliases
no high-risk any casts
README examples are still plausible
package extraction smoke test passes
```

CI runs on:

```txt
main
canary
ci
```

GitHub Pages and public commit releases run from `main` only.

## Version Slots

```txt
[core release].[implementation].[bug-fix/patch]
```

Core release `1` is the initial Arbor public package line. Increment the implementation slot when adding package surface. Increment the patch slot for fixes within that implementation.

## Pages

The GitHub Pages site is built from `docs/`.

The Pages workflow deploys through the `github-pages` environment. If GitHub rejects a deployment with an environment protection message, update the repository environment rules:

```txt
Settings -> Environments -> github-pages -> Deployment branches and tags
```

Allow `main`, or remove the selected-branch restriction for that environment.
