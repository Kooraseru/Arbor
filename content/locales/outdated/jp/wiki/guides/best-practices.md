---
title: ベストプラクティス
---

# ベストプラクティス

## 直接所有しているものを優先する

自分のパッケージが所有しているツリーから型を導いてください。

```lua
type Name = Arbor.ChildNames<typeof(script)>
```

関係ない game service や、外部から変更されるツリーを無理に記述しようとするのは避けてください。

## 動的な値は unknown のままにする

ランタイムの `require` 結果は `unknown` として入り、バリデーターを通って出るべきです。

呼び出し側で動的な `require` をキャストしないでください。

## いちばん小さいヘルパーを選ぶ

使い分けはこうです：

- ID には `ChildNames`
- 子インスタンス 1 つには `ChildOf`
- 正確な子キーを持つ map には `ChildRecord`
- クラスで絞り込んだ子テーブルには `ChildrenOfClass`
- 検証つきの直接の子 `ModuleScript` ロードには `LoadModuleMap`
