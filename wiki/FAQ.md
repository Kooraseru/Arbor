# FAQ

## Does TypeManager load modules at compile time?

No. Luau type functions inspect analyzer-visible types. Runtime loading still happens at runtime.

## Does ChildNames prove ModuleScript return types?

No. It proves child names, not module return contracts.

## Why use LoadModuleMap?

It keeps dynamic require behavior centralized and paired with validation.

## Can I dynamically add type functions through a loop?

No. Runtime discovery does not create analyzer-visible type-function APIs. Root exported type aliases must be statically written.

## Why is there an init.luau facade?

It reduces require surface and exposes root type aliases like:

```luau
TypeManager.ChildNames<T>
TypeManager.ChildRecord<T, V>
```

The facade is static and explicit.

## Should I use root aliases or focused modules?

Use root aliases for public package surfaces. Use focused modules when the local code reads better with the original `.Of<T>` namespace.
