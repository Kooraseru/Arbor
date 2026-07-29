---
title: "クイックスタート"
---

# クイックスタート

ルートファサードを `require` します。

```lua
local Arbor = require(path.to.Arbor)
```

直下の子名を使います。

```lua
export type ActionId = Arbor.ChildNames<typeof(script)>
```

子名をキーにしたランタイム map 型を作ります。

```lua
type ActionMap = Arbor.ChildRecord<typeof(script), ActionDefinition>
```

バリデーターを通してランタイムモジュールを読み込みます。

```lua
local actions: ActionMap = Arbor.LoadModules(script, validateAction)
```

大事なルールは単純です。Arbor に Roblox 階層を Luau の型システムへ公開させ、動的な `require` の結果はランタイム境界で検証します。

全メンバーは [API リファレンス](../api/index.md) を見てください。
