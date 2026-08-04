---
name: oscal-document-workbench-expert
description: Convert legacy SSP/PDF/DOCX source material into traceable, validated OSCAL workspaces with Compliance Trestle and OSCAL CLI.
---

# oscal-document-workbench-expert

Use this skill when a user wants to modernize legacy compliance documents into OSCAL.
Use it also to maintain an OSCAL SSP with agent help.

## Required behavior

1. Keep original source files unchanged.
2. Make or update a source traceability map.
3. Map content into OSCAL only when there is source support or an explicit user assertion.
4. Mark uncertain content as `needs_review`.
5. Validate generated OSCAL structurally with available tools.
6. Make an import summary and an unmapped-items report.

## Composition

- Use `agent-skills/oscal-document-engineering/SKILL.md` for portable workflow details.
- Use root Compliance Trestle commands and `trestle validate` for OSCAL validation and workspace checks.
- Use official FedRAMP or OSCAL converters outside this repository when source material matches those specialized tools.
- Use reviewed evidence packages to update control narratives and POA&M content.
- Preserve source traceability.

## Typical sequence

```bash
bash plugins/document-transform/oscal-document-workbench/scripts/extract-legacy-doc.sh input/old-ssp.docx --output workspaces/acme/extracted
bash plugins/document-transform/oscal-document-workbench/scripts/bootstrap-trestle-workspace.sh workspaces/acme --profile fedramp-moderate
bash plugins/document-transform/oscal-document-workbench/scripts/fetch-oscal-baseline.sh workspaces/acme/trestle-workspace --baseline moderate
bash plugins/document-transform/oscal-document-workbench/scripts/draft-ssp-from-extraction.sh workspaces/acme --baseline-profile fedramp-rev5-moderate --overwrite
bash plugins/document-transform/oscal-document-workbench/scripts/build-review-queue.sh workspaces/acme/extracted/source-map.csv --output workspaces/acme/reports/review-queue.md
bash plugins/document-transform/oscal-document-workbench/scripts/validate-oscal-package.sh workspaces/acme/trestle-workspace --output workspaces/acme/reports/validation-report.json
```

Skip baseline fetch and `--baseline-profile` for offline stub models.
Skip the FedRAMP heading-map assumptions for non-FedRAMP sources.

Validation success means the package is structurally valid.
It is not an attestation, authorization, or audit opinion.
