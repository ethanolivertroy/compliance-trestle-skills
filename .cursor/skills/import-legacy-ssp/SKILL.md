---
name: import-legacy-ssp
description: Import a legacy SSP, PDF, DOCX, or Markdown package into a traceable OSCAL Document Workbench workspace using extraction, source mapping, Trestle bootstrap, and validation.
disable-model-invocation: true
---

# Import Legacy SSP

Run the end-to-end legacy SSP import workflow for Cursor.

## Before you start

Read:

- `AGENTS.md`
- `agent-skills/oscal-document-engineering/SKILL.md`
- `agent-skills/compliance-trestle-engineering/SKILL.md`
- `plugins/document-transform/oscal-document-workbench/commands/ingest-ssp.md`

## Steps

1. Confirm source files and the target workspace path, usually `workspaces/<system>-ssp-import/`.
2. Copy source documents into `input/` without modifying originals.
3. Extract source text and section structure:

```bash
bash plugins/document-transform/oscal-document-workbench/scripts/extract-legacy-doc.sh <input> --output <workspace>/extracted
```

4. Bootstrap or reuse a Compliance Trestle workspace:

```bash
bash plugins/document-transform/oscal-document-workbench/scripts/bootstrap-trestle-workspace.sh <workspace> [--profile <name>]
```

5. Map extracted content to OSCAL SSP fields with `source-map.csv` traceability.
6. Mark uncertain mappings as `needs_review`; do not invent compliance facts.
7. Build the review queue:

```bash
bash plugins/document-transform/oscal-document-workbench/scripts/build-review-queue.sh <workspace>/extracted/source-map.csv --output <workspace>/reports/review-queue.md
```

8. Validate the package or document missing tools explicitly:

```bash
bash plugins/document-transform/oscal-document-workbench/scripts/validate-oscal-package.sh <workspace>/trestle-workspace --output <workspace>/reports/validation-report.json
```

9. Produce:

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
