---
title: Arbor
description: Luau と Roblox のためのコンパイル時階層ロジック。
---

# Arbor

<div class="arbor-hero">
  <img src="assets/brand/Billboard.svg" alt="Arbor">
  <p>
    Luau と Roblox のためのコンパイル時階層ロジック。
  </p>
</div>

Arbor は、Roblox のデータモデルにコンパイル時の型付けをもたらす Luau ライブラリです。型レベルの名前、子の検索型、クラス別の子テーブル、そして検証付きランタイムローディングを提供します。

主な役割は、Roblox のインスタンス階層を Luau の型システムに公開し、アナライザーから見えるツリーをもとにコンパイル時のパッケージ基盤を作れるようにすることです。

## ここから始める

- [インストール](install.md)
- [例](examples.md)
- [API リファレンス](api/instance-tree/index.md)
- [ランタイムローダー](runtime-loaders.md)
- [リリースノート](reference/release-notes.md)

## Arbor が証明すること

Arbor は、アナライザーから見える構造を公開します：

```txt
直接の子の名前
直接の子の lookup
クラスで絞り込んだ子の名前
クラスで絞り込んだ子のレコード
```

`ModuleScript` の戻り値の型までは証明しません。ランタイムでロードした値には、引き続き検証が必要です。

## パッケージ境界

Arbor は、レジストリ、ライフサイクル、シリアライズ、ディスパッチ、ディスクリプター、パイプライン順序、パッケージルックアップ を受け持ちません。

## リリースノート

- [リリースノート](reference/release-notes.md)
- [変更履歴](reference/changelog.md)
