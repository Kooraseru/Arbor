# Package System

This document owns Arbor's repository-local package scope, source shape, and
runtime/type boundary rules.

Global Luau style, file shape, naming, and uncertainty rules still come from
the global Luau owners listed in `docs/knowledge/knowledge-map.md`.

## Purpose

Arbor answers one package question:

```txt
What static structure does the Luau analyzer know about an owned instance tree?
```

Arbor owns analyzer-facing tree helpers, typed lookup conventions, and small
validation-friendly runtime loader primitives.

Arbor does not own runtime registries, boot sequencing, serialization, dispatch
parsing, descriptor identity, pipeline order, or package lookup.

## Source Shape

Package payload source lives under `src/`.

The versioned Arbor `ModuleScript` root lives as a named child under `src/`,
such as `src/arbor@1.1.0/`.

Focused helpers should remain public under the Arbor module root when they are
part of the supported API. Repository metadata, maintainer docs, localized
public content sources, workflows, and generated publication outputs are not
package payload source.

Do not add package dependencies unless Arbor cannot perform its core job
without them.

## Type Boundary

Public Arbor types, public function parameters, public returns, and loader
contracts must not expose `any`.

Dynamic `require` belongs only in explicit runtime loader helpers. Runtime
loaders must validate loaded values before returning typed data.

Runtime child discovery proves runtime children exist. It does not prove their
static public API.

Typed child-name discovery may prove owned child names when the active analyzer
exposes direct children as literal extern properties. It does not prove
`ModuleScript` return types.

If the analyzer cannot interpret a public shape, redesign the type helper or API
surface instead of casting through the analyzer.

## Require Boundaries

Use relative or package-local requires inside Arbor source.

Files outside Arbor's local source boundary, including examples, generated
outputs, plugin sandboxes, and project-owned topology, should not use climbing
relative requires to find Arbor. Reference the Arbor `ModuleScript` instance
directly or pass the instance through an adapter or test setup.
