---
title: ランタイムローダー
---

# ランタイムローダー

ランタイムローダーは、動的なランタイム検出と明示的な検証を組み合わせるための小さなヘルパーです。

## LoadModuleMap

```lua
local LoadModuleMap = Arbor.RuntimeLoaders.LoadModuleMap
```

契約：

```lua
export type ModuleValidator<T> = (value: unknown, moduleScript: ModuleScript) -> T

LoadModuleMap.From<T>(root: Instance, validate: ModuleValidator<T>): { [string]: T }
```

挙動：

```txt
GetChildren() で直接の子を読む
直接の子 ModuleScript を require する
ModuleScript 名で sort する
require した値をそれぞれ検証する
ModuleScript 名をキーにした map を返す
```

不確実さはバリデーターに置いてください。呼び出し側が受け取るべきなのは、動的な `require` 結果ではなく、型付きの値です。
