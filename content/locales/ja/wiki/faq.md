---
title: "FAQ"
---

# FAQ

## Arbor はコンパイル時にモジュールを読み込みますか？

いいえ。Arbor の型関数は、アナライザーから見えるインスタンス情報を調べます。

## ChildNames は ModuleScript の戻り値型を保証しますか？

いいえ。保証するのは直下の子名です。ModuleScript の戻り値はランタイムで検証してください。

## なぜ init.luau ファサードがあるのですか？

ファサードは安定した公開 API です。

```lua
Arbor.ChildNames<T>
Arbor.ChildRecord<T, V>
Arbor.LoadModules(root, validate)
```

実装を目的ごとのフォルダーへ分けても、利用側が source layout を追いかけずにすみます。

## Definitions や RuntimeLoaders の下を直接 require するべきですか？

API リファレンスで下位メンバーが公開と書かれていない限り、ルートファサードを使ってください。

実装フォルダーを直接 `require` すると、利用側コードが Arbor 内部の分け方に依存します。まさに避けたい依存です。

## ほぼコンパイル時のパッケージなのに、なぜランタイム関数がありますか？

ランタイム関数があるのは、Roblox から実際の `Instance` の子や動的な `require` 結果を受け取る境界だけです。

意図して小さくしています。registry、boot system、package discovery framework ではありません。
