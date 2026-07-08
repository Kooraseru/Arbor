---
title: Type Functions
---

# Type Functions

## ChildNames

Call:

```luau
export type Id = Arbor.ChildNames<typeof(script)>
```

Expected result:

```luau
type Id = "ChildA" | "ChildB"
```

Returns a union of analyzer-visible direct child names.

## ChildNamesOfClass

Call:

```luau
export type ModuleChildName = Arbor.ChildNamesOfClass<typeof(script), "ModuleScript">
```

Expected result:

```luau
type ModuleChildName = "Kick" | "Ban"
```

Returns a union of direct child names whose analyzer-visible type matches the requested class.

## ChildRecord

Call:

```luau
export type Map = Arbor.ChildRecord<typeof(script), ActionDefinition>
```

Expected result:

```luau
type Map = {
  ChildA: ActionDefinition,
  ChildB: ActionDefinition,
}
```

Returns a table shape whose keys are direct child names and whose values are the provided type.

## ChildOf

Call:

```luau
export type Child = Arbor.ChildOf<typeof(script), "DefaultModule1">
```

Expected result:

```luau
type Child = typeof(script.DefaultModule1)
```

Returns the analyzer-visible type of a direct child by name.

## ChildrenOfClass

Call:

```luau
export type ModuleChildren = Arbor.ChildrenOfClass<typeof(script), "ModuleScript">
```

Expected result:

```luau
type ModuleChildren = {
  DefaultModule1: typeof(script.DefaultModule1),
  DefaultModule2: typeof(script.DefaultModule2),
}
```

Returns a table shape for direct children whose analyzer-visible type matches the requested class.

