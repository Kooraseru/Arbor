# Agent Entry Point

Start with Arbor-owned context before editing:

- `docs/knowledge/knowledge-map.md` for owner discovery
- `docs/knowledge/agent-workflow.md` for review, tool selection, validation,
  and stop checks
- `docs/knowledge/branch-publication-model.md` before changing branch,
  release, preview, Pages, or publication workflow behavior
- `docs/local/planning/roadmap.md` for private project state and leftovers,
  when present

Repository-facing docs live under `docs/`. Public user-facing wiki content lives
under `content/locales/<language>/wiki/`.

Do not treat `content/` as the repo rulebook. It is the localized product/wiki
surface.

Do not expose planning notes as public or maintainer-facing docs. Deep planning,
handoffs, and messy decision history belong under ignored `docs/local/`.

Do not introduce generated registries or owner manifests unless a tool actually
consumes them. Arbor is intentionally starting lighter than Glyph here.
