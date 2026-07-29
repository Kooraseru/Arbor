---
title: アナライザーモデル
---

# アナライザーモデル

Arbor が公開できるのは、Luau がすでに見えているものだけです。

これがモデルのすべてです。ランタイムでの探索とコンパイル時の型づけは別の関心ごとです。

## ルール

アナライザーが直下の子を literal property として見ているとき、Arbor は型関数でその子名を取り出せます。

次の所有ツリーがあるとします。

```txt
Actions
  Kick
  Ban
```

この型は、

```lua
export type ActionId = Arbor.ChildNames<typeof(script)>
```

次の型になれます。

```lua
type ActionId = "Kick" | "Ban"
```

ただし、チェックしているファイルからアナライザーが `script.Kick` と `script.Ban` を見えている場合だけです。

## Arbor が示せること

Arbor は、アナライザーから見える shape を示します。

```txt
direct child names
direct child lookup
class-filtered child names
class-filtered child records
direct child relations
ancestor and descendant relations
```

## Arbor が示せないこと

Arbor は次を保証しません。

```txt
what require(childModule) returns
whether runtime discovery found every expected module
whether CLI, Studio, and LSP analyzers expose identical metadata
```

ランタイムで読みこんだ値は、ローダーの境界で検証してください。

## ランタイムの読みこみは別

これはコンパイル時の shape です。

```lua
export type ActionId = Arbor.ChildNames<typeof(script)>
```

これはランタイム動作です。

`Arbor.LoadModules(root, validate)` はランタイム動作です。

ランタイムローダーは、引きつづき `require` を動的に呼びます。Arbor は、その動的な値をバリデーターが受け入れるまで `unknown` のままにします。

## ツールチェーンのメモ

開発中の検証には `luau-lsp` をおすすめします。使っているアナライザーから、期待したツリーが見えているか確認できるためです。

source-map または data-model provider を使うと、アナライザーから Roblox のインスタンス階層を見えるようにできます。その provider はアナライザー設定の一部であり、Arbor のランタイム依存ではありません。

## 次に読むもの

- [型チェック](guides/typechecking.md)
- [ランタイムの読みこみ](api/runtime-loaders/index.md)
- [API リファレンス](api/index.md)
