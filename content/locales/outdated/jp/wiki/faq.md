---
title: FAQ
---

# FAQ

## Arbor はコンパイル時にモジュールをロードしますか？

いいえ。Arbor の型関数は、アナライザーから見えるインスタンスメタデータを調べます。

## ChildNames は ModuleScript の戻り値の型を証明しますか？

いいえ。証明するのは直接の子の名前です。`ModuleScript` の戻り値はランタイムで検証してください。

## なぜ init.luau のファサードがあるのですか？

ルート alias が欲しい利用側にとって、ファサードがあると `require` まわりのノイズを減らせます：

```lua
Arbor.ChildNames<T>
Arbor.ChildRecord<T, V>
```

ローカルコードでは元の `.Of<T>` 名前空間 のほうが読みやすいこともあるため、用途別モジュールもそのまま使えます。
