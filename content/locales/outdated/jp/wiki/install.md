---
title: インストール
---

# インストール

プロジェクトやパッケージマネージャーから必要なモジュールとして公開できる場所に、`Arbor` を置いてください。

環境が提供するモジュール参照を使って、パッケージルートを `require` します：

```lua
local Arbor = require(path.to.Arbor)
```

## パッケージ要件

Arbor に必須の ピアパッケージ依存関係 はありません。

動かすために Registry、Bootstrap、Wally、Pesde、sourcemap generator、または別の Arbor パッケージは必要ありません。

## アナライザー可視性の要件

Arbor の型ヘルパーが公開できるのは、いま動いている Luau アナライザーからすでに見えている子だけです。

アナライザーから `script.Kick` が見えているなら、Arbor はその子を型レベルの情報へ変換できます：

```lua
export type ActionId = Arbor.ChildNames<typeof(script)>
```

アナライザーから `script.Kick` が見えていないなら、Arbor が型レベルで `"Kick"` を作り出すことはできません。

## おすすめのツール

ローカルエディターでのフィードバックや、再現しやすいアナライザーチェックが欲しい場合は `luau-lsp` を使ってください。

アナライザーから見えるツリーは、いくつかのツールチェーンから来ることがあります：

- `luau-lsp` の package または plugin data model
- Roblox ツリーを Luau に公開する、別の sourcemap または data-model provider

その provider はアナライザー設定の一部であり、Arbor のランタイム依存ではありません。

## 用途別モジュール

ルートファサード：

```lua
local Arbor = require(path.to.Arbor)
```

用途別モジュール：

```lua
local ChildNames = require(path.to.Arbor.InstanceTree.ChildNames)
```

呼び出し側にとって読みやすいほうを使ってください。

## 次に読む

- [アナライザーモデル](analyzer-model.md)
- [型チェック](guides/typechecking.md)
- [例](examples.md)
