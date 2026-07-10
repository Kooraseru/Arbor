# Arbor Examples

These content/en/examples are small source fixtures for Arbor docs and analyzer checks.

Each example should make one thing clear:

```txt
problem
source
expected type behavior
runtime boundary when relevant
```

## Examples

- `direct-children/` proves direct child names, direct child lookup, and child-keyed records.
- `class-filtered-children/` proves class-filtered direct child helpers.
- `runtime-loader/` proves dynamic ModuleScript loading with explicit validation.

See `../wiki/reference/analyzer-fixtures.md` for the fixture contract and required analyzer checks.

## Screenshot And Tutorial Notes

Capture screenshots or tutorial footage from the checked example files, not from
one-off snippets.

Do that after the surrounding docs are stable enough that the media will not
immediately go stale.
