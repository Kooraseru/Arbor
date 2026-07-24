---
title: ChildrenOfClass
---

# ChildrenOfClass

## 目的

アナライザーから見える型が Roblox クラスに一致する、直接の子のテーブル形状を返します。

## シグネチャ

```lua
Arbor.ChildrenOfClass<T, ClassType>
InstanceTree.ChildrenOfClass.Of<T, ClassType>
```

## 例

```lua title="型"
export type ModuleChildren = Arbor.ChildrenOfClass<typeof(script), ModuleScript>
```

## 返る型

```lua
type ModuleChildren = {
  Kick: typeof(script.Kick),
  Ban: typeof(script.Ban),
}
```

## よくあるミス

- ランタイムの `IsA` 挙動を期待する。これはアナライザー向けの型フィルタリングです。
- 子孫まで期待する。このフィルターが対象にするのは直接の子だけです。
- 検証済みのモジュール戻り値が必要な場面で使う。

## 関連関数

- [ChildNamesOfClass](child-names-of-class.md)
- [ChildRecord](child-record.md)
