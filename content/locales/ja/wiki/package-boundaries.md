---
title: パッケージ境界
---

# パッケージ境界

Arbor が答えるのは次です。

```txt
What static structure does the Luau analyzer know about an owned instance surface?
```

次には答えません。

```txt
what runtime modules exist
when startup happens
in what order behavior executes
how values cross the network
how privileged actions are exposed
what semantic concepts exist
```

## 持ってよい責任

```txt
type functions
typed lookup conventions
generated type surfaces when needed
analyzer-facing ids
small runtime loader helpers
small direct-child runtime helpers
```

## 持たない責任

```txt
runtime registries
boot sequencing
pipeline execution
serialization tags
dispatch parsing
descriptor identity
external package lookup
```

`RuntimeLoaders` は、動的な読み込みと検証を組み合わせる小さな helper なので許可されています。registry や lifecycle package へ育てないでください。

`Runtime.Children` は、直下の子を調べる基本 helper を公開するため許可されています。tree synchronization、source-map ownership、runtime topology system へ育てないでください。
