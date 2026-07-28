---
title: {{wiki.analyzer_model.title}}
---

# {{wiki.analyzer_model.title}}

{{wiki.analyzer_model.intro}}

{{wiki.analyzer_model.model_boundary}}

## {{wiki.analyzer_model.rule_heading}}

{{wiki.analyzer_model.rule_intro}}

{{wiki.analyzer_model.owned_tree_intro}}

```txt
Actions
  Kick
  Ban
```

{{wiki.analyzer_model.this_type}}

```lua
export type ActionId = Arbor.ChildNames<typeof(script)>
```

{{wiki.analyzer_model.can_become}}

```lua
type ActionId = "Kick" | "Ban"
```

{{wiki.analyzer_model.visibility_condition}}

## {{wiki.analyzer_model.proves_heading}}

{{wiki.analyzer_model.proves_intro}}

```txt
direct child names
direct child lookup
class-filtered child names
class-filtered child records
direct child relations
ancestor and descendant relations
```

## {{wiki.analyzer_model.does_not_prove_heading}}

{{wiki.analyzer_model.does_not_prove_intro}}

```txt
what require(childModule) returns
whether runtime discovery found every expected module
whether CLI, Studio, and LSP analyzers expose identical metadata
```

{{wiki.analyzer_model.validate_runtime}}

## {{wiki.analyzer_model.runtime_loading_heading}}

{{wiki.analyzer_model.compile_time_shape}}

```lua
export type ActionId = Arbor.ChildNames<typeof(script)>
```

{{wiki.analyzer_model.runtime_behavior_intro}}

{{wiki.analyzer_model.runtime_behavior}}

{{wiki.analyzer_model.unknown_boundary}}

## {{wiki.analyzer_model.toolchain_notes_heading}}

{{wiki.analyzer_model.luau_lsp}}

{{wiki.analyzer_model.provider_boundary}}

## {{wiki.analyzer_model.next_heading}}

- [{{wiki.analyzer_model.next_typechecking}}](guides/typechecking.md)
- [{{wiki.analyzer_model.next_runtime_loading}}](api/runtime-loaders/index.md)
- [{{wiki.analyzer_model.next_api_reference}}](api/index.md)
