---
title: ランタイムメンバー
description: Arbor が export するランタイム関数。
---

# ランタイムメンバー

ランタイムメンバーは、実際の `Instance` の子を調べます。それだけでコンパイル時の型を作るものではありません。

## メンバー

| メンバー | 戻り値 | 概要 |
| --- | --- | --- |
| [`CollectChildren`](#collectchildren) | `{ [string]: Instance }` | 直下の子を、名前をキーにした table へ集める。 |
| [`FindChild`](#findchild) | `Instance?` | 指定名の直下の子、または `nil` を返す。 |
| [`ExpectChild`](#expectchild) | `Instance` | 指定名の直下の子を返し、なければエラーにする。 |

## CollectChildren

### 呼び出し形式

<pre><code>Arbor.CollectChildren(parent: <a class="arbor-type-link" href="https://create.roblox.com/docs/reference/engine/classes/Instance" data-tooltip="Instance - データモデル内のオブジェクトに使われる Roblox の基本クラス。">Instance</a>): { [string]: <a class="arbor-type-link" href="https://create.roblox.com/docs/reference/engine/classes/Instance" data-tooltip="Instance - データモデル内のオブジェクトに使われる Roblox の基本クラス。">Instance</a> }</code></pre>

直下の子を `Name` をキーにして返します。

### パラメーター

| パラメーター | 型 | 説明 |
| --- | --- | --- |
| `parent` | <a class="arbor-type-link" href="https://create.roblox.com/docs/reference/engine/classes/Instance" data-tooltip="Instance - データモデル内のオブジェクトに使われる Roblox の基本クラス。">`Instance`</a> | 直下の子を集める対象の instance。 |

### 戻り値

| 型 | 説明 |
| --- | --- |
| `{ [string]: `<a class="arbor-type-link" href="https://create.roblox.com/docs/reference/engine/classes/Instance" data-tooltip="Instance - データモデル内のオブジェクトに使われる Roblox の基本クラス。">`Instance`</a>` }` | 直下の子名をキーにした table。 |

### 動作

| ルール | 説明 |
| --- | --- |
| 直下の子 | `parent:GetChildren()` を読み、子孫は無視する。 |
| 安定した順序 | insert する前に、子を名前で sort する。 |
| 重複名 | 直下の子 2 つが同じ名前ならエラーにする。 |

### コード例

```lua
local children = Arbor.CollectChildren(script.Parent.Fixture)
local stringModule = children.String
```

## FindChild

### 呼び出し形式

<pre><code>Arbor.FindChild(parent: <a class="arbor-type-link" href="https://create.roblox.com/docs/reference/engine/classes/Instance" data-tooltip="Instance - データモデル内のオブジェクトに使われる Roblox の基本クラス。">Instance</a>, name: string): <a class="arbor-type-link" href="https://create.roblox.com/docs/reference/engine/classes/Instance" data-tooltip="Instance - データモデル内のオブジェクトに使われる Roblox の基本クラス。">Instance</a>?</code></pre>

指定した名前の直下の子を返します。なければ `nil` を返します。

### パラメーター

| パラメーター | 型 | 説明 |
| --- | --- | --- |
| `parent` | <a class="arbor-type-link" href="https://create.roblox.com/docs/reference/engine/classes/Instance" data-tooltip="Instance - データモデル内のオブジェクトに使われる Roblox の基本クラス。">`Instance`</a> | 検索する instance。 |
| `name` | `string` | 探す直下の子名。 |

### 戻り値

| 型 | 説明 |
| --- | --- |
| <a class="arbor-type-link" href="https://create.roblox.com/docs/reference/engine/classes/Instance" data-tooltip="Instance - データモデル内のオブジェクトに使われる Roblox の基本クラス。">`Instance`</a>`?` | 一致する子があれば、その instance。 |

### コード例

```lua
local maybeStringModule = Arbor.FindChild(script.Parent.Fixture, "String")
```

## ExpectChild

### 呼び出し形式

<pre><code>Arbor.ExpectChild(parent: <a class="arbor-type-link" href="https://create.roblox.com/docs/reference/engine/classes/Instance" data-tooltip="Instance - データモデル内のオブジェクトに使われる Roblox の基本クラス。">Instance</a>, name: string): <a class="arbor-type-link" href="https://create.roblox.com/docs/reference/engine/classes/Instance" data-tooltip="Instance - データモデル内のオブジェクトに使われる Roblox の基本クラス。">Instance</a></code></pre>

指定した名前の直下の子を返します。なければエラーにします。

### パラメーター

| パラメーター | 型 | 説明 |
| --- | --- | --- |
| `parent` | <a class="arbor-type-link" href="https://create.roblox.com/docs/reference/engine/classes/Instance" data-tooltip="Instance - データモデル内のオブジェクトに使われる Roblox の基本クラス。">`Instance`</a> | 検索する instance。 |
| `name` | `string` | 必須として探す直下の子名。 |

### 戻り値

| 型 | 説明 |
| --- | --- |
| <a class="arbor-type-link" href="https://create.roblox.com/docs/reference/engine/classes/Instance" data-tooltip="Instance - データモデル内のオブジェクトに使われる Roblox の基本クラス。">`Instance`</a> | 一致する子 instance。 |

### エラー

| 条件 | 内容 |
| --- | --- |
| 子がない | 子が見つからないとき、エラーにする。 |

### コード例

```lua
local stringModule = Arbor.ExpectChild(script.Parent.Fixture, "String")
```

## 関連

- [子の型](children.md)
- [ランタイムローダー](runtime-loaders/index.md)
