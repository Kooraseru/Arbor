---
title: ChildNames
---

# ChildNames

## 目的

アナライザーから見える直接の子の名前ユニオンを返します。

## シグネチャ

```lua
Arbor.ChildNames<T>
InstanceTree.ChildNames.Of<T>
```

## 例

```txt title="ツリー"
Package/
  init.luau
  Kick.luau
  Ban.luau
```

```lua title="型"
export type ActionId = Arbor.ChildNames<typeof(script)>
```

## 返る型

```lua
type ActionId = "Kick" | "Ban"
```

## よくあるミス

- 子孫の名前まで期待する。`ChildNames` が読むのは直接の子だけです。
- `ModuleScript` の戻り値型を期待する。これは名前を証明するだけで、`require` 結果は証明しません。
- 子がアナライザーから見えない、ランタイムで検出した `Instance` 値に使う。

## 関連関数

- [ChildOf](child-of.md)
- [ChildRecord](child-record.md)
- [ChildNamesOfClass](child-names-of-class.md)
