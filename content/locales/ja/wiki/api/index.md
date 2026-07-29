---
title: "API リファレンス"
description: "Arbor の公開 API リファレンス。"
---

# API リファレンス

Arbor は 1 つのパッケージルートと、少数の公開メンバーを提供します。

ルートファサードが、利用側の正式な入口です。

```lua
local Arbor = require(path.to.Arbor)
```

## まとめ

| メンバー | 種類 | 用途 |
| --- | --- | --- |
| `Arbor.Version` | 値 | 現在のパッケージバージョン文字列。 |
| `Arbor.EntryProtocolVersion` | 値 | ファサード metadata の protocol version。 |
| `Arbor.CollectChildren` | 関数 | 直下の子を名前をキーにして返す。 |
| `Arbor.FindChild` | 関数 | 指定名の直下の子、または `nil` を返す。 |
| `Arbor.ExpectChild` | 関数 | 指定名の直下の子を返し、なければエラーにする。 |
| `Arbor.LoadModules` | 関数 | 直下の `ModuleScript` を検証しながら読み込む。 |
| `Arbor.Child` | 型 | 直下の子 1 つを名前から、checked・optional・required の mode で解決する。 |
| `Arbor.RequiredChild` | 型 | 必須の直下の子 1 つを名前から解決する。 |
| `Arbor.ChildNames` | 型 | アナライザーから見える直下の子名の union。 |
| `Arbor.ChildNamesOfClass` | 型 | 指定クラスに一致する直下の子名の union。 |
| `Arbor.ChildOf` | 型 | 親の直下の子である場合だけ、子の型を残す。 |
| `Arbor.ChildRecord` | 型 | 直下の子名をキーにし、指定した value type を持つ table。 |
| `Arbor.ChildTypeRecord` | 型 | 直下の子名をキーにし、それぞれの子 instance type を持つ table。 |
| `Arbor.ChildrenOfClass` | 型 | 指定クラスに一致する直下の子の table。 |
| `Arbor.IsChildOf` | 型 | 直下の子関係を boolean でチェックする。 |
| `Arbor.AncestorOf` | 型 | 関係が成立する場合だけ祖先型を残す。 |
| `Arbor.DescendantOf` | 型 | 関係が成立する場合だけ子孫型を残す。 |
| `Arbor.IsAncestorOf` | 型 | 祖先関係を boolean でチェックする。 |
| `Arbor.IsDescendantOf` | 型 | 子孫関係を boolean でチェックする。 |
| `Arbor.Mold` | 型 | 低レベルの型関数 Mold primitive。 |
| `Arbor.Run` | 型 | 低レベルの molded definition resolver。 |
| `Arbor.Resolve1` | 型 | 1 つの型引数で definition を解決する。 |
| `Arbor.Resolve2` | 型 | 2 つの型引数で definition を解決する。 |

## API グループ

| グループ | 内容 |
| --- | --- |
| [ランタイムメンバー](runtime.md) | `CollectChildren`、`FindChild`、`ExpectChild`。 |
| [子の型](children.md) | 名前つき子 lookup、子名 union、正確な child record、クラスでしぼった子。 |
| [関係型](relations.md) | 直下の子・祖先・子孫の filter / check。 |
| [Definition Runtime](definitions.md) | 低レベルの `Mold`、`Run`、`Resolve1`、`Resolve2` エイリアス。 |
| [ランタイムローダー](runtime-loaders/index.md) | 直下の `ModuleScript` を検証しながら読み込む。 |

## 境界

Arbor のリファレンスページは、`src/arbor@1.1.0/init.luau` から export される公開 API を説明します。

`Authoring`、`Definitions`、`Mold`、`Run` の下にあるページは、ルートファサードが公開エイリアスを export していない限り実装向けです。公開 API の説明に役立つ場合だけ、分割しやすい内部構造としてドキュメント化します。
