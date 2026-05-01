# OSCAL Document Workbench

The OSCAL Document Workbench helps agents and practitioners convert legacy SSP/PDF/DOCX/Markdown source material into traceable OSCAL workspaces. It is designed for Claude Code plugin users and for other coding agents that read command docs and run scripts directly.

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
validate-oscal-package.sh
        ↓
validation report + needs-review list
```

## Commands

- `ingest-ssp` — end-to-end guidance for legacy SSP import.
- `extract-legacy-doc` — extract source text and create a traceability map skeleton.
- `build-trestle-workspace` — initialize a Compliance Trestle workspace.
- `validate-oscal-package` — validate OSCAL files or packages with available validators.
- `update-ssp-from-evidence` — update an SSP from new evidence while preserving source references.

## Guardrails

- Every OSCAL field should trace to source text, collected evidence, or a user assertion.
- Unclear mappings must be marked `needs_review`.
- Do not treat validation as an audit opinion or authorization decision.
- Do not commit sensitive customer documents or evidence.
