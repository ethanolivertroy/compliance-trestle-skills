---
name: review-oscal-mappings
description: Review source-to-OSCAL mappings, triage needs_review rows, and update the review queue before treating generated OSCAL as ready for stakeholders.
disable-model-invocation: true
---

# Review OSCAL Mappings

Human-in-the-loop review workflow for source traceability and mapping quality.

## Read first

- `docs/OSCAL-REVIEW-WORKFLOW.md`
- `adapters/generic-agent-package/prompts/review-oscal-mappings.md`
- `plugins/document-transform/oscal-document-workbench/templates/review-queue.md`
- `plugins/document-transform/oscal-document-workbench/templates/control-mapping-review.csv`

## Steps

1. Load `source-map.csv` and any generated `reports/review-queue.md`.
2. For each `needs_review` or unmapped row:
   - confirm the source text supports the OSCAL target;
   - mark unsupported claims `needs_review` or `reject`;
   - identify missing evidence;
   - preserve reviewer notes.
3. Regenerate or update the review queue:

```bash
bash plugins/document-transform/oscal-document-workbench/scripts/build-review-queue.sh <workspace>/extracted/source-map.csv --output <workspace>/reports/review-queue.md
```

4. Summarize counts of mapped, `needs_review`, and unmapped items.
5. Block "ready for assessment" claims while unresolved review rows remain.

## Reviewer decisions

Use explicit statuses in the traceability map:

- `mapped`
- `needs_review`
- `unmapped`
- `reject`

Do not silently rewrite uncertain source statements as implemented technical reality.
