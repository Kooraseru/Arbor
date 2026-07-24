---
title: Plugin Sandbox
---

# Plugin Sandbox

## Problem

You want a Studio place fixture that exercises Arbor's plugin discovery and
generation behavior.

## Source

```md title="README.md"
--8<-- "src/examples/plugin-sandbox/README.md"
```

```lua title="ServiceTypes.luau"
--8<-- "src/examples/plugin-sandbox/ServiceTypes.luau"
```

```lua title="setup-sandbox.server.luau"
--8<-- "src/examples/plugin-sandbox/setup-sandbox.server.luau"
```

## Result

The sandbox creates a service tree and lets the Studio plugin regenerate the
`Generated.ServiceTypes` facade.

## Why It Works

The plugin discovers the versioned Arbor package from the source-controlled
package shape and writes user-owned generated source beside the project code it
describes.

