# API Reference Format

This document owns Arbor's public API reference page schema.

Roblox Creator Docs `STYLE.md` is the upstream prose style model, but it is not
the API reference layout specification. Roblox's public Engine API reference is
generated from internal metadata and generated YAML; the public repository does
not expose enough of that pipeline to copy the component-level format.

Arbor owns its own API reference format.

Render API pages consistently from structured metadata instead of inventing
layouts per page. Keep API metadata such as kind, version, lifecycle,
parameters, return types, and generator behavior separate from localized prose.
Use `docs/knowledge/configuration-conventions.md` for metadata format rules.

## Page Order

API reference pages use this order for each documented member:

```txt
Member heading
Call Structure
Parameters or Type Parameters
Returns
Errors, Behavior, or Boundaries when relevant
Code Samples
Related
```

## Member Listings

Group pages should start with a member table.

| Column | Meaning |
| --- | --- |
| Member | Link to the member section on the current page. |
| Returns | The shortest useful return shape. |
| Summary | One sentence describing the member. |

## Call Structure

Use `Call Structure` for callable functions, type aliases, and resolver aliases.

Function members should show arguments and return type:

```lua
Arbor.FindChild(parent: Instance, name: string): Instance?
```

Type aliases should show type parameters:

```lua
Arbor.ChildOf<Child, Parent>
```

Do not use fenced Markdown code blocks for generated signatures when individual
tokens need links. Normal Markdown does not support active links inside fenced
code.

Use structured signature output instead: code-looking HTML or a future generated
component that emits the signature token by token.

Use linked Roblox terms when the call structure references Roblox classes or
data types. Use linked Luau terms when the call structure or parameter table
references analyzer/type-function concepts such as `extern type`.

Inline prose links may use Arbor's API-token syntax:

```md
`Class.Instance`
`Class.Instance:FindFirstChild()`
`Datatype.CFrame`
`Enum.Material`
`Luau.extern|extern type`
`Luau.types|types library`
```

The MkDocs extension converts recognized inline-code tokens to monospaced
links. Use `|no-link` to suppress linking when a token should remain plain
code.

Structured signature links and inline API tokens should resolve through
`content/locales/<language>/roblox-references.toml` when the term exists. Each
locale owns its own labels and summaries while keeping Roblox and Luau URLs
aligned across languages.

## Parameters And Type Parameters

Use `Parameters` for runtime function arguments.

| Parameter | Type | Description |
| --- | --- | --- |
| `parent` | `Instance` | The instance to search. |

Use `Type Parameters` for generic/type-function arguments.

| Parameter | Description |
| --- | --- |
| `Parent` | An analyzer-visible Roblox `extern type`. |

## Returns

Returns are always tables, even when there is only one return shape.

Use the shortest table that accurately represents the member:

| Type | Description |
| --- | --- |
| `Instance?` | The matching child instance when present. |

When returns vary by input type, mode, or options, add a condition column:

| Type | Condition |
| --- | --- |
| `Child` | `Child` is an analyzer-visible direct child of `Parent`. |
| `never` | The relation does not pass. |

When a return is a structured table, use nested key/type tables beneath the
return row instead of burying the shape in prose.

## Code Samples

Code samples belong with the member they demonstrate.

Do not maintain a separate public Examples section for API samples. Source
fixtures may still live under `src/examples/` for analyzer validation and may
provide the source material for member-local code samples.

Code samples should be short, focused, and aligned with real Arbor source
fixtures or supported usage.

## Compatibility Pages

Compatibility pages may exist for old links, but they must not be the main API
teaching path.

Compatibility pages should:

- identify the old wording or namespace
- point to the current reference page
- avoid adding new examples unless needed to explain migration
