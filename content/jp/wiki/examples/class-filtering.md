---
title: クラスフィルタリング
---

# クラスフィルタリング

## 問題

自分で子ツリーを所有しているけれど、型付きサーフェスに出したい直接の子は一部だけ、という場合があります。

```txt title="パッケージ"
class-filtered-children/
  init.luau
  Kick.luau
  Ban.luau
```

ローダー系のコードでは、アナライザーから見えるクラスが `ModuleScript` の直接の子だけが、よく使うセットになります。

## ソース

```lua title="init.luau"
--8<-- "content/jp/examples/class-filtered-children/init.luau"
```

```lua title="Kick.luau"
--8<-- "content/jp/examples/class-filtered-children/Kick.luau"
```

```lua title="Ban.luau"
--8<-- "content/jp/examples/class-filtered-children/Ban.luau"
```

## 結果

アナライザーから `Kick` と `Ban` が直接の子 `ModuleScript` として見えている場合、Arbor は次を公開します：

```lua title="アナライザー向けの型"
type ModuleChildren = {
  Kick: typeof(script.Kick),
  Ban: typeof(script.Ban),
}
```

`ModuleScript` に一致する直接の子だけが、テーブル形状に現れます。

## なぜ動くのか

`ChildrenOfClass<typeof(script), ModuleScript>` は、アナライザーから見える直接の子テーブルを Roblox クラスでフィルターします。

必要なのが子の名前ユニオンだけではなく、子インスタンスの形そのものなら、これを使ってください。

## 証明しないこと

これはアナライザー向けの型フィルタリングです。ランタイムで `Instance:IsA()` を実行するわけではありません。

また、アナライザーから子ツリーのクラスメタデータが見えていることにも依存します。いま使っているツールチェーンから子のクラスが見えないなら、Arbor がランタイム状態からそれを復元することはできません。
