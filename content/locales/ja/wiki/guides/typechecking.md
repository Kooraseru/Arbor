---
title: 型チェック
---

# 型チェック

Arbor は、使っている Luau アナライザーが所有ツリーの直下の子を literal property として公開することに依存します。

期待どおりに型がしぼられないときは、まずアナライザーから見えているかを調べてください。

## 最小チェック

```lua
local valid: Arbor.ChildNames<typeof(script)> = "Kick"
local invalid: Arbor.ChildNames<typeof(script)> = "Nope"
```

アナライザーからパッケージツリーが見えていて、`Nope` が直下の子でないなら、2 つ目の代入は失敗するはずです。

失敗しない場合、問題は Arbor のランタイム動作ではなく、アナライザーからの見え方か source-map 設定にある可能性が高いです。

## 診断する順番

次の順で確認します。

1. そのファイルは、意図した workspace で解析されていますか？
2. アナライザーから、Studio で見えるはずの Roblox ツリーと同じものが見えていますか？
3. `script.Kick` のような直接 property access は動きますか？
4. その子は子孫ではなく、直下の子ですか？
5. その子は、含まれている root または service の下にありますか？
6. source-map / data-model provider は最新ですか？
7. コンパイル時の型づけを試すつもりで、ランタイム読みこみを試していませんか？

## 直下の子を確かめる

パッケージローダー全体を debug する前に、小さな確認を使います。

```lua
export type ActionId = Arbor.ChildNames<typeof(script)>

local kick: ActionId = "Kick"
local nope: ActionId = "Nope"
```

期待する結果:

```txt
"Kick" is accepted.
"Nope" is rejected.
```

## クラスでしぼった結果を確かめる

クラスでしぼる helper では、アナライザーから子のクラスが見えていることを確認します。

```lua
export type ModuleChildName = Arbor.ChildNamesOfClass<typeof(script), ModuleScript>
```

module ではない子が結果の union に入る、または module の子が抜ける場合、調べるべきなのはアナライザーから見えるクラス情報です。

## ランタイムローダーを確かめる

ランタイムローダーの例では、不確かな値をバリデーター境界に残してください。

```lua
local actions = Arbor.LoadModules(script, validateAction)
```

呼び出し場所で `require` 結果を cast しないでください。バリデーターが shape を保証できないなら、バリデーターか読みこむモジュール contract を直してください。

## 次に読むもの

- [アナライザーモデル](../analyzer-model.md)
- [API リファレンス](../api/index.md)
