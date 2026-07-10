<div align="center">
  <img src="images/Billboard.svg" alt="Arbor" width="860">
  <h3>Typed Roblox instance trees for Luau.</h3>

  <p>
    <a href="https://github.com/Kooraseru/Arbor"><img alt="Stars + Issues + License" src="https://shieldcn.dev/group/github/stars/Kooraseru/Arbor+github/Kooraseru/Arbor/issues+github/license/Kooraseru/Arbor.svg?variant=outline"></a>
    <br>
    <a href="https://github.com/Kooraseru/Arbor/releases"><img alt="Releases" src="https://shieldcn.dev/github/Kooraseru/Arbor/release.svg?variant=outline"></a>
  </p>

  <img src="https://counter.seku.su/cmoe?name=Kooraseru&theme=mb">

  <!-- NAVIGATION -->
  <table>
    <tr>
      <td align="center"><a href="#features">Features</a></td>
      <td align="center"><a href="#quick-start">Quick Start</a></td>
      <td align="center"><a href="#documentation">Documentation</a></td>
      <td align="center"><a href="#project">Project</a></td>
    </tr>
  </table>

  <!-- LANGUAGES -->
  <table>
    <tr>
      <td align="center">English</td>
      <td align="center"><a href="content/jp/README.md">Japanese</a></td>
    </tr>
  </table>
</div>

## Features

Arbor helps Luau understand Roblox instance hierarchies at compile time.[^compile-time]

- Direct child names become checked string unions such as `"Kick" | "Ban"`.
- Child-keyed records can be typed without hand-maintained manifests.[^manifests]
- Direct children can be filtered by analyzer-visible Roblox class, such as `ModuleScript`.
- Direct `ModuleScript` children can be loaded at runtime through an explicit validator.[^runtime-validator]
- Runtime loading and compile-time tree typing stay separate.

## Quick Start

### Install

Place `Arbor` wherever your project or package manager exposes required modules.

Require the package root through whatever module reference your environment provides:

```lua
local Arbor = require(path.to.Arbor)
```

When used inside a standalone package, internal Arbor requires use `@self` and focused child modules.

### Example

This example builds a typed action table from direct ModuleScript children. The child names come from the analyzer-visible tree, while loaded module values still pass through an explicit runtime validator.

```lua
local Arbor = require(path.to.Arbor)

local LoadModuleMap = Arbor.RuntimeLoaders.LoadModuleMap

type ActionDefinition = {
	Run: (playerName: string) -> (),
}

local function validateAction(value: unknown, moduleScript: ModuleScript): ActionDefinition
	if type(value) ~= "string" then
		error(`{moduleScript:GetFullName()} must return an action name`)
	end

	local actionName = value

	return {
		Run = function(playerName: string)
			print(`{actionName} {playerName}`)
		end,
	}
end

export type ActionId = Arbor.ChildNames<typeof(script)>
export type ActionMap = Arbor.ChildRecord<typeof(script), ActionDefinition>

local actions: ActionMap = LoadModuleMap.From(script, validateAction)

actions.Kick.Run("Builder")
actions.Ban.Run("Spammer")

return actions
```

With child modules named `Kick` and `Ban`, `ActionId` becomes `"Kick" | "Ban"` and `actions` is checked as a table with those keys.

### API And Tools

To support those workflows, Arbor exposes:

<table>
  <tr>
    <td><code>ChildNames&lt;T&gt;</code></td>
    <td>Direct child-name unions.</td>
  </tr>
  <tr>
    <td><code>ChildRecord&lt;T, V&gt;</code></td>
    <td>Child-keyed table shapes.</td>
  </tr>
  <tr>
    <td><code>ChildOf&lt;T, Name&gt;</code></td>
    <td>The analyzer-visible type of one named direct child.</td>
  </tr>
  <tr>
    <td><code>ChildNamesOfClass&lt;T, ClassType&gt;</code></td>
    <td>Class-filtered child-name unions.</td>
  </tr>
  <tr>
    <td><code>ChildrenOfClass&lt;T, ClassType&gt;</code></td>
    <td>Class-filtered child tables.</td>
  </tr>
  <tr>
    <td><code>LoadModuleMap.From(root, validate)</code></td>
    <td>Validated runtime loading for direct ModuleScript children.</td>
  </tr>
</table>

Root facade exports:

```txt
Arbor.ChildNames<T>
Arbor.ChildNamesOfClass<T, ClassType>
Arbor.ChildRecord<T, V>
Arbor.ChildOf<T, Name>
Arbor.ChildrenOfClass<T, ClassType>
Arbor.ModuleValidator<T>
```

Root runtime facade:

```txt
Arbor.InstanceTree.ChildNames
Arbor.InstanceTree.ChildNamesOfClass
Arbor.InstanceTree.ChildRecord
Arbor.InstanceTree.ChildOf
Arbor.InstanceTree.ChildrenOfClass
Arbor.RuntimeLoaders.LoadModuleMap
```

Focused module exports:

```txt
InstanceTree/ChildNames.Of<T>
InstanceTree/ChildNamesOfClass.Of<T, ClassType>
InstanceTree/ChildRecord.Of<T, V>
InstanceTree/ChildOf.Of<T, Name>
InstanceTree/ChildrenOfClass.Of<T, ClassType>
RuntimeLoaders/LoadModuleMap.From(root, validate)
```

## Documentation

The English wiki source lives under `content/en/wiki/`. Examples referenced by
the wiki live under `content/en/examples/`.

- [Home](https://kooraseru.github.io/Arbor/)
- [Examples](https://kooraseru.github.io/Arbor/examples/)
- [InstanceTree API](https://kooraseru.github.io/Arbor/api/instance-tree/)
- [Runtime Loaders](https://kooraseru.github.io/Arbor/runtime-loaders/)
- [FAQ](https://kooraseru.github.io/Arbor/faq/)

### Requirements

These helpers depend on the active Luau analyzer exposing direct children as literal extern properties.

Roblox Studio:

- no extra external tooling is required to use Arbor at runtime

VS Code and other external editor workflows need:

- a sourcemap/data-model provider that exposes the Roblox instance tree to the analyzer[^sourcemap]
- [Luau LSP](https://github.com/JohnnyMorganz/luau-lsp), or an equivalent Luau analyzer integration that understands that sourcemap

Specific APIs need:

- `ChildNames<T>`, `ChildRecord<T, V>`, and `ChildOf<T, Name>` need direct children exposed as analyzer-visible properties.
- `ChildNamesOfClass<T, ClassType>` and `ChildrenOfClass<T, ClassType>` also need analyzer-visible Roblox class metadata for those children.
- `LoadModuleMap.From(root, validate)` is runtime Luau code and does not require analyzer-visible children, but typed callers still benefit from the child-name helpers above.

> [!NOTE]
> Validate your target solver/toolchain before treating child-name discovery as public API.

## Project

Arbor is maintained by a solo developer. Issues, docs fixes, examples, and small
pull requests are welcome; sponsorship is also greatly appreciated if this
package saves you time or helps your project stay typed.

- [Sponsor Kooraseru](https://github.com/sponsors/Kooraseru)

### Versions

- [Releases](https://github.com/Kooraseru/Arbor/releases) list published versions and downloadable assets.
- [Release notes](release-notes/Stable/v1.0.0.md) describe the current stable release.
- [Changelog](CHANGELOG.md) summarizes package history after it is constructed.

### License

Apache License 2.0. See [LICENSE](LICENSE).

### Contributors

<a href="https://github.com/Kooraseru/Arbor/graphs/contributors" target="_blank">
  <img src="https://contrib.rocks/image?repo=Kooraseru/Arbor" />
</a>

#### Footnotes

[^compile-time]: Arbor works through Luau type functions and analyzer-visible Roblox tree metadata. It does not change Roblox runtime behavior by itself.
[^manifests]: The child ModuleScript or instance name remains the source of truth for these helpers.
[^runtime-validator]: The validator is where raw `require` results become project-owned typed values.
[^sourcemap]: In external editors, the analyzer needs a model of the Roblox tree before it can see child names or classes.
