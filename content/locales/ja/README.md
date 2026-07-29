<div align="center">
  <img src="../../assets/brand/Billboard.svg" alt="Arbor" width="860">
  <h3>Luau のための型付き Roblox インスタンスツリー。</h3>

  <p>
    <a href="https://github.com/Kooraseru/Arbor"><img alt="Stars + Issues + License" src="https://shieldcn.dev/group/github/stars/Kooraseru/Arbor+github/Kooraseru/Arbor/issues+github/license/Kooraseru/Arbor.svg?variant=outline"></a>
    <br>
    <a href="https://github.com/Kooraseru/Arbor/releases"><img alt="Releases" src="https://shieldcn.dev/github/Kooraseru/Arbor/release.svg?variant=outline"></a>
  </p>

  <img src="https://counter.seku.su/cmoe?name=Kooraseru&theme=mb">

  <!-- NAVIGATION -->
  <table>
    <tr>
      <td align="center"><a href="#機能">機能</a></td>
      <td align="center"><a href="#クイックスタート">クイックスタート</a></td>
      <td align="center"><a href="#ドキュメント">ドキュメント</a></td>
      <td align="center"><a href="#プロジェクト">プロジェクト</a></td>
    </tr>
  </table>

  <!-- LANGUAGES -->
  <table>
    <tr>
      <td align="center"><a href="../../../README.md">English</a></td>
      <td align="center">日本語</td>
    </tr>
  </table>
</div>

## 機能

Arbor は、Luau が Roblox のインスタンス階層をコンパイル時に理解できるようにする小さなパッケージです。[^compile-time]

- 直下の子名を `"Kick" | "Ban"` のようなチェック済み文字列 union にできます。
- 子名をキーにした record 型を、手書き manifest なしで作れます。[^manifests]
- `ModuleScript` など、アナライザーから見える Roblox クラスで直下の子を絞り込めます。
- 直下の `ModuleScript` 子を、明示的なバリデーターを通してランタイムで読み込めます。[^runtime-validator]
- ランタイム読み込みとコンパイル時のツリー型付けを分けて扱えます。

## クイックスタート

### インストール

プロジェクトやパッケージマネージャーが required modules として見つけられる場所に `Arbor` を置きます。

利用環境の module reference からパッケージルートを `require` します。

```lua
local Arbor = require(path.to.Arbor)
```

単体パッケージ内で使う場合、Arbor 内部の require は `@self` と目的別の子モジュールを使います。

### 例

この例では、直下の ModuleScript 子から型付き action table を作ります。子名はアナライザーから見えるツリーに由来し、読み込まれた module 値は明示的なランタイムバリデーターを通ります。

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

子モジュール名が `Kick` と `Ban` の場合、`ActionId` は `"Kick" | "Ban"` になり、`actions` はそのキーを持つ table としてチェックされます。

### API とツール

Arbor は次のような API を公開します。

<table>
  <tr>
    <td><code>ChildNames&lt;T&gt;</code></td>
    <td>直下の子名 union。</td>
  </tr>
  <tr>
    <td><code>ChildRecord&lt;T, V&gt;</code></td>
    <td>子名をキーにした table shape。</td>
  </tr>
  <tr>
    <td><code>ChildOf&lt;T, Name&gt;</code></td>
    <td>指定した直下の子 1 つの、アナライザーから見える型。</td>
  </tr>
  <tr>
    <td><code>ChildNamesOfClass&lt;T, ClassType&gt;</code></td>
    <td>クラスで絞り込んだ子名 union。</td>
  </tr>
  <tr>
    <td><code>ChildrenOfClass&lt;T, ClassType&gt;</code></td>
    <td>クラスで絞り込んだ子 table。</td>
  </tr>
  <tr>
    <td><code>LoadModuleMap.From(root, validate)</code></td>
    <td>直下の ModuleScript 子を検証しながら読み込むランタイム helper。</td>
  </tr>
</table>

ルートファサード export:

```txt
Arbor.ChildNames<T>
Arbor.ChildNamesOfClass<T, ClassType>
Arbor.ChildRecord<T, V>
Arbor.ChildOf<T, Name>
Arbor.ChildrenOfClass<T, ClassType>
Arbor.ModuleValidator<T>
```

ランタイムローダー export:

```txt
RuntimeLoaders/LoadModuleMap.From(root, validate)
```

## ドキュメント

wiki source は `content/pages/wiki/` と locale data から生成されます。

- [ホーム](https://kooraseru.github.io/Arbor/ja/)
- [子の型 API](https://kooraseru.github.io/Arbor/ja/api/children/)
- [Runtime Loaders](https://kooraseru.github.io/Arbor/ja/api/runtime-loaders/)
- [FAQ](https://kooraseru.github.io/Arbor/ja/faq/)

### 要件

これらの helper は、現在の Luau アナライザーが直下の子を literal extern property として見えることに依存します。

Roblox Studio:

- Arbor をランタイムで使うだけなら追加の外部ツールは不要です。

VS Code など外部エディターの workflow では次が必要です。

- Roblox インスタンスツリーをアナライザーへ公開する sourcemap/data-model provider[^sourcemap]
- [Luau LSP](https://github.com/JohnnyMorganz/luau-lsp)、またはその sourcemap を理解できる同等の Luau アナライザー統合

API ごとの要件:

- `ChildNames<T>`、`ChildRecord<T, V>`、`ChildOf<T, Name>` は、直下の子がアナライザーから property として見える必要があります。
- `ChildNamesOfClass<T, ClassType>` と `ChildrenOfClass<T, ClassType>` は、それらの子についてアナライザーから Roblox クラス metadata も見える必要があります。
- `LoadModuleMap.From(root, validate)` はランタイム Luau コードなので、アナライザーから子が見えなくても動きます。ただし、型付き caller は上の子名 helper から恩恵を受けます。

> [!NOTE]
> 子名 discovery を公開 API として扱う前に、対象の solver/toolchain で検証してください。

## プロジェクト

Arbor は solo developer によって保守されています。Issue、ドキュメント修正、例、小さな pull request は歓迎です。このパッケージが時間の節約や型安全性に役立つなら sponsorship もとても助かります。

- [Sponsor Kooraseru](https://github.com/sponsors/Kooraseru)

### バージョン

- [Releases](https://github.com/Kooraseru/Arbor/releases) には公開バージョンと downloadable asset があります。
- [CHANGELOG.md](../../../CHANGELOG.md) には生成された package history の概要があります。

### ライセンス

Apache License 2.0。詳しくは [LICENSE](../../../LICENSE) を見てください。

### Contributors

<a href="https://github.com/Kooraseru/Arbor/graphs/contributors" target="_blank">
  <img src="https://contrib.rocks/image?repo=Kooraseru/Arbor" />
</a>

#### Footnotes

[^compile-time]: Arbor は Luau type function と、アナライザーから見える Roblox tree metadata を通して動きます。Arbor 自体が Roblox のランタイム挙動を変えるわけではありません。
[^manifests]: 子 ModuleScript や instance 名が、これらの helper にとっての source of truth です。
[^runtime-validator]: バリデーターは、生の `require` 結果をプロジェクト所有の型付き値へ変換する境界です。
[^sourcemap]: 外部エディターでは、子名やクラスを見る前に、アナライザーが Roblox tree のモデルを持つ必要があります。

