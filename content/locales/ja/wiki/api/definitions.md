---
title: Definition Runtime
description: Arbor の型関数 definition layer を分割するためのメモ。
---

# Definition Runtime

`Mold`、`Run`、`Resolve1`、`Resolve2` は、Arbor の生成ファサードが使う低レベルの公開エイリアスです。

多くの利用側コードでは、`ChildNames`、`RequiredChild`、`ChildrenOfClass`、`IsDescendantOf` などの名前つきエイリアスを優先してください。

## メンバー

| メンバー | 戻り値 | 概要 |
| --- | --- | --- |
| [`Mold`](#mold) | Mold 済み definition 型 | definition schema の最初の 2 つの generic parameter を差し替える。 |
| [`Run`](#run) | 解決後の型 | Mold 済みの Arbor definition を解決する。 |
| [`Resolve1`](#resolve1) | 解決後の型 | 1 つの型引数で definition を解決する。 |
| [`Resolve2`](#resolve2) | 解決後の型 | 2 つの型引数で definition を解決する。 |

## Mold

### 呼び出し形式

```lua
Arbor.Mold<Schema, First, Second>
```

definition schema の最初の 2 つの generic parameter を差し替えます。

### 型パラメーター

| パラメーター | 説明 |
| --- | --- |
| `Schema` | 型関数の definition schema。 |
| `First` | 最初の generic parameter に入れる型。 |
| `Second` | 2 つ目の generic parameter に入れる型。 |

### 戻り値

| 型 | 説明 |
| --- | --- |
| Mold 済み definition 型 | Arbor の最初と 2 つ目の型引数を差し替えた definition schema。 |

## Run

### 呼び出し形式

```lua
Arbor.Run<Molded>
```

Mold 済みの Arbor definition を最終型へ解決します。

### 型パラメーター

| パラメーター | 説明 |
| --- | --- |
| `Molded` | Mold 済みの Arbor definition table。 |

### 戻り値

| 型 | 説明 |
| --- | --- |
| 解決後の型 | Mold 済みの Arbor definition が作る最終型。 |

## Resolve1

### 呼び出し形式

```lua
Arbor.Resolve1<Definition, First>
```

1 つの型引数で definition を Mold し、解決します。

### 型パラメーター

| パラメーター | 説明 |
| --- | --- |
| `Definition` | 型関数 definition。 |
| `First` | 最初の型引数。 |

### 戻り値

| 型 | 説明 |
| --- | --- |
| 解決後の型 | `Definition` に `First` を入れて Mold と Run をした最終型。 |

## Resolve2

### 呼び出し形式

```lua
Arbor.Resolve2<Definition, First, Second>
```

2 つの型引数で definition を Mold し、解決します。

### 型パラメーター

| パラメーター | 説明 |
| --- | --- |
| `Definition` | 型関数 definition。 |
| `First` | 最初の型引数。 |
| `Second` | 2 つ目の型引数。 |

### 戻り値

| 型 | 説明 |
| --- | --- |
| 解決後の型 | `Definition` に `First` と `Second` を入れて Mold と Run をした最終型。 |

## 分割境界

API リファレンスを source folder ごとではなく公開メンバーのグループごとに分ける主な理由が、この layer です。

`Definitions/` の内部 tag、projection、関係チェック、source が増えても、すべての実装ファイルを利用側 API page にする必要はありません。下位ファイルを意図した extension point にしない限り、公開ドキュメントはルートファサードに合わせてください。

## 関連

- [API リファレンス](index.md)
- [子の型](children.md)
- [関係型](relations.md)
