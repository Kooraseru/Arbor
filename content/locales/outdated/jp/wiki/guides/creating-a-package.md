---
title: パッケージを作る
---

# パッケージを作る

自分のパッケージが小さな子ツリーを所有していて、そのツリーをアナライザーに理解してほしい場合に Arbor を使ってください。

## おすすめの形

```txt
Package/
  init.luau
  FeatureA.luau
  FeatureB.luau
```

`init.luau` の中で、`typeof(script)` から名前やレコードを導きます：

```lua
local Arbor = require(path.to.Arbor)

export type FeatureName = Arbor.ChildNames<typeof(script)>
```

## ランタイムは分ける

静的な形には Arbor を使います。ランタイムのモジュール値にはバリデーターを使ってください。

```lua
export type FeatureMap = Arbor.ChildRecord<typeof(script), FeatureDefinition>
```

この型が言っているのは、どんなキーが存在するかです。モジュールがすでに `require` され、検証済みであることまでは言っていません。
