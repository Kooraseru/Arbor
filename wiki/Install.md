# Install

## Copy-Folder Install

Place `TypeManager` somewhere your package can require it:

```txt
ReplicatedStorage
  Packages
    TypeManager
```

Then require the package root:

```luau
local TypeManager = require(path.To.TypeManager)
```

## Package-Local Install

For a package that depends on TypeManager, a sibling layout is the current simplest analyzer-friendly shape:

```txt
Packages
  TypeManager
  Serialization
```

Inside `Serialization`:

```luau
local TypeManager = require("../TypeManager")
```

> [!NOTE]
> A future Dependency package may make runtime dependency lookup path-agnostic. Compile-time type aliases still need an analyzer-visible module surface.

## Focused Module Requires

Root facade:

```luau
local TypeManager = require("../TypeManager")
```

Focused module:

```luau
local ChildNames = require("../TypeManager/InstanceTree/ChildNames")
```

Use whichever is clearer for the caller.
