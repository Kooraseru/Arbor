---
title: 関係型
description: 子・祖先・子孫のチェックに使う型エイリアス。
---

# 関係型

関係エイリアスは、アナライザーから見える instance type の間に、直下の子・祖先・子孫の関係があるかを答えます。

これらのエイリアスは、Roblox の instance class としてアナライザーから公開される Luau の `Luau.extern|extern type` 値に対して動きます。

## メンバー

| メンバー | 戻り値 | 概要 |
| --- | --- | --- |
| [`ChildOf`](#childof) | `Child` または `never` | 親の直下の子である場合だけ、子の型を残す。 |
| [`IsChildOf`](#ischildof) | `true` または `false` | 直下の子関係を boolean でチェックする。 |
| [`AncestorOf`](#ancestorof) | `Ancestor` または `never` | 関係が成立する場合だけ祖先型を残す。 |
| [`IsAncestorOf`](#isancestorof) | `true` または `false` | 祖先関係を boolean でチェックする。 |
| [`DescendantOf`](#descendantof) | `Descendant` または `never` | 関係が成立する場合だけ子孫型を残す。 |
| [`IsDescendantOf`](#isdescendantof) | `true` または `false` | 子孫関係を boolean でチェックする。 |

## ChildOf

### 呼び出し形式

```lua
Arbor.ChildOf<Child, Parent>
```

### 型パラメーター

| パラメーター | 説明 |
| --- | --- |
| `Child` | 子の候補となる、アナライザーから見える `Luau.extern|extern type`。 |
| `Parent` | 親の候補となる、アナライザーから見える `Luau.extern|extern type`。 |

### 戻り値

| 型 | 条件 |
| --- | --- |
| `Child` | `Child` が、アナライザーから見える `Parent` の直下の子。 |
| `never` | `Child` が、アナライザーから見える `Parent` の直下の子ではない。 |

### コード例

```lua
local fixture = script.Parent.Fixture
local fixtureChild = script.Parent.Fixture.String

type FixtureType = typeof(fixture)
type FixtureStringType = typeof(fixtureChild)

local _validFixtureChild: Arbor.ChildOf<FixtureStringType, FixtureType> = fixtureChild
```

## IsChildOf

### 呼び出し形式

```lua
Arbor.IsChildOf<Child, Parent>
```

### 型パラメーター

| パラメーター | 説明 |
| --- | --- |
| `Child` | 子の候補となる、アナライザーから見える `Luau.extern|extern type`。 |
| `Parent` | 親の候補となる、アナライザーから見える `Luau.extern|extern type`。 |

### 戻り値

| 型 | 条件 |
| --- | --- |
| `true` | `Child` が、アナライザーから見える `Parent` の直下の子。 |
| `false` | `Child` が、アナライザーから見える `Parent` の直下の子ではない。 |

### コード例

```lua
type StringIsChild = Arbor.IsChildOf<
    typeof(script.Parent.Fixture.String),
    typeof(script.Parent.Fixture)
>

local _stringIsChild: StringIsChild = true
```

## AncestorOf

### 呼び出し形式

```lua
Arbor.AncestorOf<Ancestor, Descendant>
```

### 型パラメーター

| パラメーター | 説明 |
| --- | --- |
| `Ancestor` | 祖先の候補となる、アナライザーから見える `Luau.extern|extern type`。 |
| `Descendant` | 子孫の候補となる、アナライザーから見える `Luau.extern|extern type`。 |

### 戻り値

| 型 | 条件 |
| --- | --- |
| `Ancestor` | `Ancestor` が、アナライザーから見える `Descendant` の祖先。 |
| `never` | `Ancestor` が、アナライザーから見える `Descendant` の祖先ではない。 |

## IsAncestorOf

### 呼び出し形式

```lua
Arbor.IsAncestorOf<Ancestor, Descendant>
```

### 型パラメーター

| パラメーター | 説明 |
| --- | --- |
| `Ancestor` | 祖先の候補となる、アナライザーから見える `Luau.extern|extern type`。 |
| `Descendant` | 子孫の候補となる、アナライザーから見える `Luau.extern|extern type`。 |

### 戻り値

| 型 | 条件 |
| --- | --- |
| `true` | `Ancestor` が、アナライザーから見える `Descendant` の祖先。 |
| `false` | `Ancestor` が、アナライザーから見える `Descendant` の祖先ではない。 |

### コード例

```lua
type FixtureIsAncestor = Arbor.IsAncestorOf<
    typeof(script.Parent.Fixture),
    typeof(script.Parent.Fixture.String)
>

local _fixtureIsAncestor: FixtureIsAncestor = true
```

## DescendantOf

### 呼び出し形式

```lua
Arbor.DescendantOf<Descendant, Ancestor>
```

### 型パラメーター

| パラメーター | 説明 |
| --- | --- |
| `Descendant` | 子孫の候補となる、アナライザーから見える `Luau.extern|extern type`。 |
| `Ancestor` | 祖先の候補となる、アナライザーから見える `Luau.extern|extern type`。 |

### 戻り値

| 型 | 条件 |
| --- | --- |
| `Descendant` | `Descendant` が、アナライザーから見える `Ancestor` の子孫。 |
| `never` | `Descendant` が、アナライザーから見える `Ancestor` の子孫ではない。 |

## IsDescendantOf

### 呼び出し形式

```lua
Arbor.IsDescendantOf<Descendant, Ancestor>
```

### 型パラメーター

| パラメーター | 説明 |
| --- | --- |
| `Descendant` | 子孫の候補となる、アナライザーから見える `Luau.extern|extern type`。 |
| `Ancestor` | 祖先の候補となる、アナライザーから見える `Luau.extern|extern type`。 |

### 戻り値

| 型 | 条件 |
| --- | --- |
| `true` | `Descendant` が、アナライザーから見える `Ancestor` の子孫。 |
| `false` | `Descendant` が、アナライザーから見える `Ancestor` の子孫ではない。 |

### コード例

```lua
type StringIsDescendant = Arbor.IsDescendantOf<
    typeof(script.Parent.Fixture.String),
    typeof(script.Parent.Fixture)
>

local _stringIsDescendant: StringIsDescendant = true
```

## 境界

| 境界 | 説明 |
| --- | --- |
| 直下の子チェック | 子孫までは検索しない。 |
| 祖先・子孫チェック | アナライザーから見える直下の子 property をたどる。 |
| 入力 | すべての関係入力は、アナライザーから見える `Luau.extern|extern type` 値である必要がある。 |
| 関係が成立しない場合 | filter エイリアスは `never`、boolean エイリアスは `false` を返す。 |

## 関連

- [子の型](children.md)
- [アナライザーモデル](../analyzer-model.md)
