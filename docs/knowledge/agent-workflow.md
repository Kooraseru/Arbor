# Agent Workflow

This document owns Arbor's repository-local workflow for AI agents.

## Knowledge Review

Before planning, auditing, or editing:

- load `docs/knowledge/knowledge-map.md`
- identify the affected owner docs or source domains
- inspect existing Arbor files before copying Glyph patterns
- state unclear ownership before creating new structure

## Tool Selection

Choose tools by capability, then implementation.

Use `docs/knowledge/tool-capabilities.md` before adding, changing, or reporting
validation/tooling behavior.

If a capability is documented but unavailable locally, report it as unavailable.

## Ownership Review

Before adding a document, section, manifest, registry, or planning artifact:

- identify the concept
- identify the existing owner
- update the owner when one exists
- create a new owner only when no existing owner fits

Do not create metadata just because Glyph has it. Arbor should stay lean unless
tooling needs the structure.

## Stop Validation

Before reporting completed repository changes:

- confirm relevant owners were loaded
- run the selected validation tools, or explain skipped checks
- report exact commands and pass/fail status
- update `docs/local/planning/` when private project state or leftovers changed
