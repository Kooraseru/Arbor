{{wiki.api.runtime_loaders_load_module_map.line_1}}
{{wiki.api.runtime_loaders_load_module_map.line_2}}
{{wiki.api.runtime_loaders_load_module_map.line_3}}

{{wiki.api.runtime_loaders_load_module_map.line_5}}

{{wiki.api.runtime_loaders_load_module_map.line_7}}

{{wiki.api.runtime_loaders_load_module_map.line_9}}

{{wiki.api.runtime_loaders_load_module_map.line_11}}
{{wiki.api.runtime_loaders_load_module_map.line_12}}
{{wiki.api.runtime_loaders_load_module_map.line_13}}
{{wiki.api.runtime_loaders_load_module_map.line_14}}

{{wiki.api.runtime_loaders_load_module_map.line_16}}

{{wiki.api.runtime_loaders_load_module_map.line_18}}
{{wiki.api.runtime_loaders_load_module_map.line_19}}
{{wiki.api.runtime_loaders_load_module_map.line_20}}
{{wiki.api.runtime_loaders_load_module_map.line_21}}

{{wiki.api.runtime_loaders_load_module_map.line_23}}

```lua
export type ModuleValidator<T> = (value: unknown, moduleScript: ModuleScript) -> T
```

{{wiki.api.runtime_loaders_load_module_map.line_29}}

{{wiki.api.runtime_loaders_load_module_map.line_31}}
{{wiki.api.runtime_loaders_load_module_map.line_32}}
{{wiki.api.runtime_loaders_load_module_map.line_33}}
{{wiki.api.runtime_loaders_load_module_map.line_34}}

{{wiki.api.runtime_loaders_load_module_map.line_36}}

{{wiki.api.runtime_loaders_load_module_map.line_38}}
{{wiki.api.runtime_loaders_load_module_map.line_39}}
{{wiki.api.runtime_loaders_load_module_map.line_40}}

{{wiki.api.runtime_loaders_load_module_map.line_42}}

{{wiki.api.runtime_loaders_load_module_map.line_44}}
{{wiki.api.runtime_loaders_load_module_map.line_45}}
{{wiki.api.runtime_loaders_load_module_map.line_46}}
{{wiki.api.runtime_loaders_load_module_map.line_47}}
{{wiki.api.runtime_loaders_load_module_map.line_48}}
{{wiki.api.runtime_loaders_load_module_map.line_49}}
{{wiki.api.runtime_loaders_load_module_map.line_50}}
{{wiki.api.runtime_loaders_load_module_map.line_51}}

{{wiki.api.runtime_loaders_load_module_map.line_53}}

```lua
type TypeModulesRecord = Arbor.ChildRecord<typeof(script.Parent.Fixture), TypeModule>

local modules: TypeModulesRecord = Arbor.LoadModules(script.Parent.Fixture, validateTypeModule)
```

{{wiki.api.runtime_loaders_load_module_map.line_61}}

{{wiki.api.runtime_loaders_load_module_map.line_63}}

{{wiki.api.runtime_loaders_load_module_map.line_65}}

{{wiki.api.runtime_loaders_load_module_map.line_67}}
{{wiki.api.runtime_loaders_load_module_map.line_68}}
{{wiki.api.runtime_loaders_load_module_map.line_69}}

{{wiki.api.runtime_loaders_load_module_map.line_71}}

{{wiki.api.runtime_loaders_load_module_map.line_73}}
{{wiki.api.runtime_loaders_load_module_map.line_74}}
{{wiki.api.runtime_loaders_load_module_map.line_75}}
