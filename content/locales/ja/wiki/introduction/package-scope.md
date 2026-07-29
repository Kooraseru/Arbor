---
title: "データモデルの範囲"
---

# データモデルの範囲

Roblox のデータモデルコードでは、よく 2 つの目的がぶつかります。

```txt
keep related instances organized as children
avoid hand-maintained string manifests
```

Arbor は、そのうちアナライザーから見える部分を扱います。Roblox のインスタンス階層を Luau の型システムへ公開し、その shape の上にコンパイル時の仕組みを作れるようにします。

## できること

- 直下の子名を取り出す
- 必須または任意の直下の子を解決する
- 子名を正確なキーにした record を作る
- アナライザーから見えるクラスで子をしぼる
- 子・祖先・子孫の関係をチェックする
- ランタイムの読み込みと検証を組み合わせる
- アナライザーが実際に見ているツリーから、データモデル境界をドキュメント化する

## やらないこと

Arbor 自体が registry、lifecycle、package manager、dispatch layer、serializer になることはありません。

この境界は重要です。Arbor は、アナライザーから見える Roblox ツリーをコードで表す手助けをしますが、その周りのランタイム動作までは所有しません。
