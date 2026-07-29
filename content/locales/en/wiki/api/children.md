---
title: Child Types
description: Type aliases for analyzer-visible direct children.
---

# Child Types

Child type aliases read analyzer-visible direct child properties from a parent type.

They operate on types, not runtime instances. In Luau type functions, Roblox instance classes appear as `Luau.extern|extern type` values. If the analyzer cannot see the child as a direct property on that type, Arbor cannot recover that name later.

## Members

| Member | Returns | Summary |
| --- | --- | --- |
| [`Child`](#child) | child instance type, `nil`, or `never` | Resolve one direct child by name with explicit lookup mode. |
| [`RequiredChild`](#requiredchild) | child instance type | Require one direct child by name. |
| [`ChildNames`](#childnames) | string singleton union | Return analyzer-visible direct child names. |
| [`ChildNamesOfClass`](#childnamesofclass) | string singleton union | Return direct child names matching a class. |
| [`ChildRecord`](#childrecord) | table type | Build exact child-keyed records with a chosen value type. |
| [`ChildTypeRecord`](#childtyperecord) | table type | Build exact child-keyed records with child instance types. |
| [`ChildrenOfClass`](#childrenofclass) | table type | Build exact child-keyed records for children matching a class. |

## Child

### Call Structure

```lua
Arbor.Child<{ Parent: Parent, Name: Name, Mode: "checked" | "optional" | "required"? }>
```

Resolves one direct child by name.

### Type Parameters

| Parameter | Description |
| --- | --- |
| `Parent` | An analyzer-visible Roblox `Luau.extern|extern type`. |
| `Name` | A string singleton child name. |
| `Mode` | Optional lookup mode. Default is `"checked"`. |

### Returns

| Type | Condition |
| --- | --- |
| `typeof(parent.Child)` | The named child exists. |
| `nil` | `Mode` is `"optional"` and the child is missing. |
| `never` | `Mode` is `"checked"` and the child is missing. |

### Errors

| Mode | Condition |
| --- | --- |
| `"required"` | Raises an analyzer error when the child is missing. |

### Code Samples

```lua
export type StringModule = Arbor.Child<{
    Parent: typeof(script.Parent.Fixture),
    Name: "String",
    Mode: "required",
}>
```

## RequiredChild

### Call Structure

```lua
Arbor.RequiredChild<Parent, Name>
```

Shorthand for `Arbor.Child<{ Parent: Parent, Name: Name, Mode: "required" }>`.

### Type Parameters

| Parameter | Description |
| --- | --- |
| `Parent` | An analyzer-visible Roblox `Luau.extern|extern type`. |
| `Name` | A string singleton child name. |

### Returns

| Type | Condition |
| --- | --- |
| `typeof(parent.Child)` | The named child exists. |
| analyzer error | The named child is missing. |

### Code Samples

```lua
export type dataservice = Arbor.RequiredChild<
    typeof(script.Parent.ServerServices),
    "DataService"
>
```

## ChildNames

### Call Structure

```lua
Arbor.ChildNames<Parent>
```

Returns a union of analyzer-visible direct child names.

### Returns

| Type | Condition |
| --- | --- |
| `"ChildA" | "ChildB" | ...` | Direct child names are visible to the analyzer. |
| `never` | No direct child names are visible. |

### Code Samples

```lua
export type TypeId = Arbor.ChildNames<typeof(script.Parent.Fixture)>
```

## ChildNamesOfClass

### Call Structure

```lua
Arbor.ChildNamesOfClass<Parent, ClassType>
```

Returns a union of direct child names whose analyzer-visible type matches `ClassType` or inherits from it.

### Type Parameters

| Parameter | Description |
| --- | --- |
| `Parent` | An analyzer-visible Roblox `Luau.extern|extern type`. |
| `ClassType` | Roblox class `Luau.extern|extern type` used as the filter, such as `ModuleScript`. |

### Returns

| Type | Condition |
| --- | --- |
| `"ChildA" | "ChildB" | ...` | Matching direct children are visible. |
| `never` | No matching direct children are visible. |

## ChildRecord

### Call Structure

```lua
Arbor.ChildRecord<Parent, Value>
```

Builds a table type whose keys are direct child names and whose values are `Value`.

### Type Parameters

| Parameter | Description |
| --- | --- |
| `Parent` | An analyzer-visible Roblox `Luau.extern|extern type`. |
| `Value` | Value type to assign to every direct child key. |

### Returns

| Type | Description |
| --- | --- |
| `{ [ChildName]: Value }` | A table type keyed by analyzer-visible direct child names. |

### Code Samples

```lua
export type TypeModulesRecord = Arbor.ChildRecord<
    typeof(script.Parent.Fixture),
    TypeModule
>
```

## ChildTypeRecord

### Call Structure

```lua
Arbor.ChildTypeRecord<Parent>
```

Builds a table type whose keys are direct child names and whose values are the analyzer-visible child instance types.

### Type Parameters

| Parameter | Description |
| --- | --- |
| `Parent` | An analyzer-visible Roblox `Luau.extern|extern type`. |

### Returns

| Type | Description |
| --- | --- |
| `{ [ChildName]: typeof(parent.Child) }` | A table type keyed by analyzer-visible direct child names, with each value set to that child instance type. |

## ChildrenOfClass

### Call Structure

```lua
Arbor.ChildrenOfClass<Parent, ClassType>
```

Builds a table type for direct children whose analyzer-visible type matches `ClassType` or inherits from it. Values are the matching child instance types.

### Type Parameters

| Parameter | Description |
| --- | --- |
| `Parent` | An analyzer-visible Roblox `Luau.extern|extern type`. |
| `ClassType` | Roblox class `Luau.extern|extern type` used as the filter, such as `ModuleScript`. |

### Returns

| Type | Condition |
| --- | --- |
| `{ [ChildName]: typeof(parent.Child) }` | Matching direct children are visible. |
| `{}` | No matching direct children are visible. |

## Boundaries

| Boundary | Description |
| --- | --- |
| Direct children | These aliases do not search descendants. |
| Extern input | `Parent` must be analyzer-visible as a Roblox `Luau.extern|extern type`. |
| Synthetic parent | The synthetic `Parent` property is excluded from child-name and child-record helpers. |
| Module returns | Child instance types are not `require` return types. |

## Related

- [Analyzer Model](../analyzer-model.md)
- [Relation Types](relations.md)
- [Runtime Members](runtime.md)
