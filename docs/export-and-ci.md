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

The GitHub Pages site is built from `docs/` with MkDocs Material.

Run the local Pages workflow shape before pushing docs workflow changes:

=== "Windows PowerShell"

    ```powershell
    bash .github/scripts/test-pages-workflow.sh
    ```

=== "Linux Bash"

    ```bash
    bash .github/scripts/test-pages-workflow.sh
    ```

=== "macOS Bash/Zsh"

    ```bash
    bash .github/scripts/test-pages-workflow.sh
    ```

The local check stages branch inputs under `.tmp/pages-workflow-test/workspace` and writes the simulated Pages artifact under `.tmp/pages-workflow-test/result`.

The Pages workflow deploys through the `github-pages` environment. If GitHub rejects a deployment with an environment protection message, update the repository environment rules:

```txt
Settings -> Environments -> github-pages -> Deployment branches and tags
```

Allow `main`, or remove the selected-branch restriction for that environment.
