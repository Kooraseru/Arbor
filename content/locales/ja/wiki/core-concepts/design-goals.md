---
title: "設計目標"
---

# 設計目標

Arbor は意図して小さくしています。

## 目標

- Roblox のインスタンス階層 shape を Luau の型システムへ公開する
- 内部を目的ごとの source folder に分けても、公開ファサードは安定させる
- パッケージソースを調べやすく保つ
- 子名について 2 つ目の基準を作らない
- 検証が明示されているときは、動的なランタイム読み込みを残す
- 各 helper API を 1 ページで説明できる範囲に保つ

## 目標ではないもの

- runtime registries
- startup lifecycle
- recursive package discovery
- network serialization
- action dispatch
- package manager lockfiles

これらの責任が必要な機能は、別のパッケージか Arbor の外側にある adapter に置くべきです。
