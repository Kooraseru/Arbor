# Package Boundaries

TypeManager answers:

```txt
What does the compiler/analyzer know?
```

It does not answer:

```txt
what runtime modules exist
when startup happens
in what order behavior executes
how values cross the network
how privileged actions are exposed
what semantic concepts exist
```

## Allowed Responsibilities

```txt
type functions
typed lookup conventions
generated type surfaces when needed
analyzer-facing ids
small runtime loader helpers
```

## Disallowed Responsibilities

```txt
runtime registries
boot sequencing
pipeline execution
serialization tags
dispatch parsing
descriptor identity
package dependency resolution
```

> [!NOTE]
> `RuntimeLoaders` is allowed because it is a tiny helper that pairs dynamic loading with validation. It should not grow into a registry or lifecycle package.
