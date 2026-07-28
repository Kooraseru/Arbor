---
title: {{wiki.package_boundaries.title}}
---

# {{wiki.package_boundaries.title}}

{{wiki.package_boundaries.answers_intro}}

```txt
What static structure does the Luau analyzer know about an owned instance surface?
```

{{wiki.package_boundaries.not_answers_intro}}

```txt
what runtime modules exist
when startup happens
in what order behavior executes
how values cross the network
how privileged actions are exposed
what semantic concepts exist
```

## {{wiki.package_boundaries.allowed_heading}}

```txt
type functions
typed lookup conventions
generated type surfaces when needed
analyzer-facing ids
small runtime loader helpers
small direct-child runtime helpers
```

## {{wiki.package_boundaries.disallowed_heading}}

```txt
runtime registries
boot sequencing
pipeline execution
serialization tags
dispatch parsing
descriptor identity
external package lookup
```

{{wiki.package_boundaries.runtime_loaders}}

{{wiki.package_boundaries.runtime_children}}
