---
title: アナライザーモデル
---

# アナライザーモデル

Arbor が公開できるのは、Luau がすでに見えているものだけです。

モデル全体はそれだけです。ランタイムでの検出と、コンパイル時の型付けは別の関心事です。

## ルール

アナライザーから直接の子がリテラルなプロパティとして見えている場合、Arbor は型関数でその子名を取り出せます。

たとえば、自分で所有しているツリーがこうだとします：

```txt
Actions
  Kick
  Ban
```

この型は：

```lua
export type ActionId = Arbor.ChildNames<typeof(script)>
```

次のようになれます：

```lua
type ActionId = "Kick" | "Ban"
```

ただし、チェック中のファイルから `script.Kick` と `script.Ban` がアナライザーに見えている場合だけです。

## Arbor が証明すること

Arbor が証明するのは、アナライザーから見える形です：

```txt
直接の子の名前
直接の子の lookup
クラスで絞り込んだ子の名前
クラスで絞り込んだ子のレコード
```

## Arbor が証明しないこと

Arbor は次のことを証明しません：

```txt
require(childModule) が何を返すか
ランタイム検出で期待したモジュールがすべて見つかったか
CLI、Studio、LSP のアナライザーが同じメタデータを公開しているか
```

ランタイムでロードした値は、ローダー境界で検証してください。

## ランタイムロードは別物

これはコンパイル時の形です：

```lua
export type ActionId = Arbor.ChildNames<typeof(script)>
```

これはランタイムの挙動です：

```lua
local actions = LoadModuleMap.From(script, validateAction)
```

ランタイムローダーは、それでも動的に `require` を呼びます。Arbor は、その動的な値を、あなたのバリデーターが受け入れるまで `unknown` のままにします。

## ツールチェーンのメモ

`luau-lsp` は開発中の検証におすすめです。いま使っているアナライザーに、期待しているツリーが本当に見えているか確認できるためです。

sourcemap や data-model provider は、アナライザーが Roblox のインスタンス階層を見る助けになります。その provider はアナライザー設定の一部であり、Arbor のランタイムパッケージではありません。

## 次に読む

- [型チェック](guides/typechecking.md)
- [ランタイムロード](runtime-loaders.md)
- [例](examples.md)
