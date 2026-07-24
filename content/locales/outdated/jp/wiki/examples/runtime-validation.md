---
title: ランタイム検証
---

# ランタイム検証

## 問題

型付きの子検出は、名前とインスタンス形状を証明できます。ただし、`ModuleScript` の戻り値までは証明しません。

不確実さを 1 つの検証境界に閉じ込めるランタイムローダーが必要です。

```txt title="パッケージ"
runtime-loader/
  init.luau
  Kick.luau
  Ban.luau
```

## ソース

```lua title="init.luau"
--8<-- "content/jp/examples/runtime-loader/init.luau"
```

```lua title="Kick.luau"
--8<-- "content/jp/examples/runtime-loader/Kick.luau"
```

```lua title="Ban.luau"
--8<-- "content/jp/examples/runtime-loader/Ban.luau"
```

## 結果

返されるテーブルは直接のモジュール名をキーにし、それぞれのロード済み値は `validateAction` を通っています。

```lua title="ランタイム向け map"
type ActionMap = Arbor.ChildRecord<typeof(script), ActionDefinition>

local actions: ActionMap = LoadModuleMap.From(script, validateAction)
```

呼び出し側は、検証後の型付き map を受け取ります：

```lua
actions.Kick.Run("Builder")
actions.Ban.Run("Spammer")
```

## なぜ動くのか

`LoadModuleMap.From` はランタイムで直接の子 `ModuleScript` を検出し、それぞれを `require` して、生の結果をバリデーターへ渡します。

バリデーターが受け取るのは `any` ではなく `unknown` です。これにより、動的な不確実さはローダー境界に留まり、呼び出し側が型システムを迂回してキャストするのを防ぎます。

## 証明しないこと

この例は、動的な `require` を静的に既知にするものではありません。

また、実際のプロジェクト内のすべてのモジュールが正しい形を返すことも証明しません。そのランタイム契約は、あなたのバリデーターが受け持ちます。
