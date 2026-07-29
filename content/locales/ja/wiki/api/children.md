---
title: 子の型
description: アナライザーから見える直下の子に使う型エイリアス。
---

# 子の型

子の型エイリアスは、親の型から、アナライザーに見えている直下の子 property を読みます。

対象は型であり、ランタイムの instance ではありません。Luau の型関数では、Roblox の instance class は `Luau.extern|extern type` の値として見えます。アナライザーがその子を型上の直下 property として見えていない場合、Arbor があとから名前を取りもどすことはできません。

## メンバー

| メンバー | 戻り値 | 概要 |
| --- | --- | --- |
| [`Child`](#child) | child instance type、`nil`、または `never` | lookup mode を明示して、名前から直下の子 1 つを解決する。 |
| [`RequiredChild`](#requiredchild) | child instance type | 名前から必須の直下の子 1 つを解決する。 |
| [`ChildNames`](#childnames) | string singleton union | アナライザーから見える直下の子名を返す。 |
| [`ChildNamesOfClass`](#childnamesofclass) | string singleton union | 指定クラスに一致する直下の子名を返す。 |
| [`ChildRecord`](#childrecord) | table type | 指定した value type で、子名を正確なキーにした record を作る。 |
| [`ChildTypeRecord`](#childtyperecord) | table type | 子 instance type で、子名を正確なキーにした record を作る。 |
| [`ChildrenOfClass`](#childrenofclass) | table type | 指定クラスに一致する子について、子名を正確なキーにした record を作る。 |

## Child

### 呼び出し形式

```lua
Arbor.Child<{ Parent: Parent, Name: Name, Mode: "checked" | "optional" | "required"? }>
```

名前から直下の子 1 つを解決します。

### 型パラメーター

| パラメーター | 説明 |
| --- | --- |
| `Parent` | アナライザーから見える Roblox の `Luau.extern|extern type`。 |
| `Name` | 子名を表す string singleton。 |
| `Mode` | 任意の lookup mode。default は `"checked"`。 |

### 戻り値

| 型 | 条件 |
| --- | --- |
| `typeof(parent.Child)` | 指定名の子がある。 |
| `nil` | `Mode` が `"optional"` で、子がない。 |
| `never` | `Mode` が `"checked"` で、子がない。 |

### エラー

| Mode | 条件 |
| --- | --- |
| `"required"` | 子がないとき、アナライザーエラーを出す。 |

### コード例

```lua
export type StringModule = Arbor.Child<{
    Parent: typeof(script.Parent.Fixture),
    Name: "String",
    Mode: "required",
}>
```

## RequiredChild

### 呼び出し形式

```lua
Arbor.RequiredChild<Parent, Name>
```

`Arbor.Child<{ Parent: Parent, Name: Name, Mode: "required" }>` の短い書き方です。

### 型パラメーター

| パラメーター | 説明 |
| --- | --- |
| `Parent` | アナライザーから見える Roblox の `Luau.extern|extern type`。 |
| `Name` | 子名を表す string singleton。 |

### 戻り値

| 型 | 条件 |
| --- | --- |
| `typeof(parent.Child)` | 指定名の子がある。 |
| analyzer error | 指定名の子がない。 |

### コード例

```lua
export type dataservice = Arbor.RequiredChild<
    typeof(script.Parent.ServerServices),
    "DataService"
>
```

## ChildNames

### 呼び出し形式

```lua
Arbor.ChildNames<Parent>
```

アナライザーから見える直下の子名の union を返します。

### 戻り値

| 型 | 条件 |
| --- | --- |
| `"ChildA" | "ChildB" | ...` | 直下の子名がアナライザーから見える。 |
| `never` | 直下の子名が 1 つも見えない。 |

### コード例

```lua
export type TypeId = Arbor.ChildNames<typeof(script.Parent.Fixture)>
```

## ChildNamesOfClass

### 呼び出し形式

```lua
Arbor.ChildNamesOfClass<Parent, ClassType>
```

アナライザーから見える型が `ClassType` に一致するか、そこから継承している直下の子名を union で返します。

### 型パラメーター

| パラメーター | 説明 |
| --- | --- |
| `Parent` | アナライザーから見える Roblox の `Luau.extern|extern type`。 |
| `ClassType` | `ModuleScript` など、filter に使う Roblox class の `Luau.extern|extern type`。 |

### 戻り値

| 型 | 条件 |
| --- | --- |
| `"ChildA" | "ChildB" | ...` | 一致する直下の子が見える。 |
| `never` | 一致する直下の子が 1 つも見えない。 |

## ChildRecord

### 呼び出し形式

```lua
Arbor.ChildRecord<Parent, Value>
```

直下の子名をキーにし、それぞれの値を `Value` にした table type を作ります。

### 型パラメーター

| パラメーター | 説明 |
| --- | --- |
| `Parent` | アナライザーから見える Roblox の `Luau.extern|extern type`。 |
| `Value` | すべての直下の子 key に入れる value type。 |

### 戻り値

| 型 | 説明 |
| --- | --- |
| `{ [ChildName]: Value }` | アナライザーから見える直下の子名をキーにした table type。 |

### コード例

```lua
export type TypeModulesRecord = Arbor.ChildRecord<
    typeof(script.Parent.Fixture),
    TypeModule
>
```

## ChildTypeRecord

### 呼び出し形式

```lua
Arbor.ChildTypeRecord<Parent>
```

直下の子名をキーにし、それぞれの値をアナライザーから見える子 instance type にした table type を作ります。

### 型パラメーター

| パラメーター | 説明 |
| --- | --- |
| `Parent` | アナライザーから見える Roblox の `Luau.extern|extern type`。 |

### 戻り値

| 型 | 説明 |
| --- | --- |
| `{ [ChildName]: typeof(parent.Child) }` | アナライザーから見える直下の子名をキーにし、各 value をその子の instance type にした table type。 |

## ChildrenOfClass

### 呼び出し形式

```lua
Arbor.ChildrenOfClass<Parent, ClassType>
```

アナライザーから見える型が `ClassType` に一致するか、そこから継承している直下の子について table type を作ります。value は一致した子の instance type です。

### 型パラメーター

| パラメーター | 説明 |
| --- | --- |
| `Parent` | アナライザーから見える Roblox の `Luau.extern|extern type`。 |
| `ClassType` | `ModuleScript` など、filter に使う Roblox class の `Luau.extern|extern type`。 |

### 戻り値

| 型 | 条件 |
| --- | --- |
| `{ [ChildName]: typeof(parent.Child) }` | 一致する直下の子が見える。 |
| `{}` | 一致する直下の子が 1 つも見えない。 |

## 境界

| 境界 | 説明 |
| --- | --- |
| 直下の子 | これらのエイリアスは子孫を検索しない。 |
| Extern input | `Parent` は、Roblox の `Luau.extern|extern type` としてアナライザーから見えている必要がある。 |
| Synthetic parent | synthetic な `Parent` property は、子名と child record の helper から除外される。 |
| Module return | 子 instance type は `require` の戻り値型ではない。 |

## 関連

- [アナライザーモデル](../analyzer-model.md)
- [関係型](relations.md)
- [ランタイムメンバー](runtime.md)
