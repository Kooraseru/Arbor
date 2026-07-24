---
title: Export And CI
---

# Export And CI

## Repository Shape

```txt
Arbor/
  src/
    arbor@1.1.0/
    examples/
    plugin/
  content/
    assets/
    locales/
      en/
        README.md
        CONTRIBUTING.md
        LICENSE
        wiki/
        examples/
      outdated/
        jp/
  release-notes/
  docs/
    knowledge/
```

The `source` branch is the authoring environment. Generated publication
branches may place README, license, package artifacts, and other user-facing
files at different paths.

`CHANGELOG.md` is generated package-history output from release notes. It is
emitted into `.generated-preview/` or publication output, not authored on
`source`.

## CI Checks

CI should verify:

```txt
Luau analysis passes
no game-rooted require aliases
no high-risk any casts
localized README and current source examples are still plausible
package extraction smoke test passes
package RBXM export passes
```

Local validation currently runs against:

```txt
source
```

GitHub Actions are disabled while Arbor's `source`/`preview`/`release`
publication model is redesigned.

## RBXM Export

The RBXM export packages `src/` as a top-level `ModuleScript` named `Arbor`.

It intentionally does not include `content/locales/en/examples/`. Those examples are repository fixtures with their own analyzer context, and bundling them under the exported package would change their path assumptions.

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

The generated model is written to `.generated-preview/results/export/rbxm-export/result/Arbor.rbxm`. The exporter writes the model with `rbx_dom_weak` and `rbx_binary`, then reads it back to verify the root shape.

## Release Notes

Release notes are Markdown files:

```txt
release-notes/Stable/v1.0.1.md
release-notes/Pre-release/v1.1.0-canary.1.md
```

Stable release notes are the source for stable GitHub release bodies. The
generated changelog summarizes package history from release notes, but release
notes remain the source for release communication.

Pre-release notes are preview release communication. They use the public
`Pre-release` channel name even when the branch or tag suffix is `canary`.

## Version Tags

```txt
v1.<release>.<patch>
v1.<release>.<patch>-canary.N
```

Only package changes create package versions. Documentation, workflow, examples,
media, and repository maintenance do not create package versions by themselves.

Stable releases attach:

```txt
Arbor.rbxm
```

GitHub automatically provides source-code archives for each release tag, so the
release workflow does not upload duplicate `src.zip` or `src.tar.gz` assets.

If a GitHub release already exists for the same version tag, the release
workflow replaces that release entry and uploads fresh assets for the same tag.
The tag is the package version; replacement is only for refreshing the GitHub
release body and downloadable artifacts attached to that tag.

## Pages

The GitHub Pages site is built from `content/locales/en/wiki/` with MkDocs
Material.

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

The local check stages branch inputs under `.generated-preview/pages/pages-workflow-test/workspace` and writes the simulated Pages artifact under `.generated-preview/pages/pages-workflow-test/result`.

The Pages workflow deploys through the `github-pages` environment. If GitHub rejects a deployment with an environment protection message, update the repository environment rules:

```txt
Settings -> Environments -> github-pages -> Deployment branches and tags
```

Allow `release`, or remove the selected-branch restriction for that environment.
