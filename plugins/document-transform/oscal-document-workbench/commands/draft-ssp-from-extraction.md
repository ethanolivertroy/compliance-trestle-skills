---
name: Draft SSP From Extraction
description: Draft a schema-valid OSCAL SSP from extracted legacy sections, optionally importing a real FedRAMP baseline profile.
---

# /oscal-document-workbench:draft-ssp-from-extraction

Draft a schema-valid OSCAL SSP from `<workspace>/extracted/sections.json` into `<workspace>/trestle-workspace/`.

## How to run

```bash
bash plugins/document-transform/oscal-document-workbench/scripts/fetch-oscal-baseline.sh <workspace>/trestle-workspace --baseline moderate
bash plugins/document-transform/oscal-document-workbench/scripts/draft-ssp-from-extraction.sh <workspace> --baseline-profile fedramp-rev5-moderate [--overwrite]
```

Omit `fetch-oscal-baseline.sh` and `--baseline-profile` to make offline stub catalog and profile models.
Replace stubs before authorization use.

The FedRAMP Rev 5 heading map is an optional structural adapter.
For non-FedRAMP sources, keep unmatched sections `needs_review`.
Do not force FedRAMP field targets.

## Arguments

- `<workspace>` : import workspace that contains `extracted/` and `trestle-workspace/`
- `--ssp-name <alias>` : Trestle SSP alias
- `--profile-label <name>` : label recorded in reports
- `--baseline-profile <alias>` : existing Trestle profile alias to import
- `--overwrite` : replace existing draft models
- `--skip-validate` : skip `trestle validate` after drafting

## Outputs

- `trestle-workspace/system-security-plans/<alias>/system-security-plan.json`
- updated `extracted/source-map.csv`
- `reports/draft-summary.md`

## Exit codes

- `0` : success
- `2` : bad arguments or missing extraction or workspace
- `3` : validation or transformation failed
- `5` : Compliance Trestle is missing

## Safety notes

- Keep source files unchanged.
- Maintain source traceability for every mapped OSCAL field.
- Mark uncertain mappings as `needs_review`.
- Do not treat structural validation as an audit opinion.
- Do not commit sensitive customer evidence or real SSPs.
