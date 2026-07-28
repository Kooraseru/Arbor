---
title: {{wiki.install.title}}
---

# {{wiki.install.title}}

{{wiki.install.place_package}}

{{wiki.install.require_root_intro}}

```lua
local Arbor = require(path.to.Arbor)
```

## {{wiki.install.package_requirements_heading}}

{{wiki.install.no_peer_dependencies}}

{{wiki.install.no_runtime_dependencies}}

## {{wiki.install.analyzer_visibility_heading}}

{{wiki.install.visibility_intro}}

{{wiki.install.visibility_example_intro}}

```lua
export type ActionId = Arbor.ChildNames<typeof(script)>
```

{{wiki.install.visibility_missing}}

## {{wiki.install.recommended_tooling_heading}}

{{wiki.install.luau_lsp}}

{{wiki.install.toolchains_intro}}

- {{wiki.install.toolchain_luau_lsp}}
- {{wiki.install.toolchain_provider}}

{{wiki.install.provider_boundary}}

## {{wiki.install.public_entry_heading}}

{{wiki.install.public_entry_intro}}

```lua
local Arbor = require(path.to.Arbor)
```

{{wiki.install.facade_exports}}

{{wiki.install.lower_level_folders}}

## {{wiki.install.next_heading}}

- [{{wiki.install.next_analyzer_model}}](analyzer-model.md)
- [{{wiki.install.next_typechecking}}](guides/typechecking.md)
- [{{wiki.install.next_api_reference}}](api/index.md)
