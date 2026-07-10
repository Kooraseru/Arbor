# コントリビュート

Arbor は意図的に小さく保っています。変更では、コンパイル時の型知識とランタイムの挙動の分離を保ってください。

> [!IMPORTANT]
> ランタイムでの検出とコンパイル時の型付けは別の関心事です。ローカルパッケージがモジュールをロードしやすくなるからといって、ここにランタイム挙動を追加しないでください。

## ローカルでの作業ルール

- パッケージソースを編集する前に、ルートの [`RULES.md`](../../RULES.md) を読んでください。
- 型関数は、アナライザーから見える事実に集中させてください。
- ここにランタイムレジストリ、ブート、シリアライズ、ディスパッチ、ディスクリプターの挙動を追加しないでください。
- パッケージ側に見せる型サーフェスには、ルートでエクスポートされた type alias を優先してください。
- アナライザーに直接見えるパスのほうが明確な場合に備えて、用途別の小さなモジュールは使える状態にしておいてください。

## 検証

変更を提案する前に、対象を絞った検証を実行してください：

```powershell
bash -n .github/scripts/write-release-notes.sh
bash -n .github/scripts/export-rbxm.sh
bash -n .github/scripts/test-pages-workflow.sh
powershell -ExecutionPolicy Bypass -File .github/scripts/analyze-luau.ps1
wsl fish ../../../.luau-lsp/analyze.fish src/Shared/Packages/Arbor/src/init.luau src/Shared/Packages/Arbor/content/en/examples/direct-children/init.luau src/Shared/Packages/Arbor/content/en/examples/class-filtered-children/init.luau src/Shared/Packages/Arbor/content/en/examples/runtime-loader/init.luau
bash .github/scripts/export-rbxm.sh
python -m mkdocs build --config-file .github\mkdocs.yml --site-dir ..\.tmp\results\docs\mkdocs-site
bash .github/scripts/test-pages-workflow.sh .tmp/results/pages/pages-workflow-test canary
git diff --check
```

チェックイン済みのアナライザーラッパーは、Packages ワークスペースの `.luau-lsp` sourcemap と global types を通して Arbor を検証します。Arbor の中に 2 つ目の global types ファイルや、エクスポート済みパッケージ向けの analyzer mirror を追加しないでください。

リポジトリ CI では、パッケージルートからの相対パスに置き換えて、これらと同等のチェックを実行してください。

## ブランチ

Arbor には 3 つの長期ブランチがあります：

```txt
main    公開用の安定パッケージライン
canary  main に昇格する前の早期機能
ci      テスト/CI 用ブランチ。公開ドキュメントやリリース用ではない
```

CI は 3 つすべてのブランチで動きます。GitHub Pages は `main` から動きます。パッケージリリースはバージョンタグから作成されます。

Pages のデプロイが environment protection で拒否された場合は、repository settings の `github-pages` environment を更新して、`main` がデプロイできるようにしてください。

## リリース

安定版パッケージのリリースノートは [`release-notes/Stable`](../../release-notes/Stable) にあります。

プレリリースノートは [`release-notes/Pre-release`](../../release-notes/Pre-release) にあります。`canary` ブランチと `-canary.N` タグサフィックスは実装上の仕組みです。公開向けのリリースノートでは `Pre-release` と書いてください。

[`CHANGELOG.md`](../../CHANGELOG.md) は安定版パッケージ履歴の要約です。ドキュメント、ワークフロー、メディア、リポジトリ保守タスクのすべてを追うための基準にはしないでください。

Arbor は連続した `v1` パッケージラインを使います：

```txt
v1.<release>.<patch>
```

プレリリースタグでは canary サフィックスを付けます：

```txt
v1.<release>.<patch>-canary.N
```

パッケージの変更だけがパッケージバージョンを作ります。ドキュメント、ワークフロー、例、メディア、リポジトリ保守は、リリースに同梱される場合にリリースノートへ書いても構いませんが、それ単体ではパッケージバージョンを作りません。

安定版リリースには次を添付してください：

```txt
Arbor.rbxm
```

例はリポジトリ内だけに残し、エクスポートされたパッケージアセットには含めません。

## 設計メモ

ランタイムでの検出は、それ自体では静的な公開 API を作りません。呼び出し側がコンパイル時のキー検査を必要とするなら、アナライザーから見える子名の検出、生成済みサーフェス、または別の明示的な型付きサーフェスを使ってください。

> [!CAUTION]
> `any` やキャストで動的ローダーを無理やりアナライザーに通さないでください。動的境界では `unknown` を使い、検証してください。
