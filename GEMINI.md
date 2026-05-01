# Gemini CLI Instructions

This repository is an agent-portable Compliance Trestle and OSCAL engineering toolkit. Use it from Gemini CLI by reading this file plus `AGENTS.md` before making changes.

## Repository purpose

The toolkit helps coding agents perform OSCAL document engineering, Compliance Trestle authoring, assessment workflows, POA&M workflows, and validation.

## Key paths

- `AGENTS.md` — full generic coding-agent instructions.
- `agent-skills/` — portable skills Gemini can read as task playbooks.
- `commands/` — canonical Compliance Trestle command docs.
- `skills/` — root Compliance Trestle skills.
- `plugins/document-transform/` — OSCAL document workbench scripts, command docs, templates, and skill.
- `docs/AGENT-COMPATIBILITY.md` — harness compatibility matrix.
- `docs/PORTABLE-SKILLS.md` — portable skill-pack contract.

## Required guardrails

- Preserve source traceability for legacy document conversion.
- Do not infer missing system details as facts. Mark them `needs_review`.
- Do not copy licensed framework text.
- Validate generated OSCAL structurally before claiming success.
- Keep sensitive customer evidence out of the repository.

## Legacy document to OSCAL quick path

For PDF/DOCX/Markdown SSP conversion:

1. Read `agent-skills/oscal-document-engineering/SKILL.md`.
2. Create a workspace outside committed source unless using a synthetic example.
3. Extract text and maintain page/section references.
4. Build or update a Compliance Trestle workspace.
5. Map source content into OSCAL SSP fields with traceability.
6. Run Trestle and OSCAL validation if installed.
7. Produce summary, validation, and unmapped-content reports.

## Validation commands

```bash
npm run test:agent-skills
npm run test:agent-adapters
npm run test:oscal-document-workbench
npm run test:trestle-integration
npm run test:oscal-review-workflow
```

If a dependency is missing, report the missing command and the exact install path instead of silently skipping required validation.
