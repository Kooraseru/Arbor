<div align="center">
  <img src="../../assets/brand/Billboard.svg" alt="Arbor" width="860">
  <h3>Luau 向けの型安全な Roblox インスタンスツリー。</h3>

  <p>
    <a href="https://github.com/Kooraseru/Arbor"><img alt="Stars + Issues + License" src="https://shieldcn.dev/group/github/stars/Kooraseru/Arbor+github/Kooraseru/Arbor/issues+github/license/Kooraseru/Arbor.svg?variant=outline"></a>
    <br>
    <a href="https://github.com/Kooraseru/Arbor/releases"><img alt="Releases" src="https://shieldcn.dev/github/Kooraseru/Arbor/release.svg?variant=outline"></a>
  </p>

  <img src="https://counter.seku.su/cmoe?name=Kooraseru&theme=mb">

  <!-- NAVIGATION -->
  <table>
    <tr>
      <td align="center"><a href="#features">機能</a></td>
      <td align="center"><a href="#quick-start">クイックスタート</a></td>
      <td align="center"><a href="#documentation">ドキュメント</a></td>
      <td align="center"><a href="#project">プロジェクト</a></td>
    </tr>
  </table>

  <!-- LANGUAGES -->
  <table>
    <tr>
      <td align="center"><a href="../../README.md">English</a></td>
      <td align="center">日本語</td>
    </tr>
  </table>
</div>

<a id="features"></a>

## 機能

Arbor は、Luau が Roblox のインスタンス階層をコンパイル時に理解できるようにするライブラリです。[^compile-time]

- 直接の子の名前は、`"Kick" | "Ban"` のようなチェック可能な文字列ユニオンになります。
- 子ごとのレコードは、手で管理するマニフェストなしで型付けできます。[^manifests]
- 直接の子は、`ModuleScript` のように、アナライザーから見える Roblox クラスで絞り込めます。
- 直接の `ModuleScript` の子は、明示的なバリデーターを通してランタイムでロードできます。[^runtime-validator]
- ランタイムでのロードと、コンパイル時のツリー型付けは分けたままにします。

<a id="quick-start"></a>

## クイックスタート

### インストール

`Arbor` を、プロジェクトやパッケージマネージャーから `require` できる場所に置きます。

環境が提供するモジュール参照を使って、パッケージルートを `require` します：

```lua
local Arbor = require(path.to.Arbor)
```

スタンドアロンパッケージの内部で使う場合、Arbor 内部の `require` は `@self` と用途別の子モジュールを使います。

### 例

この例では、直接の `ModuleScript` の子から型付きのアクションテーブルを作ります。子の名前はアナライザーから見えるツリーから取得されます。一方で、ロードされたモジュールの値は引き続き明示的なランタイムバリデーターを通ります。

```lua
local Arbor = require(path.to.Arbor)

local LoadModuleMap = Arbor.RuntimeLoaders.LoadModuleMap

type ActionDefinition = {
	Run: (playerName: string) -> (),
}

local function validateAction(value: unknown, moduleScript: ModuleScript): ActionDefinition
	if type(value) ~= "string" then
		error(`{moduleScript:GetFullName()} must return an action name`)
	end

	local actionName = value

	return {
		Run = function(playerName: string)
			print(`{actionName} {playerName}`)
		end,
	}
end

export type ActionId = Arbor.ChildNames<typeof(script)>
export type ActionMap = Arbor.ChildRecord<typeof(script), ActionDefinition>

local actions: ActionMap = LoadModuleMap.From(script, validateAction)

actions.Kick.Run("Builder")
actions.Ban.Run("Spammer")

return actions
```

`Kick` と `Ban` という名前の子モジュールがある場合、`ActionId` は `"Kick" | "Ban"` になり、`actions` はそれらのキーを持つテーブルとしてチェックされます。

### API とツール

これらのワークフローを支えるために、Arbor は次を公開しています：

<table>
  <tr>
    <td><code>ChildNames&lt;T&gt;</code></td>
    <td>直接の子の名前ユニオン。</td>
  </tr>
  <tr>
    <td><code>ChildRecord&lt;T, V&gt;</code></td>
    <td>子の名前をキーにしたテーブル形状。</td>
  </tr>
  <tr>
    <td><code>ChildOf&lt;T, Name&gt;</code></td>
    <td>名前で指定した直接の子 1 つについて、アナライザーから見える型。</td>
  </tr>
  <tr>
    <td><code>ChildNamesOfClass&lt;T, ClassType&gt;</code></td>
    <td>クラスで絞り込んだ子の名前ユニオン。</td>
  </tr>
  <tr>
    <td><code>ChildrenOfClass&lt;T, ClassType&gt;</code></td>
    <td>クラスで絞り込んだ子テーブル。</td>
  </tr>
  <tr>
    <td><code>LoadModuleMap.From(root, validate)</code></td>
    <td>直接の <code>ModuleScript</code> の子向けの、検証つきランタイムロード。</td>
  </tr>
</table>

ルートファサードのエクスポート：

```txt
Arbor.ChildNames<T>
Arbor.ChildNamesOfClass<T, ClassType>
Arbor.ChildRecord<T, V>
Arbor.ChildOf<T, Name>
Arbor.ChildrenOfClass<T, ClassType>
Arbor.ModuleValidator<T>
```

ルートのランタイムファサード：

```txt
Arbor.InstanceTree.ChildNames
Arbor.InstanceTree.ChildNamesOfClass
Arbor.InstanceTree.ChildRecord
Arbor.InstanceTree.ChildOf
Arbor.InstanceTree.ChildrenOfClass
Arbor.RuntimeLoaders.LoadModuleMap
```

用途別モジュールのエクスポート：

```txt
InstanceTree/ChildNames.Of<T>
InstanceTree/ChildNamesOfClass.Of<T, ClassType>
InstanceTree/ChildRecord.Of<T, V>
InstanceTree/ChildOf.Of<T, Name>
InstanceTree/ChildrenOfClass.Of<T, ClassType>
RuntimeLoaders/LoadModuleMap.From(root, validate)
```

<a id="documentation"></a>

## ドキュメント

日本語 wiki のソースは `content/jp/wiki/` にあります。wiki で参照する例は `content/jp/examples/` にあります。

- [ホーム](https://kooraseru.github.io/Arbor/jp/)
- [例](https://kooraseru.github.io/Arbor/jp/examples/)
- [InstanceTree API](https://kooraseru.github.io/Arbor/jp/api/instance-tree/)
- [Runtime Loaders](https://kooraseru.github.io/Arbor/jp/runtime-loaders/)
- [FAQ](https://kooraseru.github.io/Arbor/jp/faq/)

### 要件

これらのヘルパーは、使っている Luau アナライザーが直接の子をリテラルな extern プロパティとして公開していることに依存します。

Roblox Studio：

- Arbor をランタイムで使うだけなら、追加の外部ツールは不要です

VS Code などの外部エディターのワークフローでは、次が必要です：

- Roblox のインスタンスツリーをアナライザーへ公開する sourcemap/data-model provider[^sourcemap]
- [Luau LSP](https://github.com/JohnnyMorganz/luau-lsp)、またはその sourcemap を理解できる同等の Luau アナライザー連携

個別の API には、次が必要です：

- `ChildNames<T>`、`ChildRecord<T, V>`、`ChildOf<T, Name>` には、直接の子がアナライザーから見えるプロパティとして公開されている必要があります。
- `ChildNamesOfClass<T, ClassType>` と `ChildrenOfClass<T, ClassType>` には、それらの子について、アナライザーから見える Roblox クラスメタデータも必要です。
- `LoadModuleMap.From(root, validate)` はランタイム Luau コードなので、アナライザーから見える子は不要です。ただし、型付きの呼び出し側は上の子名ヘルパーの恩恵を受けられます。

> [!NOTE]
> 子名の検出を public API として扱う前に、対象のソルバー/ツールチェーンで検証してください。

<a id="project"></a>

## プロジェクト

Arbor は個人でメンテされています。Issue、ドキュメント修正、例の追加、小さめの pull request は歓迎です。このパッケージで時間が浮いたり、プロジェクトの型を保つ助けになったなら、スポンサーもかなりありがたいです。

- [Sponsor Kooraseru](https://github.com/sponsors/Kooraseru)

### バージョン

- [Releases](https://github.com/Kooraseru/Arbor/releases) には、公開済みバージョンとダウンロード可能なアセットが載っています。
- [Release notes](../../release-notes/Stable/v1.0.1.md) には、現在の安定版リリースの内容が書かれています。
- [Changelog](../../CHANGELOG.md) は、パッケージ履歴を要約しています。

### ライセンス

Apache License 2.0。詳しくは [LICENSE](../../LICENSE) を参照してください。

### コントリビューター

<a href="https://github.com/Kooraseru/Arbor/graphs/contributors" target="_blank">
  <img src="https://contrib.rocks/image?repo=Kooraseru/Arbor" />
</a>

#### 脚注

[^compile-time]: Arbor は Luau の型関数と、アナライザーから見える Roblox ツリーのメタデータを使って動きます。それ自体が Roblox のランタイム挙動を変えるわけではありません。
[^manifests]: 子の `ModuleScript` やインスタンス名そのものが、これらのヘルパーの基準になります。
[^runtime-validator]: バリデーターは、生の `require` 結果をプロジェクト側で所有する型付きの値に変える場所です。
[^sourcemap]: 外部エディターでは、アナライザーが子の名前やクラスを見る前に、Roblox ツリーのモデルが必要です。
