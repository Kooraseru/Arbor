---
title: LoadModuleMap.From
---

# LoadModuleMap.From

Loads direct `ModuleScript` children and validates each required value.

## Call Structure

<pre><code>Arbor.RuntimeLoaders.LoadModuleMap.From&lt;T&gt;(
    root: <a class="arbor-type-link" href="https://create.roblox.com/docs/reference/engine/classes/Instance" data-tooltip="Instance - Roblox base class for objects in the data model.">Instance</a>,
    validate: ModuleValidator&lt;T&gt;
): { [string]: T }</code></pre>

Root alias:

<pre><code>Arbor.LoadModules&lt;T&gt;(
    root: <a class="arbor-type-link" href="https://create.roblox.com/docs/reference/engine/classes/Instance" data-tooltip="Instance - Roblox base class for objects in the data model.">Instance</a>,
    validate: ModuleValidator&lt;T&gt;
): { [string]: T }</code></pre>

Validator type:

```lua
export type ModuleValidator<T> = (value: unknown, moduleScript: ModuleScript) -> T
```

## Parameters

| Parameter | Type | Description |
| --- | --- | --- |
| `root` | <a class="arbor-type-link" href="https://create.roblox.com/docs/reference/engine/classes/Instance" data-tooltip="Instance - Roblox base class for objects in the data model.">`Instance`</a> | The instance whose direct `ModuleScript` children should be loaded. |
| `validate` | `ModuleValidator<T>` | Receives the raw `require` result as `unknown` and returns the accepted typed value. |

## Returns

| Type | Description |
| --- | --- |
| `{ [string]: T }` | A map keyed by direct `ModuleScript.Name`. |

## Behavior

| Rule | Description |
| --- | --- |
| Direct children | Reads direct children with `GetChildren()`. |
| Ordering | Sorts children by name. |
| Filtering | Skips non-`ModuleScript` children. |
| Duplicate names | Errors on duplicate `ModuleScript` names. |
| Require failures | Wraps `require` failures with the module path. |
| Validator failures | Wraps validator failures with the module path. |

## Code Samples

```lua
type TypeModulesRecord = Arbor.ChildRecord<typeof(script.Parent.Fixture), TypeModule>

local modules: TypeModulesRecord = Arbor.LoadModules(script.Parent.Fixture, validateTypeModule)
```

## Pairing

Use `Arbor.ChildRecord<Root, T>` when the analyzer can see the exact children and you want a stricter table type at the call boundary.

## Common Mistakes

- Casting `require` results instead of validating `unknown`.
- Expecting recursive descendant loading.
- Letting this become a registry or lifecycle system.

## Related

- [Runtime Loaders](index.md)
- [Child Types](../children.md)
- [Runtime Loading](index.md)
