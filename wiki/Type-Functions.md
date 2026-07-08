# Type Functions

## ChildNames

```luau
export type Id = TypeManager.ChildNames<typeof(script)>
```

Returns a union of direct child names.

## ChildRecord

```luau
export type Map = TypeManager.ChildRecord<typeof(script), ActionDefinition>
```

Returns a table shape whose keys are direct child names and whose values are the provided type.

## ChildOf

```luau
export type Child = TypeManager.ChildOf<typeof(script), "DefaultModule1">
```

Returns the analyzer-visible type of a direct child by name.

## ChildrenOfClass

```luau
export type ModuleChildren = TypeManager.ChildrenOfClass<typeof(script), "ModuleScript">
```

Returns a table shape for direct children whose analyzer-visible type matches the requested class.

> [!TIP]
> Use root exported aliases for package-facing APIs. Use focused `.Of<T>` modules if you want the leaf helper name visible in local code.
