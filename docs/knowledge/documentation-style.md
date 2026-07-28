# Documentation Style

This document owns Arbor's public prose conventions.

Arbor uses Roblox Creator Docs `STYLE.md` as the upstream model for prose style,
terminology, and API-link behavior where it fits Arbor.

Roblox source:

```txt
https://github.com/Roblox/creator-docs/blob/main/STYLE.md
```

## Scope

This owner covers:

- terminology and capitalization
- present tense and active voice
- summaries versus detailed explanations
- second-person guidance without overusing "you"
- links to Roblox classes, data types, enums, members, and Luau docs concepts
- alerts, notes, warnings, and other callout tone
- code, paths, functions, variables, and inline identifier formatting

This owner does not define Arbor API page layout. Use
`docs/knowledge/api-reference-format.md` for call structure, metadata labels,
parameter sections, return sections, examples, and ordering.

This owner also does not define repository configuration formats. Use
`docs/knowledge/configuration-conventions.md` for TOML/YAML/JSON rules and
workflow logic placement.

## Content Roles

Use section headings to make intent obvious:

| Role | Purpose |
| --- | --- |
| Conceptual | Explain what something is and why it exists. |
| Task-based | Explain how to complete an action. |
| Reference | Describe exact API shape, inputs, returns, errors, and constraints. |
| Tutorial | Walk through a larger end-to-end learning path. |

A page may contain more than one role, but each role should have a clear heading.

## Prose Rules

| Rule | Arbor convention |
| --- | --- |
| Tense | Prefer present tense. |
| Voice | Prefer active voice. |
| Reader address | Use second person when useful, but avoid repeating "you can". |
| Requirements | Use "must" for requirements, "should" for recommendations, "can" for optional actions or permission, and "might" for possibility. Avoid "may". |
| Emphasis | Use bold for key terms and UI labels. Use code formatting for paths, APIs, functions, variables, and literals. |
| Localization | Avoid idioms and colloquialisms in public docs. |
| Numbers | Spell out one through nine unless the number has a unit. Use numerals for 10 and above. |

## Platform And Luau Links

When Arbor references Roblox API terms in prose, link to Creator Docs when the
term is important to understanding the Arbor behavior.

Roblox-style API-link syntax from upstream docs is the conceptual model:

```txt
`Class.Instance`
`Class.Instance:FindFirstChild()`
`Datatype.CFrame`
`Enum.Font`
```

Arbor's MkDocs renderer parses that inline-code token syntax through
`.github/mkdocs_extensions/api_links.py`. Public wiki pages should use API
tokens for Roblox and Luau references, with localized tooltip metadata from
`content/locales/<language>/roblox-references.toml`.

Avoid excessive repeated links. Link the first meaningful use, then use pronouns
or contextual prose when the term is already clear.

Analyzer and type-function concepts that belong to Luau, such as `extern type`,
`type`, `types` library, singleton type, table type, and function type, should
link to `luau.org`, not Creator Docs.

Use this split:

| Term source | Link target |
| --- | --- |
| Roblox engine, platform, data model, classes, members, enums, and Roblox data types | Roblox Creator Docs |
| Luau language, analyzer logic, type system, type functions, and `types` library concepts | Luau documentation |
| Arbor API members | Arbor API reference pages |

Short form: Creator Docs are for Roblox internals; Luau docs are for Luau
logic.
