---
title: アナライザー Fixture
---

# アナライザー Fixture

状態: ドキュメント化された fixture contract

チェック対象の package source files が、現在の analyzer proof fixture です。

小さいのは意図したものです。それぞれの fixture は、関係のないパッケージ動作を混ぜず、アナライザー向けの主張を 1 つだけ確認します。

source tree の package files が analyzer proof surface です。export したパッケージ artifact ではパッケージ shape を確認し、Arbor の source tree 上での型解決までは確認しません。

## Fixture 一覧

| Fixture | 確認すること |
| --- | --- |
| `src/arbor@1.1.0/Definitions/TypeFunctions/Children/Names/ChildNames.luau` | 直下の子名と、子名をキーにした record が、アナライザーから見える直下の子から作られる。 |
| `src/arbor@1.1.0/Definitions/TypeFunctions/Children/Checks/IsChildOf.luau` | 子・祖先・子孫の関係 helper が、アナライザーから見える fixture の子に対して解決される。 |
| `src/plugin/` | plugin 向け source がパッケージ payload の外に残る。 |
| generated publication payload | export したパッケージ shape で `Arbor` が公開ルートのままになり、repo-only source が除外される。 |

## 必須のアナライザーチェック

repo に入っている wrapper は、Packages workspace の analyzer setup を通して Arbor package source を検証します。

```powershell
powershell -ExecutionPolicy Bypass -File .github/scripts/analyze-luau.ps1
```

source tree の analyzer validation を実行:

```powershell
powershell -ExecutionPolicy Bypass -File .github\scripts\analyze-luau.ps1
```

この command は、settings、生成済み sourcemap、Roblox global types を含む Arbor の `tools/luau-lsp/` handler を使います。

対象をしぼった analyzer lane は、次のような Arbor source をチェックします。

```txt
src/arbor@1.1.0/init.luau
src/arbor@1.1.0/Definitions/TypeFunctions/**/*.luau
src/arbor@1.1.0/RuntimeLoaders/*.luau
```

## 手動の negative check

次のチェックは screenshot や toolchain validation には便利ですが、失敗する source として commit しないでください。

- `ChildNames` proof にありえない名前を代入し、アナライザーが拒否することを確認する
- `IsChildOf` proof に子ではない型を代入し、アナライザーが期待を拒否することを確認する

## 現在の制限

あとで利用側 workspace 用の sourcemap を明示して作らない限り、export 済みパッケージの検証は artifact shape に集中させてください。
