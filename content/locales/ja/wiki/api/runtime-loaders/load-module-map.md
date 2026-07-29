---
title: LoadModuleMap.From
---

# LoadModuleMap.From

直下の `ModuleScript` を読みこみ、それぞれの `require` 結果を検証します。

## 呼び出し形式

<pre><code>Arbor.RuntimeLoaders.LoadModuleMap.From&lt;T&gt;(
    root: <a class="arbor-type-link" href="https://create.roblox.com/docs/reference/engine/classes/Instance" data-tooltip="Instance - データモデル内のオブジェクトに使われる Roblox の基本クラス。">Instance</a>,
    validate: ModuleValidator&lt;T&gt;
): { [string]: T }</code></pre>

ルートエイリアス:

<pre><code>Arbor.LoadModules&lt;T&gt;(
    root: <a class="arbor-type-link" href="https://create.roblox.com/docs/reference/engine/classes/Instance" data-tooltip="Instance - データモデル内のオブジェクトに使われる Roblox の基本クラス。">Instance</a>,
    validate: ModuleValidator&lt;T&gt;
): { [string]: T }</code></pre>

バリデーター型:

```lua
export type ModuleValidator<T> = (value: unknown, moduleScript: ModuleScript) -> T
```

## パラメーター

| パラメーター | 型 | 説明 |
| --- | --- | --- |
| `root` | <a class="arbor-type-link" href="https://create.roblox.com/docs/reference/engine/classes/Instance" data-tooltip="Instance - データモデル内のオブジェクトに使われる Roblox の基本クラス。">`Instance`</a> | 直下の `ModuleScript` を読みこむ対象の instance。 |
| `validate` | `ModuleValidator<T>` | 生の `require` 結果を `unknown` として受け取り、受け入れた型つきの値を返す。 |

## 戻り値

| 型 | 説明 |
| --- | --- |
| `{ [string]: T }` | 直下の `ModuleScript.Name` をキーにした map。 |

## 動作

| ルール | 説明 |
| --- | --- |
| 直下の子 | `GetChildren()` で直下の子を読む。 |
| 順序 | 子を名前で sort する。 |
| しぼりこみ | `ModuleScript` ではない子を飛ばす。 |
| 重複名 | 同じ `ModuleScript` 名があればエラーにする。 |
| Require failure | `require` の失敗を module path つきで包む。 |
| Validator failure | バリデーターの失敗を module path つきで包む。 |

## コード例

```lua
type TypeModulesRecord = Arbor.ChildRecord<typeof(script.Parent.Fixture), TypeModule>

local modules: TypeModulesRecord = Arbor.LoadModules(script.Parent.Fixture, validateTypeModule)
```

## 組み合わせ

アナライザーから正確な子が見えていて、呼び出し境界でより厳密な table type が必要なら、`Arbor.ChildRecord<Root, T>` を使います。

## よくある間違い

- `unknown` を検証せず、`require` 結果を cast する。
- 子孫まで再帰的に読みこむと考える。
- registry や lifecycle system へ育てる。

## 関連

- [ランタイムローダー](index.md)
- [子の型](../children.md)
- [ランタイムの読みこみ](index.md)
