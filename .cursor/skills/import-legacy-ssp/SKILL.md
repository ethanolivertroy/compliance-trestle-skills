---
name: import-legacy-ssp
description: Import a legacy SSP, PDF, DOCX, or Markdown package into a traceable OSCAL Document Workbench workspace using extraction, source mapping, Trestle bootstrap, and validation.
disable-model-invocation: true
---

# Import Legacy SSP

Run the full legacy SSP import workflow for Cursor.

## Before you start

Read:

- `AGENTS.md`
- `agent-skills/oscal-document-engineering/SKILL.md`
- `agent-skills/compliance-trestle-engineering/SKILL.md`
- `plugins/document-transform/oscal-document-workbench/commands/ingest-ssp.md`

This repository is an OSCAL and Compliance Trestle toolkit.
FedRAMP Rev 5 heading maps and 20x KSI coverage are optional adapters.
They are not the default product claim.

## Steps

1. Make sure you know the source files and the target workspace path. Usual path: `workspaces/<system>-ssp-import/`.
2. Copy source documents into `input/`.
3. Do not change the original files.
4. Extract source text and section structure:

```bash
bash plugins/document-transform/oscal-document-workbench/scripts/extract-legacy-doc.sh <input> --output <workspace>/extracted
```

5. Bootstrap or reuse a Compliance Trestle workspace:

```bash
bash plugins/document-transform/oscal-document-workbench/scripts/bootstrap-trestle-workspace.sh <workspace> [--profile <name>]
```

6. Optionally import a real NIST or FedRAMP baseline when the source is a FedRAMP-style SSP:

```bash
bash plugins/document-transform/oscal-document-workbench/scripts/fetch-oscal-baseline.sh <workspace>/trestle-workspace --baseline moderate
```

7. Draft a schema-valid SSP from extracted sections when Trestle is available:

```bash
bash plugins/document-transform/oscal-document-workbench/scripts/draft-ssp-from-extraction.sh <workspace> [--baseline-profile fedramp-rev5-moderate] [--overwrite]
```

Omit `--baseline-profile` to make offline stub catalog and profile models.
Replace stubs before authorization use.
For non-FedRAMP sources, do not treat the FedRAMP heading map as authoritative.
Keep unmatched sections `needs_review`.

8. Map remaining content in `source-map.csv`. Mark uncertain mappings as `needs_review`. Do not invent compliance facts.
9. Build the review queue:

```bash
bash plugins/document-transform/oscal-document-workbench/scripts/build-review-queue.sh <workspace>/extracted/source-map.csv --output <workspace>/reports/review-queue.md
```

10. Validate the package or document missing tools explicitly:

```bash
bash plugins/document-transform/oscal-document-workbench/scripts/validate-oscal-package.sh <workspace>/trestle-workspace --output <workspace>/reports/validation-report.json
```

11. Optionally report FedRAMP 20x KSI documentation coverage:

```bash
bash plugins/document-transform/oscal-document-workbench/scripts/fetch-fedramp-2026-rules.sh
bash plugins/document-transform/oscal-document-workbench/scripts/ksi-coverage-report.sh <ssp.json> --output <workspace>/reports/ksi-coverage.md
```

12. Make:

- `reports/import-summary.md`
- `reports/validation-report.json`
- `reports/unmapped-items.md`
- `reports/review-queue.md`

## Synthetic example

```bash
bash examples/legacy-ssp-to-oscal/scripts/run-example.sh
```

## Safety

- Do not commit real customer SSPs or sensitive evidence.
- Schema-valid OSCAL does not prove compliance effectiveness.
- Require human review for all `needs_review` and unmapped rows before assessment use.
