# Arbor Plugin Sandbox

Use this fixture to test the Arbor Studio plugin.

## Setup

Run `setup-sandbox.server.luau` in Studio Command Bar or a temporary Script. It
creates this tree under `ReplicatedStorage`:

```txt
ReplicatedStorage
  ArborPluginSandbox
    ServerServices
      InventoryService
      PlayerService
      DataService
    Generated
      ServiceTypes
```

The plugin should regenerate `Generated.ServiceTypes`.

The plugin discovers Arbor from the source-controlled package shape. The place
should contain exactly one versioned Arbor ModuleScript such as `arbor@1.1.0`.
