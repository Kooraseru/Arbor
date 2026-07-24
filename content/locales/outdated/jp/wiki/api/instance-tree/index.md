---
title: InstanceTree
---

# InstanceTree

`InstanceTree` には、アナライザーから見える直接の子向けの型ヘルパーが入っています。

これらのヘルパーは、次のような問いに答えます：

```txt
アナライザーはどの子名を見えているか？
1 つの子の型は何か？
直接の子名からどんなテーブル形状を導けるか？
どの直接の子が Roblox クラスに一致するか？
```

## ヘルパー

- [ChildNames](child-names.md)
- [ChildOf](child-of.md)
- [ChildRecord](child-record.md)
- [ChildrenOfClass](children-of-class.md)
- [ChildNamesOfClass](child-names-of-class.md)

## 境界

InstanceTree ヘルパーは、アナライザーから見えるツリー形状を証明します。`ModuleScript` の戻り値までは証明しません。
