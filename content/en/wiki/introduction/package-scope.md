---
title: Data Model Scope
---

# Data Model Scope

Roblox data model code often has two competing needs:

```txt
keep related instances organized as children
avoid hand-maintained string manifests
```

Arbor handles the analyzer-visible part of that problem. It exposes Roblox instance hierarchies to Luau's type system, then lets your code build compile-time infrastructure on top of that shape.

## What It Helps With

- extracting direct child names
- creating exact child-keyed records
- filtering children by analyzer-visible class
- pairing runtime loading with validation
- documenting data model boundaries through the tree the analyzer actually sees

## What It Avoids

Arbor does not become your registry, lifecycle, package manager, dispatch layer, or serializer.

That boundary matters. Arbor should help code describe an analyzer-visible Roblox tree without owning the runtime behavior around that tree.
