---
title: 型チェック
---

# 型チェック

Arbor は、いま動いている Luau アナライザーが、所有された直接の子をリテラルなプロパティとして公開していることに依存します。

型が期待どおりに絞り込まれない場合は、まずアナライザーからの可視性を調べてください。

## 最小チェック

```lua
local valid: Arbor.ChildNames<typeof(script)> = "Kick"
local invalid: Arbor.ChildNames<typeof(script)> = "Nope"
```

アナライザーからパッケージツリーが見えていて、`Nope` が直接の子ではないなら、2 つ目の代入は失敗するはずです。

失敗しない場合、問題は Arbor のランタイム挙動ではなく、アナライザー可視性か sourcemap 設定にある可能性が高いです。

## 診断の順番

この順番で確認してください：

1. そのファイルは意図したワークスペースで解析されていますか？
2. アナライザーは、Studio で見えるはずの Roblox ツリーと同じものを見ていますか？
3. `script.Kick` のような直接のプロパティアクセスは動きますか？
4. その子は子孫ではなく、直接の子ですか？
5. その子は、含まれている root または service の下にありますか？
6. sourcemap/data-model provider は最新ですか？
7. コンパイル時の型付けを試すつもりで、ランタイムロードをテストしていませんか？

## 直接の子の証明

パッケージローダー全体を debug する前に、小さな証明を使ってください：

```lua
export type ActionId = Arbor.ChildNames<typeof(script)>

local kick: ActionId = "Kick"
local nope: ActionId = "Nope"
```

期待する結果：

```txt
"Kick" は受け入れられます。
"Nope" は拒否されます。
```

## クラスで絞り込む証明

クラスで絞り込むヘルパーでは、アナライザーから子のクラスが見えていることを確認してください：

```lua
export type ModuleChildName = Arbor.ChildNamesOfClass<typeof(script), ModuleScript>
```

モジュールではない子が結果の union に入っていたり、モジュールの子が抜けていたりする場合、見るべきものはアナライザーから見えるクラスメタデータです。

## ランタイムローダーの証明

ランタイムローダーの `content/jp/examples` では、不確実さをバリデーター境界に置くべきです：

```lua
local actions = LoadModuleMap.From(script, validateAction)
```

呼び出し側で `require` 結果をキャストしないでください。バリデーターが形を証明できないなら、バリデーターかロードされるモジュールの契約を直してください。

## 次に読む

- [アナライザーモデル](../analyzer-model.md)
- [直接の子の例](../examples/direct-children.md)
- [ランタイム検証の例](../examples/runtime-validation.md)
