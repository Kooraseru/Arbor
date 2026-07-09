---
title: Why Arbor?
---

# Why Arbor?

Roblox package code often has two competing needs:

```txt
keep modules organized as children
avoid hand-maintained string manifests
```

Arbor exists for the analyzer-visible part of that problem. It turns owned child trees into type-level names, child lookup types, and exact table shapes.

## What It Helps With

- extracting direct child names
- creating exact child-keyed records
- filtering children by analyzer-visible class
- pairing runtime loading with validation

## What It Avoids

Arbor does not become your registry, lifecycle, package manager, dispatch layer, or serializer.

That boundary matters. Arbor should help a package describe its static tree without owning the package's runtime behavior.
