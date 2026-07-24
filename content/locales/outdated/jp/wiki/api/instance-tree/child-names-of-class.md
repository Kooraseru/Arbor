---
title: ChildNamesOfClass
---

# ChildNamesOfClass

## 目的

アナライザーから見える型が Roblox クラスに一致する、直接の子の名前ユニオンを返します。

## シグネチャ

```lua
Arbor.ChildNamesOfClass<T, ClassType>
InstanceTree.ChildNamesOfClass.Of<T, ClassType>
```

## 例

```lua title="型"
export type ModuleName = Arbor.ChildNamesOfClass<typeof(script), ModuleScript>
```

## 返る型

```lua
type ModuleName = "Kick" | "Ban"
```

## よくあるミス

- クラスで絞り込んだ名前を、モジュールの戻り値型の証明として扱う。
- `ChildrenOfClass` のほうが子インスタンス情報を多く保てる場面で、こちらを使う。
- 対象ツールチェーンでアナライザー対応を確認せずに、これに依存する。

## 関連関数

- [ChildrenOfClass](children-of-class.md)
- [ChildNames](child-names.md)
