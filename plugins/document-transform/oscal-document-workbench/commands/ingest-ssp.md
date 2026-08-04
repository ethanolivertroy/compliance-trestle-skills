---
name: Ingest Legacy SSP
description: Run the end-to-end legacy SSP import process: extract source material, create source traceability, bootstrap a Trestle workspace, map content, validate OSCAL, and report unmapped items.
---

# /oscal-document-workbench:ingest-ssp

Run the full legacy SSP import process.
Extract source material.
Make source traceability.
Bootstrap a Trestle workspace.
Map content.
Validate OSCAL.
Report unmapped items.

## How to run

```bash
bash plugins/document-transform/oscal-document-workbench/scripts/extract-legacy-doc.sh <input> --output <workspace>/extracted
bash plugins/document-transform/oscal-document-workbench/scripts/bootstrap-trestle-workspace.sh <workspace> [--profile <name>]
bash plugins/document-transform/oscal-document-workbench/scripts/fetch-oscal-baseline.sh <workspace>/trestle-workspace --baseline moderate
bash plugins/document-transform/oscal-document-workbench/scripts/draft-ssp-from-extraction.sh <workspace> --baseline-profile fedramp-rev5-moderate [--overwrite]
bash plugins/document-transform/oscal-document-workbench/scripts/validate-oscal-package.sh <workspace>/trestle-workspace --output <workspace>/reports/validation-report.json
```

Draft generation uses FedRAMP Rev 5 SSP heading conventions from `templates/fedramp-rev5-heading-map.json`.
See `templates/fedramp-rev5-ssp-section-map.md` and https://www.fedramp.gov/rev5/documents-templates/ for the human template reference.

The `fetch-oscal-baseline.sh` step imports the real NIST 800-53 Rev 5 catalog and FedRAMP Rev 5 baseline profile.
Then the drafted SSP can refer to that content.
Omit that step and `--baseline-profile` to make offline stub models.
Replace stubs before authorization use.

Optionally compare the drafted SSP to the FedRAMP 20x Key Security Indicators from the 2026 Consolidated Rules:

```bash
bash plugins/document-transform/oscal-document-workbench/scripts/fetch-fedramp-2026-rules.sh
bash plugins/document-transform/oscal-document-workbench/scripts/ksi-coverage-report.sh <ssp.json> --output <workspace>/reports/ksi-coverage.md
```

## Arguments

- `<input>` : legacy source document path when extraction is required
- `<workspace>` : working directory for extracted content, Trestle files, reports, and review artifacts
- `--profile <name>` : optional baseline or profile label such as `fedramp-moderate`
- `--overwrite` : replace an existing generated workspace where the script supports it

## Outputs

Expected outputs can include:

- `extracted.md`
- `source-map.csv`
- `extract-manifest.json`
- `trestle-workspace/`
- `reports/draft-summary.md`
- `reports/import-summary.md`
- `reports/validation-report.json`
- `reports/unmapped-items.md`

## Exit codes

- `0` : success
- `2` : bad arguments, unreadable input, or unsafe overwrite attempt
- `3` : validation or transformation failed
- `5` : required external dependency is missing
- `6` : unsupported format or structurally invalid OSCAL

## Safety notes

- Keep source files unchanged.
- Maintain source traceability for every mapped OSCAL field.
- Mark uncertain mappings as `needs_review`.
- Do not treat structural validation as an audit opinion.
- Do not commit sensitive customer evidence or real SSPs.
