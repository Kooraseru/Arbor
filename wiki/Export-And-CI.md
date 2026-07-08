# Export And CI

## Standalone Repository Shape

Recommended simple layout:

```txt
Arbor/
  src/
    init.luau
    InstanceTree/
    RuntimeLoaders/
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
no high-risk `any` casts
README examples are still plausible
package extraction smoke test passes
```

## Release Policy

Use the package version slots:

```txt
[core release].[implementation].[bug-fix/patch]
```

Core release `1` is the initial Arbor public package line. Increment the implementation slot when adding package surface. Increment the patch slot for fixes within that implementation.

## Wiki Publishing

GitHub stores wiki pages in a separate repository:

```txt
Kooraseru/Arbor.wiki.git
```

The package includes `.github/workflows/sync-wiki.yml` to publish package-local `wiki/*.md` pages there.

The workflow:

```txt
runs on wiki changes pushed to main or master
can be run manually from GitHub Actions
skips wiki/README.md
pushes only when generated wiki contents changed
```
