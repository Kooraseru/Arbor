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
package RBXM export passes
```

CI runs on:

```txt
main
canary
ci
```

GitHub Pages and public commit releases run from `main` only.

## RBXM Export

The RBXM export packages `src/` as a top-level `ModuleScript` named `Arbor`.

It intentionally does not include `examples/`. The examples are repository fixtures with their own analyzer context, and bundling them under the exported package would change their path assumptions.

Run the local export before wiring release artifacts:

=== "Windows PowerShell"

    ```powershell
    bash .github/scripts/export-rbxm.sh
    ```

=== "Linux Bash"

    ```bash
    bash .github/scripts/export-rbxm.sh
    ```

=== "macOS Bash/Zsh"

    ```bash
    bash .github/scripts/export-rbxm.sh
    ```

The generated model is written to `.tmp/rbxm-export/result/Arbor.rbxm`. The exporter writes the model with `rbx_dom_weak` and `rbx_binary`, then reads it back to verify the root shape.

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
