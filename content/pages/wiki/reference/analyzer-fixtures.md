---
title: {{wiki.reference.analyzer_fixtures.title}}
---

# {{wiki.reference.analyzer_fixtures.title}}

{{wiki.reference.analyzer_fixtures.status}}

{{wiki.reference.analyzer_fixtures.intro}}

{{wiki.reference.analyzer_fixtures.small_on_purpose}}

{{wiki.reference.analyzer_fixtures.source_tree_boundary}}

## {{wiki.reference.analyzer_fixtures.fixture_set_heading}}

| {{wiki.reference.analyzer_fixtures.fixture_column}} | {{wiki.reference.analyzer_fixtures.claim_column}} |
| --- | --- |
| `src/arbor@1.1.0/Definitions/TypeFunctions/Children/Names/ChildNames.luau` | {{wiki.reference.analyzer_fixtures.identify_type_claim}} |
| `src/arbor@1.1.0/Definitions/TypeFunctions/Children/Checks/IsChildOf.luau` | {{wiki.reference.analyzer_fixtures.check_relations_claim}} |
| `src/plugin/` | {{wiki.reference.analyzer_fixtures.plugin_sandbox_claim}} |
| {{wiki.reference.analyzer_fixtures.generated_payload_fixture}} | {{wiki.reference.analyzer_fixtures.generated_payload_claim}} |

## {{wiki.reference.analyzer_fixtures.required_checks_heading}}

{{wiki.reference.analyzer_fixtures.wrapper_validation}}

```powershell
powershell -ExecutionPolicy Bypass -File .github/scripts/analyze-luau.ps1
```

{{wiki.reference.analyzer_fixtures.run_validation}}

```powershell
powershell -ExecutionPolicy Bypass -File .github\scripts\analyze-luau.ps1
```

{{wiki.reference.analyzer_fixtures.command_uses}}

{{wiki.reference.analyzer_fixtures.focused_lane}}

```txt
src/arbor@1.1.0/init.luau
src/arbor@1.1.0/Definitions/TypeFunctions/**/*.luau
src/arbor@1.1.0/RuntimeLoaders/*.luau
```

## {{wiki.reference.analyzer_fixtures.negative_checks_heading}}

{{wiki.reference.analyzer_fixtures.negative_checks_intro}}

- {{wiki.reference.analyzer_fixtures.negative_child_names}}
- {{wiki.reference.analyzer_fixtures.negative_relation}}

## {{wiki.reference.analyzer_fixtures.current_limitation_heading}}

{{wiki.reference.analyzer_fixtures.current_limitation}}
