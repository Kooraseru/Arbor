---
title: ChildOf
---

# ChildOf

## 目的

名前で指定した直接の子 1 つについて、アナライザーから見える型を返します。

## シグネチャ

```lua
Arbor.ChildOf<T, Name>
InstanceTree.ChildOf.Of<T, Name>
```

## 例

```lua title="型"
export type KickModule = Arbor.ChildOf<typeof(script), "Kick">
```

## 返る型

```lua
type KickModule = typeof(script.Kick)
```

## よくあるミス

- 直接の子ではない名前を渡す。
- 子インスタンスの型を、モジュールの戻り値型として扱う。
- 子テーブル全体の形を使ったほうが読みやすい場面で使う。

## 関連関数

- [ChildNames](child-names.md)
- [ChildRecord](child-record.md)
