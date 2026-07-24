---
title: パッケージ抽出
---

# パッケージ抽出

## 問題

Arbor は通常、パッケージフォルダーが Roblox 向けのパッケージ場所へエクスポートまたはコピーされたあとに使われます。

重要なのは、抽出後もパッケージが同じ公開ルート形状を保っているかどうかです。

## ソース

```md title="content/jp/examples/extracted-package/README.md"
--8<-- "content/jp/examples/extracted-package/README.md"
```

## 結果

エクスポート済みパッケージのルートは、`Arbor` という名前の `ModuleScript` です：

```txt title="エクスポート済みモデル"
Arbor
  InstanceTree
    ChildNames
    ChildNamesOfClass
    ChildOf
    ChildRecord
    ChildrenOfClass
  RuntimeLoaders
    LoadModuleMap
```

利用側はパッケージルートから Arbor を `require` します：

```lua
local Arbor = require(path.to.Arbor)
```

## なぜ動くのか

エクスポーターは `src/init.luau` をルートモジュールとして扱い、パッケージ名をルートインスタンス名として使います。子フォルダーとモジュールは、そのパッケージルートの下に残ります。

`src/` はリポジトリ内のソースフォルダーです。エクスポート後のパッケージルートとして現れるべきではありません。

## 証明しないこと

パッケージ抽出だけでは、アナライザーからの可視性は証明されません。

使う側のワークスペースには、抽出済みパッケージツリーを Luau に公開する sourcemap、プラグインモデル、または別のアナライザーから見える データモデル が引き続き必要です。

例は意図的に RBXM パッケージへバンドルしません。例は、それぞれ固有のアナライザーコンテキストを持つリポジトリフィクスチャです。
