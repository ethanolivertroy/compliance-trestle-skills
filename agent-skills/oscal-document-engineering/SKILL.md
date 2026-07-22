---
name: oscal-document-engineering
description: Convert, validate, and maintain OSCAL documents from legacy SSP/PDF/DOCX/Markdown source material.
tags: [oscal, ssp, compliance-trestle, document-transformation, grc]
related_skills: [compliance-trestle]
---

# OSCAL Document Engineering

Use this skill when a user wants to turn old compliance documents into maintainable OSCAL, especially SSPs, SAPs, SARs, POA&Ms, component definitions, and supporting evidence packages.

## Core rule

Every OSCAL statement must be traceable to source text, collected evidence, or a user-supplied assertion. If the source is unclear, mark the item `needs_review` instead of inventing a compliance fact.

## Inputs

Common inputs:

- SSP in PDF, DOCX, Markdown, or text.
- Existing OSCAL JSON/XML/YAML.
- Evidence folders, diagrams, inventories, policies, or POA&M spreadsheets.
- Framework/profile target such as FedRAMP Moderate, NIST 800-53, SOC 2, ISO 27001, or organization-specific profiles.

## Outputs

Produce these artifacts:

- OSCAL workspace or package.
- `source-traceability-map.csv`.
- `ssp-import-plan.md`.
- `import-summary.md`.
- `validation-report.json` or Markdown equivalent.
- `unmapped-items.md` listing content requiring human review.

## Workflow

1. Confirm source files and target OSCAL document type.
2. Create a workspace outside committed source unless using a synthetic example.
3. Extract text while preserving page numbers, headings, and section identifiers where possible.
4. Build a source traceability map using `templates/source-traceability-map.csv`.
5. Initialize or update a Compliance Trestle workspace.
6. Draft a schema-valid SSP from extracted sections when Trestle is available:

```bash
bash plugins/document-transform/oscal-document-workbench/scripts/draft-ssp-from-extraction.sh <workspace> --overwrite
```

Use FedRAMP Rev 5 heading conventions from `plugins/document-transform/oscal-document-workbench/templates/fedramp-rev5-heading-map.json`.
7. Refine mappings and fill remaining OSCAL SSP structure:
   - metadata
   - parties and roles
   - system characteristics
   - system implementation
   - control implementation
   - inventory items
   - back matter resources
8. Validate with Compliance Trestle and OSCAL CLI where available.
9. Generate summary reports and identify gaps.
10. Ask the user or system owner to review all `needs_review` items.

## Mapping guidance

- Map document title, version, system name, owner, and dates into OSCAL metadata.
- Map authorizing officials, system owners, ISSOs, assessors, and service providers into parties and responsible roles.
- Map boundary descriptions, data types, users, deployment model, and interconnections into system characteristics.
- Map components, services, accounts, inventories, and cloud resources into system implementation.
- Map control narratives by control ID into control implementation statements.
- Map attachments, diagrams, policies, and evidence into back matter resources.

## Validation commands

Use commands available in the local environment. Examples:

```bash
trestle validate -f <path-to-ssp.json>
trestle validate -f <path-to-ssp.json>
```

If a validator is missing, report the missing dependency and continue only if the user accepts partial validation.

## References

- `references/legacy-doc-ingestion.md`
- `references/oscal-validation.md`
- `templates/ssp-import-plan.md`
- `templates/source-traceability-map.csv`
