---
title: ChildRecord
---

# ChildRecord

## 目的

アナライザーから見える直接の子の名前をキーにし、値を指定した型にしたテーブル形状を作ります。

## シグネチャ

```lua
Arbor.ChildRecord<T, V>
InstanceTree.ChildRecord.Of<T, V>
```

## 例

```lua title="型"
export type ActionMap = Arbor.ChildRecord<typeof(script), ActionDefinition>
```

## 返る型

```lua
type ActionMap = {
  Kick: ActionDefinition,
  Ban: ActionDefinition,
}
```

## よくあるミス

- 正確な子キーが欲しいのに `{ [string]: V }` を使う。
- `ChildRecord` がモジュールをロードすると考える。これはテーブル形状を表すだけです。
- ランタイムでロードしたモジュール値を、この形に代入する前に検証し忘れる。

## 関連関数

- [ChildNames](child-names.md)
- [RuntimeLoaders.LoadModuleMap](../runtime-loaders/load-module-map.md)
