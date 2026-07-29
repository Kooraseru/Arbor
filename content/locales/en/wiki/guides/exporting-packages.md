---
title: "Exporting Packages"
---

# Exporting Packages

Arbor can export the package source as an RBXM model.

Run:

```bash
bash .github/scripts/export-rbxm.sh
```

The result is:

```txt
.generated/shared/export/rbxm-export/result/Arbor.rbxm
```

## Export Shape

```txt
Arbor
  Authoring
  Definitions
  Runtime
  RuntimeLoaders
```

`src/arbor@1.1.0/init.luau` becomes the root `ModuleScript` named `Arbor`. The folder name `src` and the versioned source folder name are not part of the exported model.

Repository-only source is not bundled. Generated package artifacts contain the public Arbor package, not maintainer tooling or documentation source material.
