# ランタイムローダーの例

この例は、Arbor のランタイムローダー境界を確認します：

- `LoadModuleMap.From(script, validateAction)` は、直接の子 `ModuleScript` を `require` します。
- 生の `require` 結果は `unknown` として入ってきます。
- バリデーターが、生のロード済みアクション名を `ActionDefinition` に変換します。
- 呼び出し側は、検証後の型付き map を受け取ります。

スクリーンショットの対象：

- `Kick` と `Ban` が直接の子 `ModuleScript` としてある Explorer ツリー。
- `LoadModuleMap.From` と `validateAction` が書かれている `init.luau`。
- 正常にロードできたときのランタイム出力。
- どちらかの子モジュールから一時的に string ではない値を返したときのランタイムエラー。

壊したモジュール形状はコミットしないでください。検証境界のスクリーンショット用としてだけ使ってください。
