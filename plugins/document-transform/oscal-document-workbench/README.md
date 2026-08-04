# OSCAL Document Workbench

The OSCAL Document Workbench helps agents and practitioners convert legacy SSP, PDF, DOCX, or Markdown source material into traceable OSCAL workspaces.
Claude Code plugin users can use it.
Other coding agents can read the command docs and run the scripts directly.

## Core workflow

```text
legacy SSP / PDF / DOCX / Markdown
        ↓
extract-legacy-doc.sh
        ↓
extracted.md + source-map.csv + extract-manifest.json
        ↓
bootstrap-trestle-workspace.sh
        ↓
Compliance Trestle workspace
        ↓
fetch-oscal-baseline.sh (optional, real NIST/FedRAMP baseline)
        ↓
draft-ssp-from-extraction.sh
        ↓
draft OSCAL SSP JSON + updated source-map.csv
        ↓
validate-oscal-package.sh
        ↓
ksi-coverage-report.sh (optional, FedRAMP 20x KSI cross-reference)
        ↓
validation report + needs-review list
```

## Commands

- `ingest-ssp` : end-to-end guidance for legacy SSP import.
- `extract-legacy-doc` : extract source text and make a traceability map skeleton.
- `build-trestle-workspace` : start a Compliance Trestle workspace.
- `fetch-oscal-baseline` : download and import the NIST 800-53 Rev 5 catalog and a FedRAMP Rev 5 baseline profile.
- `draft-ssp-from-extraction` : draft a schema-valid OSCAL SSP from extracted legacy sections with FedRAMP Rev 5 heading conventions.
- `ksi-coverage` : compare an OSCAL SSP to the FedRAMP 20x Key Security Indicators from the 2026 Consolidated Rules.
- `validate-oscal-package` : validate OSCAL files or packages with available validators.
- `update-ssp-from-evidence` : update an SSP from new evidence and keep source references.

## Legacy templates and the FedRAMP 2026 transition

FedRAMP is moving away from the legacy Rev 5 document templates.
It moves to the machine-readable 2026 Consolidated Rules (`FedRAMP/rules` and `FedRAMP/2026-markdown` on GitHub).
FedRAMP 20x is organized around Key Security Indicators.
This workbench supports both directions:

- Legacy Rev 5 documents convert into OSCAL through extraction and `draft-ssp-from-extraction`.
- The resulting OSCAL SSP can compare to 20x KSIs through `ksi-coverage`.
- Teams can see how existing Rev 5 documentation positions them for the KSI model.

## Guardrails

- Every OSCAL field must trace to source text, collected evidence, or a user assertion.
- Unclear mappings must be marked `needs_review`.
- Do not treat validation as an audit opinion or authorization decision.
- Do not commit sensitive customer documents or evidence.
