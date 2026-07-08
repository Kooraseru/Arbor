# Runtime Loaders

Runtime loaders are small helpers for package-owned child sets.

## LoadModuleMap

```luau
local LoadModuleMap = Arbor.RuntimeLoaders.LoadModuleMap

local modules = LoadModuleMap.From(script, validateModule)
```

`LoadModuleMap.From(root, validate)`:

```txt
collects direct ModuleScript children
sorts them by name
requires each child
passes the required value to validate(value, moduleScript)
returns a map keyed by ModuleScript.Name
```

## Validator Boundary

```luau
local function validateModule(value: unknown, moduleScript: ModuleScript): ActionDefinition
	assert(type(value) == "table", `{moduleScript.Name} must return a table`)
	-- narrow/validate here
	return value
end
```

> [!IMPORTANT]
> The validator is where uncertainty belongs. Call sites should receive typed values, not dynamic require results.

## Static Versus Runtime

Runtime map:

```luau
local actions = LoadModuleMap.From(script, validateAction)
```

Static surface:

```luau
export type ActionId = Arbor.ChildNames<typeof(script)>
export type ActionMap = Arbor.ChildRecord<typeof(script), ActionDefinition>
```

Both pieces matter. Runtime discovery alone is not a static public API.
