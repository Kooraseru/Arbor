# Install

## Install Shape

Place `Arbor` wherever your project or package manager exposes required modules.

Require the package root through your environment's module reference:

```luau
local Arbor = require(path.to.Arbor)
```

Arbor does not require peer packages. The only install requirement is that the Luau analyzer can see the module surface you require.

## Focused Module Requires

Root facade:

```luau
local Arbor = require(path.to.Arbor)
```

Focused module:

```luau
local ChildNames = require(path.to.Arbor.InstanceTree.ChildNames)
```

Use whichever is clearer for the caller.
