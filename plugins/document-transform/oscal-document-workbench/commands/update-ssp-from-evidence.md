---
name: Update SSP From Evidence
description: Use new evidence, findings, or POA&M information to update an existing OSCAL SSP while preserving traceability.
---

# /oscal-document-workbench:update-ssp-from-evidence

Use new evidence, findings, or POA&M information to update an existing OSCAL SSP.
Keep source traceability.
This is an agent-led workflow.
This is not a one-shot converter.

## How to run

1. Summarize the current source map:

```bash
node plugins/document-transform/oscal-document-workbench/scripts/summarize-source-map.js <workspace>/extracted/source-map.csv
```

Exit `3` means `needs_review` rows remain.
That is expected until review is complete.

2. Add or update source-map rows for the new evidence.
Keep source hashes, targets, and `needs_review` where the evidence is incomplete.
3. Update the SSP through the Trestle authoring roundtrip when possible.
If a direct JSON edit is required, validate afterward.
4. Rebuild the review queue:

```bash
bash plugins/document-transform/oscal-document-workbench/scripts/build-review-queue.sh \
  <workspace>/extracted/source-map.csv \
  --output <workspace>/reports/review-queue.md
```

5. Validate:

```bash
bash plugins/document-transform/oscal-document-workbench/scripts/validate-oscal-package.sh \
  <workspace>/trestle-workspace \
  --output <workspace>/reports/validation-report.json
```

## Arguments

- `<workspace>` : import workspace with `extracted/`, `trestle-workspace/`, and `reports/`
- `<source-map.csv>` : current source traceability map

## Outputs

- updated `source-map.csv`
- updated SSP model or markdown
- `reports/review-queue.md`
- `reports/validation-report.json`

## Exit codes

- `0` : summary has no `needs_review` rows
- `2` : bad arguments or unreadable input
- `3` : `needs_review` rows remain or validation failed
- `5` : required external dependency is missing

## Safety notes

- Keep source files unchanged.
- Maintain source traceability for every mapped OSCAL field.
- Mark uncertain mappings as `needs_review`.
- Do not treat structural validation as an audit opinion.
- Do not commit sensitive customer evidence or real SSPs.
