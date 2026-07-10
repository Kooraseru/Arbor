---
title: エクスポートと CI
---

# エクスポートと CI

## リポジトリ形状

```txt
Arbor/
  src/
    init.luau
    InstanceTree/
    RuntimeLoaders/
  content/
    README.md
    en/
      wiki/
      examples/
    jp/
      README.md
      CONTRIBUTING.md
      wiki/
      examples/
  release-notes/
  README.md
  RULES.md
  CHANGELOG.md
  CONTRIBUTING.md
  LICENSE
```

## CI チェック

CI では次を検証します：

```txt
Luau 解析が通る
game-rooted な require alias がない
危険度の高い any キャストがない
README と content examples がまだ妥当
パッケージ抽出の smoke test が通る
パッケージ RBXM エクスポートが通る
```

CI は次のブランチで動きます：

```txt
main
canary
ci
```

GitHub Pages は `main` から動きます。パッケージリリースはバージョンタグから作成されます。

## RBXM エクスポート

RBXM エクスポートは、`src/` を `Arbor` という名前のトップレベル `ModuleScript` としてパッケージ化します。

`content/en/examples/` は意図的に含めません。これらの例は、それぞれのアナライザーコンテキストを持つリポジトリフィクスチャです。エクスポート済みパッケージの下にバンドルすると、パスの前提が変わってしまいます。

リリースアセットへ組み込む前に、ローカルでエクスポートを実行してください：

=== "Windows PowerShell"

    ```powershell
    bash .github/scripts/export-rbxm.sh
    ```

=== "Linux Bash"

    ```bash
    bash .github/scripts/export-rbxm.sh
    ```

=== "macOS Bash/Zsh"

    ```bash
    bash .github/scripts/export-rbxm.sh
    ```

生成されたモデルは `.tmp/results/export/rbxm-export/result/Arbor.rbxm` に書き込まれます。エクスポーターは `rbx_dom_weak` と `rbx_binary` でモデルを書き込み、そのあと読み戻してルート形状を検証します。

## リリースノート

リリースノートは Markdown ファイルです：

```txt
release-notes/Stable/v1.0.0.md
release-notes/Pre-release/v1.1.0-canary.1.md
```

安定版リリースノートは、安定版 GitHub release body と、`CHANGELOG.md` 内の安定版パッケージ履歴の要約に使われます。

プレリリースノートは、プレビューリリース用の案内です。ブランチ名やタグサフィックスが `canary` でも、公開向けには `Pre-release` というチャンネル名を使います。

## バージョンタグ

```txt
v1.<release>.<patch>
v1.<release>.<patch>-canary.N
```

パッケージの変更だけがパッケージバージョンを作ります。ドキュメント、ワークフロー、例、メディア、リポジトリ保守は、それ単体ではパッケージバージョンを作りません。

安定版リリースには次を添付します：

```txt
Arbor.rbxm
```

## Pages

GitHub Pages サイトは、MkDocs Material を使って `content/en/wiki/` からビルドされます。

ドキュメントワークフローの変更を push する前に、ローカルの Pages ワークフロー形状を実行してください：

=== "Windows PowerShell"

    ```powershell
    bash .github/scripts/test-pages-workflow.sh
    ```

=== "Linux Bash"

    ```bash
    bash .github/scripts/test-pages-workflow.sh
    ```

=== "macOS Bash/Zsh"

    ```bash
    bash .github/scripts/test-pages-workflow.sh
    ```

ローカルチェックは、ブランチ入力を `.tmp/results/pages/pages-workflow-test/workspace` の下に stage し、シミュレートした Pages artifact を `.tmp/results/pages/pages-workflow-test/result` に書き込みます。

Pages ワークフローは `github-pages` environment を通してデプロイします。GitHub が environment protection のメッセージでデプロイを拒否した場合は、リポジトリの environment ルールを更新してください：

```txt
Settings -> Environments -> github-pages -> Deployment branches and tags
```

`main` を許可するか、その environment の selected-branch 制限を外してください。
