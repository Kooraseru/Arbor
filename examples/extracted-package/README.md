# Extracted Package Example

This example is a checklist for proving Arbor behaves the same when consumed as an extracted package.

Expected workspace shape:

```txt
WorkspaceOrPackageRoot
  Packages
    Arbor
      src
  Examples
    ExtractedConsumer
      init.luau
      Kick.luau
      Ban.luau
```

Checks:

- The consumer requires Arbor from the extracted package location.
- Root facade usage works.
- Focused module usage works.
- Analyzer results match the in-repository examples.
- Runtime loader validation still owns ModuleScript return types.

This folder is documentation-only for now because extracted package paths depend on the consuming workspace or package manager. During export, add the concrete workspace layout chosen for public distribution.
