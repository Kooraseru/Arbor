---
title: {{wiki.guides.creating_a_package.title}}
---

# {{wiki.guides.creating_a_package.title}}

{{wiki.guides.creating_a_package.intro}}

## {{wiki.guides.creating_a_package.recommended_shape_heading}}

```txt
SomeRoot/
  init.luau
  FeatureA.luau
  FeatureB.luau
```

{{wiki.guides.creating_a_package.init_intro}}

```lua
local Arbor = require(path.to.Arbor)

export type FeatureName = Arbor.ChildNames<typeof(script)>
export type FeatureModule = Arbor.RequiredChild<typeof(script), "FeatureA">
```

## {{wiki.guides.creating_a_package.runtime_separate_heading}}

{{wiki.guides.creating_a_package.runtime_separate_intro}}

```lua
export type FeatureMap = Arbor.ChildRecord<typeof(script), FeatureDefinition>
```

{{wiki.guides.creating_a_package.type_boundary}}

{{wiki.guides.creating_a_package.validator_boundary}}

```lua
local features: FeatureMap = Arbor.LoadModules(script, validateFeature)
```

## {{wiki.guides.creating_a_package.split_friendly_heading}}

{{wiki.guides.creating_a_package.root_aliases}}

{{wiki.guides.creating_a_package.facade_stability}}
