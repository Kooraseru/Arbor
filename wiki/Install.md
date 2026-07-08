# Install

## Install Shape

Place `TypeManager` wherever your project or package manager exposes required modules.

Require the package root through your environment's module reference:

```luau
local TypeManager = require(path.to.TypeManager)
```

TypeManager does not require peer packages. The only install requirement is that the Luau analyzer can see the module surface you require.

## Focused Module Requires

Root facade:

```luau
local TypeManager = require(path.to.TypeManager)
```

Focused module:

```luau
local ChildNames = require(path.to.TypeManager.InstanceTree.ChildNames)
```

Use whichever is clearer for the caller.
