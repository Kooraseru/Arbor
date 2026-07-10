---
title: Exporting Packages
---

# Exporting Packages

Arbor can export the package source as an RBXM model.

Run:

```bash
bash .github/scripts/export-rbxm.sh
```

The result is:

```txt
.tmp/results/export/rbxm-export/result/Arbor.rbxm
```

## Export Shape

```txt
Arbor
  InstanceTree
  RuntimeLoaders
```

`src/init.luau` becomes the root `ModuleScript` named `Arbor`. The folder name `src` is not part of the exported model.

Examples are not bundled. They are analyzer fixtures and documentation source material, not package runtime contents.
