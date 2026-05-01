---
name: oscal-document-workbench-expert
description: Convert legacy SSP/PDF/DOCX source material into traceable, validated OSCAL workspaces with Compliance Trestle and OSCAL CLI.
---

# oscal-document-workbench-expert

Use this skill when a user wants to modernize legacy compliance documents into OSCAL or maintain an OSCAL SSP with agent help.

## Required behavior

1. Preserve original source files unchanged.
2. Create or update a source traceability map.
3. Map content into OSCAL only when there is source support or an explicit user assertion.
4. Mark uncertain content as `needs_review`.
5. Validate generated OSCAL structurally with available tools.
6. Produce an import summary and unmapped-items report.

## Composition

- Use `agent-skills/oscal-document-engineering/SKILL.md` for portable workflow details.
- Use root Compliance Trestle commands and `trestle validate` for OSCAL validation and workspace checks.
- Use official FedRAMP or OSCAL converters outside this repository when source material matches those specialized tools.
- Use reviewed evidence packages to update control narratives and POA&M content, preserving source traceability.

## Typical sequence

```bash
bash plugins/document-transform/oscal-document-workbench/scripts/extract-legacy-doc.sh input/old-ssp.docx --output workspaces/acme/extracted
bash plugins/document-transform/oscal-document-workbench/scripts/bootstrap-trestle-workspace.sh workspaces/acme --profile fedramp-moderate
bash plugins/document-transform/oscal-document-workbench/scripts/validate-oscal-package.sh workspaces/acme/trestle-workspace --output workspaces/acme/reports/validation-report.json
```

Validation success means the package is structurally valid. It is not an attestation, authorization, or audit opinion.
