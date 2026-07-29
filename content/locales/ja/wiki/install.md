---
title: インストール
---

# インストール

プロジェクトやパッケージマネージャーから必要なモジュールを参照できる場所に、`Arbor` を置きます。

使っている環境のモジュール参照を通して、パッケージルートを `require` します。

```lua
local Arbor = require(path.to.Arbor)
```

## パッケージ要件

Arbor に必須の peer package dependency はありません。

実行するために Registry、Bootstrap、Wally、Pesde、source-map generator、別の Arbor パッケージは必要ありません。

## アナライザーから見えるための条件

Arbor の型 helper が公開できるのは、使っている Luau アナライザーからすでに見えている子だけです。

アナライザーから `script.Kick` が見えているなら、Arbor はその子を型レベルの情報へ変えられます。

```lua
export type ActionId = Arbor.ChildNames<typeof(script)>
```

アナライザーから `script.Kick` が見えなければ、Arbor が型レベルで `"Kick"` を作り出すことはできません。

## おすすめのツール

ローカルエディターでの feedback と、再現できる analyzer check が必要なら `luau-lsp` を使ってください。

アナライザーから見えるツリーは、いくつかの toolchain から提供できます。

- luau-lsp の package または plugin data model
- Roblox ツリーを Luau に見せる別の source-map / data-model provider

その provider はアナライザー設定の一部であり、Arbor のランタイム依存ではありません。

## 公開エントリーポイント

公開 API にはルートファサードを使います。

```lua
local Arbor = require(path.to.Arbor)
```

ルートファサードは、[API リファレンス](api/index.md) にある正式なランタイム関数と型エイリアスを export します。

`Definitions`、`Runtime`、`RuntimeLoaders`、`Authoring`、`Mold`、`Run` などの下位 source folder は、ファサードをきれいに生成・分割するためにあります。すべての source file を安定した `require` path として扱わないでください。

## 次に読むもの

- [アナライザーモデル](analyzer-model.md)
- [型チェック](guides/typechecking.md)
- [API リファレンス](api/index.md)
