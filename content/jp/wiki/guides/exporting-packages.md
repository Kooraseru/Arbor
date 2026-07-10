---
title: パッケージをエクスポートする
---

# パッケージをエクスポートする

Arbor は、パッケージソースを RBXM モデルとしてエクスポートできます。

実行：

```bash
bash .github/scripts/export-rbxm.sh
```

結果はここに作られます：

```txt
.tmp/results/export/rbxm-export/result/Arbor.rbxm
```

## エクスポート形状

```txt
Arbor
  InstanceTree
  RuntimeLoaders
```

`src/init.luau` は、`Arbor` という名前のルート `ModuleScript` になります。フォルダー名の `src` は、エクスポート済みモデルには含まれません。

例はバンドルされません。例はアナライザーフィクスチャであり、ドキュメントのソース素材です。パッケージのランタイム内容ではありません。
