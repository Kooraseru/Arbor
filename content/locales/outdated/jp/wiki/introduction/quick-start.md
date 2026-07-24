---
title: クイックスタート
---

# クイックスタート

ルートファサードを `require` します：

```lua
local Arbor = require(path.to.Arbor)
```

直接の子の名前を使います：

```lua
export type ActionId = Arbor.ChildNames<typeof(script)>
```

子名をキーにしたランタイム map の型を作ります：

```lua
type ActionMap = Arbor.ChildRecord<typeof(script), ActionDefinition>
```

バリデーターを通してランタイムモジュールをロードします：

```lua
local LoadModuleMap = Arbor.RuntimeLoaders.LoadModuleMap

local actions: ActionMap = LoadModuleMap.From(script, validateAction)
```

基本ルールはシンプルです。Arbor に Roblox 階層を Luau の型システムへ公開させ、そのあと動的な `require` 結果をランタイム境界で検証してください。
