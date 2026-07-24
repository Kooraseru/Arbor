---
title: アナライザーフィクスチャ
---

# アナライザーフィクスチャ

状態：ドキュメント化されたフィクスチャの取り決め

`content/en/examples/` の下にあるチェック済みの例が、現在のアナライザー証明用フィクスチャです。

これらは意図的に小さくしています。それぞれのフィクスチャは、関係ないパッケージ挙動を混ぜ込まずに、アナライザー向けの主張を 1 つだけ証明するべきです。

ソースツリーの `content/en/examples` は、アナライザー証明用のサーフェスです。エクスポート済みパッケージの artifact はパッケージ形状についてチェックされますが、Arbor のソースツリー上での型解決挙動をチェックするものではありません。

## フィクスチャ一覧

| フィクスチャ | 主張 |
| --- | --- |
| `direct-children/` | 直接の子の名前、名前つき子ルックアップ、子名をキーにしたレコードは、アナライザーから見える直接の子から来ます。 |
| `class-filtered-children/` | クラスで絞り込んだ子テーブルには、要求されたクラスに一致する、アナライザーから見える直接の子が含まれます。 |
| `runtime-loader/` | 動的モジュールロードでは、生の `require` 結果を `unknown` のバリデーター境界に置きます。 |
| `extracted-package/` | エクスポート済みパッケージ形状は、`Arbor` を公開ルートとして保ち、`content/en/examples` を除外します。 |

## 必要なアナライザーチェック

チェックイン済みのラッパーは、Packages ワークスペースのアナライザー設定を通して、Arbor のソースツリー `content/en/examples` を検証します：

```powershell
powershell -ExecutionPolicy Bypass -File .github/scripts/analyze-luau.ps1
```

ソースツリーのアナライザー検証を実行するには：

```powershell
wsl fish .luau-lsp/analyze.fish src/Shared/Packages/Arbor/src/init.luau src/Shared/Packages/Arbor/content/en/examples/direct-children/init.luau src/Shared/Packages/Arbor/content/en/examples/class-filtered-children/init.luau src/Shared/Packages/Arbor/content/en/examples/runtime-loader/init.luau
```

このコマンドは Packages ワークスペースのルートから実行され、ワークスペースレベルに 1 つだけある `.luau-lsp/globalTypes.d.luau` と `.luau-lsp/sourcemap.json` を使います。Arbor の中に 2 つ目の global types ファイルを作らないでください。

ワークスペースのアナライザーレーンは次をチェックします：

```txt
content/en/examples/direct-children/init.luau
content/en/examples/class-filtered-children/init.luau
content/en/examples/runtime-loader/init.luau
src/init.luau
src/InstanceTree/*.luau
src/RuntimeLoaders/*.luau
```

## 手動のネガティブチェック

これらのチェックはスクリーンショットやツールチェーン検証には便利ですが、失敗するソースとしてコミットするべきではありません：

- `content/en/examples/direct-children/init.luau` で、`Arbor.ChildNames<typeof(script)>` に `"Nope"` を代入する。
- `content/en/examples/class-filtered-children/init.luau` で、`Arbor.ChildrenOfClass<typeof(script), ModuleScript>` に `{}` を代入し、アナライザーが `Ban` と `Kick` の欠落を報告することを確認する。
- runtime-loader の子モジュール 1 つから一時的に string ではない値を返し、`validateAction` が境界エラーを出すことを確認する。

## 現在の制限

将来、別の consuming-workspace sourcemap を意図的に定義するまでは、これをエクスポート済みパッケージのアナライザー検証で置き換えないでください。

エクスポート済みパッケージの検証は、将来、別の consuming-workspace sourcemap を意図的に定義するまでは、artifact 形状に集中させてください。
