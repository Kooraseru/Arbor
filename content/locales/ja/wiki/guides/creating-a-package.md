---
title: 子ツリーを型づけする
---

# 子ツリーを型づけする

Roblox データモデルに子ツリーがあり、Luau にそのツリーをコンパイル時に理解させたいとき、Arbor を使います。

## おすすめの形

```txt
SomeRoot/
  init.luau
  FeatureA.luau
  FeatureB.luau
```

`init.luau` の中で、`typeof(script)` から名前や record を作ります。

```lua
local Arbor = require(path.to.Arbor)

export type FeatureName = Arbor.ChildNames<typeof(script)>
export type FeatureModule = Arbor.RequiredChild<typeof(script), "FeatureA">
```

## ランタイムは分ける

静的な shape には Arbor を使います。ランタイムのモジュール値にはバリデーターを使います。

```lua
export type FeatureMap = Arbor.ChildRecord<typeof(script), FeatureDefinition>
```

この型が示すのは、どのキーがあるかです。モジュールがすでに `require` され、検証されたことまでは示しません。

ランタイム値を読みこむ必要があるときは、バリデーターを通して境界をわたります。

```lua
local features: FeatureMap = Arbor.LoadModules(script, validateFeature)
```

## 分割に強い API の使い方

`Arbor.ChildNames`、`Arbor.RequiredChild`、`Arbor.LoadModules` などのルートエイリアスに依存してください。

Arbor が大きくなれば内部 folder は分割できます。ルートファサードが安定した利用側 API です。
