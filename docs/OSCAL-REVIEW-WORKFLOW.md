# OSCAL review workflow

Use this workflow whenever legacy documents are transformed into OSCAL or Compliance Trestle workspaces.

## Review gates

1. Extraction gate: confirm extracted text and section boundaries are usable.
2. Mapping gate: confirm each OSCAL target has source traceability.
3. Control gate: confirm generated control implementation statements are supported by source evidence.
4. Validation gate: run Trestle/OSCAL validation and triage findings.
5. Release gate: confirm no unresolved `needs_review` items are hidden in final outputs.

## Review queue

Generate a queue from a source map:

```bash
bash plugins/document-transform/oscal-document-workbench/scripts/build-review-queue.sh \
  workspaces/acme/extracted/source-map.csv \
  workspaces/acme/reports/review-queue.md
```

The script exits nonzero when review items remain. That behavior is intentional: unresolved mappings should stop automated release even though they may be acceptable during drafting.

## Reviewer decisions

Allowed decisions:

- approve
- remap
- reject
- needs_more_evidence
- defer

Document reviewer decisions in the queue or a control mapping review CSV. Do not overwrite uncertainty by making unsupported generated content look authoritative.

## Required warning

Every generated package should state: schema-valid OSCAL does not prove compliance effectiveness.
