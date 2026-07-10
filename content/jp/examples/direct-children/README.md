# 直接の子の例

この例は、Arbor の基本的な共有挙動を確認します：

- `ChildNames<typeof(script)>` は直接の子の名前を取り出します。
- `ChildOf<typeof(script), "Kick">` は、アナライザーから見える子インスタンスの型を返します。
- `ChildRecord<typeof(script), ActionDefinition>` は、直接の子の名前をキーにしたテーブル形状を作ります。

スクリーンショットの対象：

- `direct-children` の下に、`Kick` と `Ban` が直接の子 `ModuleScript` としてある Explorer ツリー。
- Arbor の型を エクスポートしている `init.luau`。
- アナライザーが `"Kick"` と `"Ban"` を `ActionId` として受け入れること。
- ワークスペースで一時的に試したとき、関係ない名前をアナライザーが拒否すること。

わざと拒否されるテスト行はコミットしないでください。スクリーンショットだけ撮れば十分です。
