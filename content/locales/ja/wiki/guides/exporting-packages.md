---
title: "パッケージの export"
---

# パッケージの export

Arbor は、パッケージソースを RBXM model として export できます。

実行:

```bash
bash .github/scripts/export-rbxm.sh
```

結果:

```txt
.generated/shared/export/rbxm-export/result/Arbor.rbxm
```

## Export される形

```txt
Arbor
  Authoring
  Definitions
  Runtime
  RuntimeLoaders
```

`src/arbor@1.1.0/init.luau` は、`Arbor` という名前のルート `ModuleScript` になります。folder 名の `src` と、バージョンつき source folder 名は export した model に入りません。

例は bundle しません。アナライザー用 fixture とドキュメント用 source であり、パッケージのランタイム内容ではありません。
