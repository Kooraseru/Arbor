---
title: Runtime Members
description: Runtime functions exported by Arbor.
---

# Runtime Members

Runtime members inspect actual `Instance` children. They do not create compile-time types by themselves.

## Members

| Member | Returns | Summary |
| --- | --- | --- |
| [`CollectChildren`](#collectchildren) | `{ [string]: Instance }` | Collect direct children into a name-keyed table. |
| [`FindChild`](#findchild) | `Instance?` | Return a named direct child or `nil`. |
| [`ExpectChild`](#expectchild) | `Instance` | Return a named direct child or raise an error. |

## CollectChildren

### Call Structure

<pre><code>Arbor.CollectChildren(parent: <a class="arbor-type-link" href="https://create.roblox.com/docs/reference/engine/classes/Instance" data-tooltip="Instance - Roblox base class for objects in the data model.">Instance</a>): { [string]: <a class="arbor-type-link" href="https://create.roblox.com/docs/reference/engine/classes/Instance" data-tooltip="Instance - Roblox base class for objects in the data model.">Instance</a> }</code></pre>

Returns direct children keyed by `Name`.

### Parameters

| Parameter | Type | Description |
| --- | --- | --- |
| `parent` | <a class="arbor-type-link" href="https://create.roblox.com/docs/reference/engine/classes/Instance" data-tooltip="Instance - Roblox base class for objects in the data model.">`Instance`</a> | The instance whose direct children should be collected. |

### Returns

| Type | Description |
| --- | --- |
| `{ [string]: `<a class="arbor-type-link" href="https://create.roblox.com/docs/reference/engine/classes/Instance" data-tooltip="Instance - Roblox base class for objects in the data model.">`Instance`</a>` }` | A table keyed by direct child name. |

### Behavior

| Rule | Description |
| --- | --- |
| Direct children | Reads `parent:GetChildren()` and ignores descendants. |
| Stable order | Sorts children by name before inserting. |
| Duplicate names | Errors when two direct children share the same name. |

### Code Samples

```lua
local children = Arbor.CollectChildren(script.Parent.Fixture)
local stringModule = children.String
```

## FindChild

### Call Structure

<pre><code>Arbor.FindChild(parent: <a class="arbor-type-link" href="https://create.roblox.com/docs/reference/engine/classes/Instance" data-tooltip="Instance - Roblox base class for objects in the data model.">Instance</a>, name: string): <a class="arbor-type-link" href="https://create.roblox.com/docs/reference/engine/classes/Instance" data-tooltip="Instance - Roblox base class for objects in the data model.">Instance</a>?</code></pre>

Returns a direct child with the given name, or `nil`.

### Parameters

| Parameter | Type | Description |
| --- | --- | --- |
| `parent` | <a class="arbor-type-link" href="https://create.roblox.com/docs/reference/engine/classes/Instance" data-tooltip="Instance - Roblox base class for objects in the data model.">`Instance`</a> | The instance to search. |
| `name` | `string` | The direct child name to find. |

### Returns

| Type | Description |
| --- | --- |
| <a class="arbor-type-link" href="https://create.roblox.com/docs/reference/engine/classes/Instance" data-tooltip="Instance - Roblox base class for objects in the data model.">`Instance`</a>`?` | The matching child instance when present. |

### Code Samples

```lua
local maybeStringModule = Arbor.FindChild(script.Parent.Fixture, "String")
```

## ExpectChild

### Call Structure

<pre><code>Arbor.ExpectChild(parent: <a class="arbor-type-link" href="https://create.roblox.com/docs/reference/engine/classes/Instance" data-tooltip="Instance - Roblox base class for objects in the data model.">Instance</a>, name: string): <a class="arbor-type-link" href="https://create.roblox.com/docs/reference/engine/classes/Instance" data-tooltip="Instance - Roblox base class for objects in the data model.">Instance</a></code></pre>

Returns a direct child with the given name, or raises an error.

### Parameters

| Parameter | Type | Description |
| --- | --- | --- |
| `parent` | <a class="arbor-type-link" href="https://create.roblox.com/docs/reference/engine/classes/Instance" data-tooltip="Instance - Roblox base class for objects in the data model.">`Instance`</a> | The instance to search. |
| `name` | `string` | The direct child name to require. |

### Returns

| Type | Description |
| --- | --- |
| <a class="arbor-type-link" href="https://create.roblox.com/docs/reference/engine/classes/Instance" data-tooltip="Instance - Roblox base class for objects in the data model.">`Instance`</a> | The matching child instance. |

### Errors

| Condition | Message |
| --- | --- |
| Missing child | Errors when the child is missing. |

### Code Samples

```lua
local stringModule = Arbor.ExpectChild(script.Parent.Fixture, "String")
```

## Related

- [Child Types](children.md)
- [Runtime Loaders](runtime-loaders/index.md)
