---
title: {{wiki.guides.typechecking.title}}
---

# {{wiki.guides.typechecking.title}}

{{wiki.guides.typechecking.intro}}

{{wiki.guides.typechecking.visibility_first}}

## {{wiki.guides.typechecking.minimal_check_heading}}

```lua
local valid: Arbor.ChildNames<typeof(script)> = "Kick"
local invalid: Arbor.ChildNames<typeof(script)> = "Nope"
```

{{wiki.guides.typechecking.second_should_fail}}

{{wiki.guides.typechecking.failure_likely_visibility}}

## {{wiki.guides.typechecking.diagnosis_heading}}

{{wiki.guides.typechecking.diagnosis_intro}}

1. {{wiki.guides.typechecking.diagnosis_workspace}}
2. {{wiki.guides.typechecking.diagnosis_tree}}
3. {{wiki.guides.typechecking.diagnosis_property}}
4. {{wiki.guides.typechecking.diagnosis_direct_child}}
5. {{wiki.guides.typechecking.diagnosis_included_root}}
6. {{wiki.guides.typechecking.diagnosis_provider_current}}
7. {{wiki.guides.typechecking.diagnosis_runtime_vs_compile}}

## {{wiki.guides.typechecking.direct_child_heading}}

{{wiki.guides.typechecking.direct_child_intro}}

```lua
export type ActionId = Arbor.ChildNames<typeof(script)>

local kick: ActionId = "Kick"
local nope: ActionId = "Nope"
```

{{wiki.guides.typechecking.expected_result}}

```txt
"Kick" is accepted.
"Nope" is rejected.
```

## {{wiki.guides.typechecking.class_filtered_heading}}

{{wiki.guides.typechecking.class_filtered_intro}}

```lua
export type ModuleChildName = Arbor.ChildNamesOfClass<typeof(script), ModuleScript>
```

{{wiki.guides.typechecking.class_metadata_boundary}}

## {{wiki.guides.typechecking.runtime_loader_heading}}

{{wiki.guides.typechecking.runtime_loader_intro}}

```lua
local actions = Arbor.LoadModules(script, validateAction)
```

{{wiki.guides.typechecking.no_cast_boundary}}

## {{wiki.guides.typechecking.next_heading}}

- [{{wiki.guides.typechecking.next_analyzer_model}}](../analyzer-model.md)
- [{{wiki.guides.typechecking.next_api_reference}}](../api/index.md)
