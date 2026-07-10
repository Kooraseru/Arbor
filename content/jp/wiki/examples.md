---
title: 例
---

# 例

例は `content/jp/examples/` に置かれていて、チェック済みのファイルから wiki に取り込まれます。

それぞれの例は、同じ形にそろえています：

```txt
問題
ソース
結果
なぜ動くのか
```

まずは直接の子から始めて、そのあとクラスフィルタリングとランタイム検証へ進みます。

- [直接の子](examples/direct-children.md)
- [クラスフィルタリング](examples/class-filtering.md)
- [ランタイム検証](examples/runtime-validation.md)
- [パッケージ抽出](examples/package-extraction.md)

例は、まずソースフィクスチャであり、その次に wiki の素材です。ここで取り込まれているソースブロックを変えるなら、リポジトリ内でもアナライザーチェックされるべきです。

アナライザーフィクスチャの取り決めは、[アナライザーフィクスチャ](reference/analyzer-fixtures.md) にあります。
