---
title: 直接の子
---

# 直接の子

## 問題

直接の子モジュールを持つモジュールを所有しているとします：

```txt title="パッケージ"
direct-children/
  init.luau
  Kick.luau
  Ban.luau
```

ランタイムコードはそれらの子を検出できますが、パッケージ側に見せる型には、まだ静的なサーフェスが必要です。2 つ目のマニフェストを手書きせずに、利用できる子名を Luau に知ってほしい、という状況です。

## ソース

```lua title="init.luau"
--8<-- "content/jp/examples/direct-children/init.luau"
```

```lua title="Kick.luau"
--8<-- "content/jp/examples/direct-children/Kick.luau"
```

```lua title="Ban.luau"
--8<-- "content/jp/examples/direct-children/Ban.luau"
```

## 結果

アナライザーから `Kick` と `Ban` が直接の子として見えている場合、Arbor は次を公開します：

```lua title="アナライザー向けの型"
type ActionId = "Kick" | "Ban"
type ActionChildren = {
  Kick: typeof(script.Kick),
  Ban: typeof(script.Ban),
}
```

`"Kick"` と `"Ban"` は `ActionId` として受け入れられます。関係ない名前は拒否されるはずです。

## なぜ動くのか

`ChildNames<typeof(script)>` は、現在のモジュールについて、アナライザーから見える直接の子を読みます。

`ChildOf<typeof(script), "Kick">` は、名前で指定した子 1 つについて、アナライザーから見える型を返します。

`ChildRecord<typeof(script), V>` は同じ直接の子名をテーブルキーとして使い、それぞれのキーに指定された値の型を割り当てます。

## 証明しないこと

この例が証明するのは、静的なツリー形状です。`require(script.Kick)` がランタイムで何を返すかは証明しません。

子モジュールを動的にロードする場合は、ロードした値をランタイム境界で検証してください。
