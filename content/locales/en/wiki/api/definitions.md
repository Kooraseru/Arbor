---
title: Definition Runtime
description: Split-ready notes for Arbor's type-function definition layer.
---

# Definition Runtime

`Mold`, `Run`, `Resolve1`, and `Resolve2` are low-level public aliases used by Arbor's generated facade.

Most package users should prefer named aliases such as `ChildNames`, `RequiredChild`, `ChildrenOfClass`, and `IsDescendantOf`.

## Members

| Member | Returns | Summary |
| --- | --- | --- |
| [`Mold`](#mold) | molded definition type | Substitute the first two generic parameters in a definition schema. |
| [`Run`](#run) | resolved type | Resolve a molded Arbor definition. |
| [`Resolve1`](#resolve1) | resolved type | Resolve a definition with one type argument. |
| [`Resolve2`](#resolve2) | resolved type | Resolve a definition with two type arguments. |

## Mold

### Call Structure

```lua
Arbor.Mold<Schema, First, Second>
```

Substitutes the first two generic parameters in a definition schema.

### Type Parameters

| Parameter | Description |
| --- | --- |
| `Schema` | Type-function definition schema. |
| `First` | Replacement for the first generic parameter. |
| `Second` | Replacement for the second generic parameter. |

### Returns

| Type | Description |
| --- | --- |
| molded definition type | A definition schema with Arbor's first and second type arguments substituted. |

## Run

### Call Structure

```lua
Arbor.Run<Molded>
```

Resolves a molded Arbor definition into the final type.

### Type Parameters

| Parameter | Description |
| --- | --- |
| `Molded` | Molded Arbor definition table. |

### Returns

| Type | Description |
| --- | --- |
| resolved type | The final type produced by the molded Arbor definition. |

## Resolve1

### Call Structure

```lua
Arbor.Resolve1<Definition, First>
```

Molds and resolves a definition with one type argument.

### Type Parameters

| Parameter | Description |
| --- | --- |
| `Definition` | Type-function definition. |
| `First` | First type argument. |

### Returns

| Type | Description |
| --- | --- |
| resolved type | The final type produced by molding and running `Definition` with `First`. |

## Resolve2

### Call Structure

```lua
Arbor.Resolve2<Definition, First, Second>
```

Molds and resolves a definition with two type arguments.

### Type Parameters

| Parameter | Description |
| --- | --- |
| `Definition` | Type-function definition. |
| `First` | First type argument. |
| `Second` | Second type argument. |

### Returns

| Type | Description |
| --- | --- |
| resolved type | The final type produced by molding and running `Definition` with `First` and `Second`. |

## Split Boundary

This layer is the main reason the API reference is split by public member group instead of by source folder.

`Definitions/` can grow internal tags, projections, relationship checks, or sources without forcing every implementation file to become a user-facing API page. Public docs should follow the root facade unless a lower-level file becomes an intentional extension point.

## Related

- [API Reference](index.md)
- [Child Types](children.md)
- [Relation Types](relations.md)
