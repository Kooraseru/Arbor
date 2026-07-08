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

## Version Slots

```txt
[core release].[implementation].[bug-fix/patch]
```

Core release `1` is the initial Arbor public package line. Increment the implementation slot when adding package surface. Increment the patch slot for fixes within that implementation.

## Pages

The GitHub Pages site is built from `docs/`.
