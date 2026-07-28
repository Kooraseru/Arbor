---
title: "{{wiki.introduction.quick_start.title}}"
---

# {{wiki.introduction.quick_start.title}}

{{wiki.introduction.quick_start.require_root}}

```lua
local Arbor = require(path.to.Arbor)
```

{{wiki.introduction.quick_start.use_child_names}}

```lua
export type ActionId = Arbor.ChildNames<typeof(script)>
```

{{wiki.introduction.quick_start.create_map_type}}

```lua
type ActionMap = Arbor.ChildRecord<typeof(script), ActionDefinition>
```

{{wiki.introduction.quick_start.load_modules}}

```lua
local actions: ActionMap = Arbor.LoadModules(script, validateAction)
```

{{wiki.introduction.quick_start.key_rule}}

{{wiki.introduction.quick_start.api_reference}}
