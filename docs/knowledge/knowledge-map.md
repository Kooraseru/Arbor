# Knowledge Map

This is Arbor's canonical map for repository knowledge ownership.

Keep this as the first discovery surface. Do not turn it into a duplicate table
of contents for every wiki page.

## Repository Owners

| Concept | Canonical owner | Notes |
| --- | --- | --- |
| Knowledge ownership and docs/wiki boundary | `docs/knowledge/knowledge-system.md` | Defines owner docs, public wiki scope, and metadata restraint. |
| Knowledge ownership map | `docs/knowledge/knowledge-map.md` | This file. |
| Documentation prose style | `docs/knowledge/documentation-style.md` | Roblox STYLE.md-inspired prose, terminology, links, callout, and formatting conventions. |
| API reference page format | `docs/knowledge/api-reference-format.md` | Arbor-owned API schema, member order, signatures, parameter tables, return tables, and code sample placement. |
| Configuration and metadata formats | `docs/knowledge/configuration-conventions.md` | TOML-first Arbor metadata, YAML exceptions, workflow script boundaries, and locale/API metadata split. |
| Agent workflow | `docs/knowledge/agent-workflow.md` | Review, tool selection, validation, and stop checks. |
| Branch publication model | `docs/knowledge/branch-publication-model.md` | Source/pre-release/release ownership and authoring/publication boundary. |
| Arbor package system | `docs/knowledge/package-system.md` | Package purpose, source shape, runtime/type boundaries, and require boundaries. |
| Tool capabilities | `docs/knowledge/tool-capabilities.md` | Repo-facing handlers for Luau CLI analysis, MkDocs/wiki, and generators. |
| Local project planning | `docs/local/planning/planning-system.md` and `docs/local/planning/roadmap.md` | Ignored private/local state, backlog, and maintained leftovers. |

## Consumed Global Owners

| Concept | Canonical owner | Notes |
| --- | --- | --- |
| Global documentation system | `/mnt/c/Users/Kooraseru/docs/knowledge/global-docs.md` | Global versus repository documentation scope. |
| Configuration and metadata formats | `/mnt/c/Users/Kooraseru/docs/knowledge/configuration-conventions.md` | TOML-first repository metadata, YAML/JSON exceptions, workflow script boundaries, and localization metadata split. |
| Luau file shape | `/mnt/c/Users/Kooraseru/docs/language/luau/files/file-system.md` | Path labels, `--!strict`, headers, comments, and module file shape. |
| Luau naming and constants | `/mnt/c/Users/Kooraseru/docs/language/luau/language/naming.md` | `camelCase`, `PascalCase`, `const`, and constant naming policy. |
| Luau types and uncertainty | `/mnt/c/Users/Kooraseru/docs/language/luau/language/types.md` | `unknown` boundaries, no `:: any` fixes, and typed lookup guidance. |

## Product Content Owners

| Concept | Canonical owner | Notes |
| --- | --- | --- |
| Public content source model | `docs/knowledge/knowledge-system.md` | Defines `content/pages/`, `content/repo/`, locale data, and generated output boundaries. |
| Wiki project/domain config | `.github/wiki-languages.yml` | Project path and domain pattern config; default locale is marked in locale metadata. |
| Locale metadata | `content/locales/<language>/locale.toml` | Per-locale display metadata; the folder name is the language identifier. |
| Public wiki page structure | `content/pages/wiki/` | User-facing product docs governed by documentation style and API reference format owners. |
| Repository-facing public page structure | `content/repo/` | Source structure for generated root `README.md`, `CONTRIBUTING.md`, and `LICENSE`. |
| English locale data | `content/locales/en/` | English strings, locale metadata, and Roblox/Luau reference labels. |
| Japanese locale data | `content/locales/ja/` | Japanese strings, locale metadata, and Roblox/Luau reference labels. |
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
