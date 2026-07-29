---
title: Arbor
description: Luau 向けのコンパイル時 Roblox データモデル型づけ。
---

# Arbor

<div class="arbor-hero">
  <img src="assets/brand/Billboard.svg" alt="Arbor">
  <p>
    Luau 向けのコンパイル時 Roblox データモデル型づけ。
  </p>
</div>

Arbor は、アナライザーから見える Roblox インスタンスツリーを便利な静的型へ変える Luau パッケージです。

公開 API は意図して小さくしています。直下の子の探索、子・祖先・子孫の関係型、子名を正確なキーにした record、そして型つきソースから動的な `require` へわたる場所で使う、小さな検証つきランタイムローダーだけです。

## はじめに

- [インストール](install.md)
- [API リファレンス](api/index.md)
- [ランタイムローダー](api/runtime-loaders/index.md)
- [リリースノート](reference/release-notes.md)

## Arbor が示せること

Arbor は、アナライザーから見える構造を公開します。

```txt
direct child names
direct child lookup
class-filtered child names
class-filtered child records
direct child, ancestor, and descendant relations
```

ModuleScript の戻り値の型は保証しません。ランタイムで読みこんだ値は、引きつづき検証が必要です。

## 公開 API

利用側が使う正式な入口は、パッケージルートです。

```lua
local Arbor = require(path.to.Arbor)
```

ルートは、`CollectChildren`、`ExpectChild`、`FindChild`、`LoadModules` などのランタイムエイリアスと、`ChildNames`、`RequiredChild`、`ChildTypeRecord`、`IsChildOf`、`IsDescendantOf` などの型エイリアスを export します。

## パッケージ境界

Arbor は registry、lifecycle、serialization、dispatch、descriptor、pipeline の順序、package lookup を持ちません。

## リリースノート

- [リリースノート](reference/release-notes.md)
