---
title: Relation Types
description: Type aliases for child, ancestor, and descendant checks.
---

# Relation Types

Relation aliases answer whether analyzer-visible instance types have a direct-child, ancestor, or descendant relationship.

These aliases operate on Luau `Luau.extern|extern type` values exposed by the analyzer for Roblox instance classes.

## Members

| Member | Returns | Summary |
| --- | --- | --- |
| [`ChildOf`](#childof) | `Child` or `never` | Keep a child type only when it is a direct child of a parent. |
| [`IsChildOf`](#ischildof) | `true` or `false` | Boolean direct-child relation check. |
| [`AncestorOf`](#ancestorof) | `Ancestor` or `never` | Keep an ancestor type only when the relation passes. |
| [`IsAncestorOf`](#isancestorof) | `true` or `false` | Boolean ancestor relation check. |
| [`DescendantOf`](#descendantof) | `Descendant` or `never` | Keep a descendant type only when the relation passes. |
| [`IsDescendantOf`](#isdescendantof) | `true` or `false` | Boolean descendant relation check. |

## ChildOf

### Call Structure

```lua
Arbor.ChildOf<Child, Parent>
```

### Type Parameters

| Parameter | Description |
| --- | --- |
| `Child` | Candidate analyzer-visible child `Luau.extern|extern type`. |
| `Parent` | Candidate analyzer-visible parent `Luau.extern|extern type`. |

### Returns

| Type | Condition |
| --- | --- |
| `Child` | `Child` is an analyzer-visible direct child of `Parent`. |
| `never` | `Child` is not an analyzer-visible direct child of `Parent`. |

### Code Samples

```lua
local fixture = script.Parent.Fixture
local fixtureChild = script.Parent.Fixture.String

type FixtureType = typeof(fixture)
type FixtureStringType = typeof(fixtureChild)

local _validFixtureChild: Arbor.ChildOf<FixtureStringType, FixtureType> = fixtureChild
```

## IsChildOf

### Call Structure

```lua
Arbor.IsChildOf<Child, Parent>
```

### Type Parameters

| Parameter | Description |
| --- | --- |
| `Child` | Candidate analyzer-visible child `Luau.extern|extern type`. |
| `Parent` | Candidate analyzer-visible parent `Luau.extern|extern type`. |

### Returns

| Type | Condition |
| --- | --- |
| `true` | `Child` is an analyzer-visible direct child of `Parent`. |
| `false` | `Child` is not an analyzer-visible direct child of `Parent`. |

### Code Samples

```lua
type StringIsChild = Arbor.IsChildOf<
    typeof(script.Parent.Fixture.String),
    typeof(script.Parent.Fixture)
>

local _stringIsChild: StringIsChild = true
```

## AncestorOf

### Call Structure

```lua
Arbor.AncestorOf<Ancestor, Descendant>
```

### Type Parameters

| Parameter | Description |
| --- | --- |
| `Ancestor` | Candidate analyzer-visible ancestor `Luau.extern|extern type`. |
| `Descendant` | Candidate analyzer-visible descendant `Luau.extern|extern type`. |

### Returns

| Type | Condition |
| --- | --- |
| `Ancestor` | `Ancestor` is an analyzer-visible ancestor of `Descendant`. |
| `never` | `Ancestor` is not an analyzer-visible ancestor of `Descendant`. |

## IsAncestorOf

### Call Structure

```lua
Arbor.IsAncestorOf<Ancestor, Descendant>
```

### Type Parameters

| Parameter | Description |
| --- | --- |
| `Ancestor` | Candidate analyzer-visible ancestor `Luau.extern|extern type`. |
| `Descendant` | Candidate analyzer-visible descendant `Luau.extern|extern type`. |

### Returns

| Type | Condition |
| --- | --- |
| `true` | `Ancestor` is an analyzer-visible ancestor of `Descendant`. |
| `false` | `Ancestor` is not an analyzer-visible ancestor of `Descendant`. |

### Code Samples

```lua
type FixtureIsAncestor = Arbor.IsAncestorOf<
    typeof(script.Parent.Fixture),
    typeof(script.Parent.Fixture.String)
>

local _fixtureIsAncestor: FixtureIsAncestor = true
```

## DescendantOf

### Call Structure

```lua
Arbor.DescendantOf<Descendant, Ancestor>
```

### Type Parameters

| Parameter | Description |
| --- | --- |
| `Descendant` | Candidate analyzer-visible descendant `Luau.extern|extern type`. |
| `Ancestor` | Candidate analyzer-visible ancestor `Luau.extern|extern type`. |

### Returns

| Type | Condition |
| --- | --- |
| `Descendant` | `Descendant` is an analyzer-visible descendant of `Ancestor`. |
| `never` | `Descendant` is not an analyzer-visible descendant of `Ancestor`. |

## IsDescendantOf

### Call Structure

```lua
Arbor.IsDescendantOf<Descendant, Ancestor>
```

### Type Parameters

| Parameter | Description |
| --- | --- |
| `Descendant` | Candidate analyzer-visible descendant `Luau.extern|extern type`. |
| `Ancestor` | Candidate analyzer-visible ancestor `Luau.extern|extern type`. |

### Returns

| Type | Condition |
| --- | --- |
| `true` | `Descendant` is an analyzer-visible descendant of `Ancestor`. |
| `false` | `Descendant` is not an analyzer-visible descendant of `Ancestor`. |

### Code Samples

```lua
type StringIsDescendant = Arbor.IsDescendantOf<
    typeof(script.Parent.Fixture.String),
    typeof(script.Parent.Fixture)
>

local _stringIsDescendant: StringIsDescendant = true
```

## Boundaries

| Boundary | Description |
| --- | --- |
| Direct-child checks | Do not search descendants. |
| Ancestor and descendant checks | Walk analyzer-visible direct child properties. |
| Inputs | All relation inputs must be analyzer-visible `Luau.extern|extern type` values. |
| Failed relation | Filtering aliases return `never`; boolean aliases return `false`. |

## Related

- [Child Types](children.md)
- [Analyzer Model](../analyzer-model.md)
