---
name: Validate OSCAL Package
description: Validate an OSCAL file or Trestle package with available validators and write a validation summary.
---

# /oscal-document-workbench:validate-oscal-package

Validate an OSCAL file or Trestle package with available validators and write a validation summary.

## How to run

```bash
bash plugins/document-transform/oscal-document-workbench/scripts/validate-oscal-package.sh <path> [--output <report.json>] [--allow-partial]
```

Pass a Trestle workspace directory, an import workspace that contains `trestle-workspace/`, or one OSCAL JSON file.
The script skips non-OSCAL JSON such as `extracted/sections.json`.

## Arguments

- `<path>` : OSCAL file, Trestle workspace, or import workspace to validate
- `--output <path>` : validation report JSON path (default: `validation-report.json`)
- `--allow-partial` : exit 0 when a validator is missing. Default is exit 5 for `partial`.

## Outputs

- `reports/validation-report.json` or the path passed to `--output`

## Exit codes

- `0` : all available validators passed, or `partial` with `--allow-partial`
- `2` : bad arguments or missing target
- `3` : a validator reported a structural failure
- `5` : required validator missing (`partial`) and `--allow-partial` was not set

## Safety notes

- Keep source files unchanged.
- Maintain source traceability for every mapped OSCAL field.
- Mark uncertain mappings as `needs_review`.
- Do not treat structural validation as an audit opinion.
- Do not commit sensitive customer evidence or real SSPs.
