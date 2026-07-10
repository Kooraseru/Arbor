---
title: Examples
---

# Examples

Examples are stored under `content/en/examples/` and included into the wiki from those checked files.

Each example follows the same shape:

```txt
problem
source
result
why it works
```

Start with direct children, then move into class filtering and runtime validation.

- [Direct Children](examples/direct-children.md)
- [Class Filtering](examples/class-filtering.md)
- [Runtime Validation](examples/runtime-validation.md)
- [Package Extraction](examples/package-extraction.md)

The examples are source fixtures first and wiki material second. If an included source block changes here, it should also be analyzer-checked in the repository.

The analyzer fixture contract lives in
[Analyzer Fixtures](reference/analyzer-fixtures.md).
