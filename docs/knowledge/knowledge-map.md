# Knowledge Map

This is Arbor's canonical map for repository knowledge ownership.

Keep this as the first discovery surface. Do not turn it into a duplicate table
of contents for every wiki page.

## Repository Owners

| Concept | Canonical owner | Notes |
| --- | --- | --- |
| Knowledge ownership and docs/wiki boundary | `docs/knowledge/knowledge-system.md` | Defines owner docs, public wiki scope, and metadata restraint. |
| Knowledge ownership map | `docs/knowledge/knowledge-map.md` | This file. |
| Agent workflow | `docs/knowledge/agent-workflow.md` | Review, tool selection, validation, and stop checks. |
| Branch publication model | `docs/knowledge/branch-publication-model.md` | Source/preview/release ownership and authoring/publication boundary. |
| Arbor package system | `docs/knowledge/package-system.md` | Package purpose, source shape, runtime/type boundaries, and require boundaries. |
| Tool capabilities | `docs/knowledge/tool-capabilities.md` | Repo-facing handlers for Luau CLI analysis, MkDocs/wiki, and generators. |
| Local project planning | `docs/local/planning/planning-system.md` and `docs/local/planning/roadmap.md` | Ignored private/local state, backlog, and maintained leftovers. |

## Consumed Global Owners

| Concept | Canonical owner | Notes |
| --- | --- | --- |
| Global documentation system | `/mnt/c/Users/Kooraseru/docs/knowledge/global-docs.md` | Global versus repository documentation scope. |
| Luau file shape | `/mnt/c/Users/Kooraseru/docs/language/luau/files/file-system.md` | Path labels, `--!strict`, headers, comments, and module file shape. |
| Luau naming and constants | `/mnt/c/Users/Kooraseru/docs/language/luau/language/naming.md` | `camelCase`, `PascalCase`, `const`, and constant naming policy. |
| Luau types and uncertainty | `/mnt/c/Users/Kooraseru/docs/language/luau/language/types.md` | `unknown` boundaries, no `:: any` fixes, and typed lookup guidance. |

## Product Content Owners

| Concept | Canonical owner | Notes |
| --- | --- | --- |
| Localized public content model | `content/README.md` | Explains language roots under `content/`. |
| Wiki language configuration | `.github/wiki-languages.yml` | Language roots, localized README/CONTRIBUTING paths, and public wiki dirs. |
| English public wiki | `content/locales/en/wiki/` | User-facing product docs. |
| Japanese public wiki rewrite source | `content/locales/outdated/jp/wiki/` | Shelved localized content; not part of active Pages builds until rewritten. |
| Public content assets | `content/assets/` | Shared wiki/readme visual assets and styles. |
| Shelved public content | `content/locales/outdated/` | Rewrite/reference material that is not part of active publication builds. |

## Source Domains

| Domain | Canonical owner | Notes |
| --- | --- | --- |
| Arbor runtime/package API | `src/arbor@1.1.0/init.luau` and `docs/knowledge/package-system.md` | Runtime head owns exported API shape; package system owns package boundaries. |
| Runtime loaders | `src/arbor@1.1.0/RuntimeLoaders/` | Runtime loader behavior. |
| Authoring/facade generation | `src/arbor@1.1.0/Authoring/` | Source-side facade generation behavior. |
| Definition DSL and type functions | `src/arbor@1.1.0/Definitions/` | Type-function/tag contracts. |
| Studio plugin | `src/plugin/` | Plugin discovery, toolbar, preferences, diagnostics, and generation behavior. |
| Source examples | `src/examples/` | Analyzer fixtures and runnable examples. |
