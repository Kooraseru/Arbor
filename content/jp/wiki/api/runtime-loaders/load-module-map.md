---
title: LoadModuleMap
---

# LoadModuleMap

## 目的

直接の子 `ModuleScript` をロードし、それぞれの `require` 結果を検証します。

## シグネチャ

```lua
export type ModuleValidator<T> = (value: unknown, moduleScript: ModuleScript) -> T

LoadModuleMap.From<T>(root: Instance, validate: ModuleValidator<T>): { [string]: T }
```

## 例

```lua title="ランタイムロード"
local LoadModuleMap = Arbor.RuntimeLoaders.LoadModuleMap

local actions = LoadModuleMap.From(script, validateAction)
```

## 返る型

```lua
{ [string]: T }
```

アナライザーに正確な子名が見えている場合は、`ChildRecord<typeof(root), T>` と組み合わせて使ってください。

## よくあるミス

- `require` 結果を検証せず、キャストで済ませる。
- 再帰的な子孫ロードを期待する。
- これをレジストリやライフサイクルシステムに育ててしまう。

## 関連関数

- [ChildRecord](../instance-tree/child-record.md)
- [ランタイムロード](../../runtime-loaders.md)
