---
title: "RuntimeLoaders"
---

# RuntimeLoaders

`RuntimeLoaders` には、ランタイムでの探索と明示した検証を組み合わせる小さな helper があります。

現在の公開メンバー:

| メンバー | ルートエイリアス | 概要 |
| --- | --- | --- |
| [LoadModuleMap.From](load-module-map.md) | `Arbor.LoadModules` | 直下の `ModuleScript` を読み込み、それぞれの `require` 結果を検証する。 |

ランタイムローダーは package lifecycle、registry、boot system の代わりではありません。読み込みの境界だけを小さく提供します。
