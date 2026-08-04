# OSCAL review workflow

Use this workflow when you convert legacy documents into OSCAL or Compliance Trestle workspaces.

## Review gates

1. Extraction gate: make sure extracted text and section boundaries are usable.
2. Mapping gate: make sure each OSCAL target has source traceability.
3. Control gate: make sure generated control implementation statements have source evidence.
4. Validation gate: run Trestle and OSCAL validation. Triage findings.
5. Release gate: make sure no unresolved `needs_review` items are hidden in final outputs.

## Review queue

Make a queue from a source map:

```bash
bash plugins/document-transform/oscal-document-workbench/scripts/build-review-queue.sh \
  workspaces/acme/extracted/source-map.csv \
  workspaces/acme/reports/review-queue.md
```

The script exits nonzero when review items remain.
That behavior is intentional.
Unresolved mappings must stop automated release.
Unresolved mappings can stay during drafting.

## Mapping statuses vs reviewer decisions

`source-map.csv` status values are `mapped`, `needs_review`, `unmapped`, or `reject`.

Reviewer decisions in the queue are separate.

Allowed decisions:

- approve
- remap
- reject
- needs_more_evidence
- defer

Document reviewer decisions in the queue or in a control mapping review CSV.
Do not overwrite uncertainty.
Do not make unsupported generated content look authoritative.

## Required warning

Every generated package should state: schema-valid OSCAL does not prove compliance effectiveness.
