---
title: "ベストプラクティス"
---

# ベストプラクティス

## 直接所有するツリーを優先する

自分のパッケージが所有するツリーから型を作ってください。

```lua
type Name = Arbor.ChildNames<typeof(script)>
```

関係のない game service や、外部から変更されるツリーを表そうとするのは避けてください。

## 動的な値は unknown のまま受ける

ランタイムの `require` 結果は `unknown` として入り、バリデーターを通して出るようにします。

呼び出し場所で動的な `require` を cast しないでください。

## いちばん小さい helper を選ぶ

使い分け:

- 子 ID には `ChildNames`
- 必ず存在する名前つきの子には `RequiredChild`
- checked または optional な名前つき子 lookup には `Child`
- 子名を正確なキーにした value map には `ChildRecord`
- 子名を正確なキーにした instance map には `ChildTypeRecord`
- クラスでしぼった子 table には `ChildrenOfClass`
- 関係チェックには `IsChildOf`、`IsAncestorOf`、`IsDescendantOf`
- 直下の ModuleScript を検証しながら読むには `LoadModules`

## ファサードに依存する

利用側コードでは `Arbor.*` の公開エイリアスを使ってください。

実装を無理なく保つため、下位 folder は分割されることがあります。API リファレンスに別の指定がない限り、実装の構造として扱ってください。
