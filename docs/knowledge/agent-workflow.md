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

## Testing And Validation Policy

Do not create test scripts that exist only for local use.

All repository validation must be defined through GitHub Actions workflows.
Local validation must run the same commands, stages, and configuration used by
GitHub Actions.

Structure each workflow as separate validation stages. Examples include:

- formatting
- linting
- static analysis
- generated-file validation
- documentation validation
- unit or integration tests
- packaging or build validation

Stages that require GitHub-specific context must detect the required GitHub
environment variables before running.

When the required GitHub environment is unavailable, the stage must skip
cleanly. It must not fail, emulate GitHub with hardcoded values, or create a
separate local implementation.

Stages that do not require GitHub-specific context must run identically both
locally and in GitHub Actions.

The intended model is:

```text
shared validation stages
├── run locally through the workflow-compatible runner
└── run remotely through GitHub Actions

GitHub-dependent stages
├── run when the required GitHub environment exists
└── skip when it does not
```

Do not add:

- local-only test scripts
- duplicated local and CI validation paths
- wrapper scripts that implement different behavior locally
- fake GitHub environment values
- validation commands that are not represented by a GitHub Actions stage

A helper script is acceptable only when a GitHub Actions stage calls that same
script. The workflow remains the canonical entry point and owner of the
validation process.

Before adding any test or validation tool, determine which GitHub Actions stage
owns it and how that stage behaves outside GitHub.

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
