# Export And CI

## Standalone Repository Shape

Recommended simple layout:

```txt
TypeManager/
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

Use `0.x` while analyzer and extraction behavior are still being confirmed.

> [!WARNING]
> Do not release `1.0.0` until TypeManager behavior is proven in the target install and analyzer environments.

## Wiki Publishing

GitHub stores wiki pages in a separate repository:

```txt
Kooraseru/TypeManager.wiki.git
```

The package includes `.github/workflows/sync-wiki.yml` to publish package-local `wiki/*.md` pages there.

The workflow:

```txt
runs on wiki changes pushed to main
can be run manually from GitHub Actions
skips wiki/README.md
pushes only when generated wiki contents changed
```
