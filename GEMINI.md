# Gemini CLI Instructions

This repository is an agent-portable Compliance Trestle and OSCAL engineering toolkit.
Use it from Gemini CLI.
Read this file and `AGENTS.md` before you make changes.

Write project documentation in ASD-STE100 Simplified Technical English.

## Repository purpose

The toolkit helps coding agents do OSCAL document engineering, Compliance Trestle authoring, assessment workflows, POA&M workflows, and validation.

## Key paths

- `AGENTS.md` : full generic coding-agent instructions.
- `agent-skills/` : portable skills that Gemini can read as task playbooks.
- `commands/` : primary Compliance Trestle command docs.
- `skills/` : root Compliance Trestle skills.
- `plugins/document-transform/` : OSCAL document workbench scripts, command docs, templates, and skill.
- `docs/AGENT-COMPATIBILITY.md` : harness compatibility matrix.
- `docs/PORTABLE-SKILLS.md` : portable skill-pack contract.

## Required guardrails

- Use Python 3.10-3.12 with Compliance Trestle. Python 3.14+ prints an expected Pydantic V1 warning on every trestle command.
- Preserve source traceability for legacy document conversion.
- Do not treat missing system details as facts. Mark them `needs_review`.
- Do not copy licensed framework text.
- Validate generated OSCAL structurally before you claim success.
- Keep sensitive customer evidence out of the repository.

## Legacy document to OSCAL quick path

For PDF, DOCX, or Markdown SSP conversion, do these steps:

1. Read `agent-skills/oscal-document-engineering/SKILL.md`.
2. Make a workspace outside committed source unless you use a synthetic example.
3. Extract text.
4. Keep page and section references.
5. Build or update a Compliance Trestle workspace.
6. Map source content into OSCAL SSP fields with source traceability.
7. Run Trestle and OSCAL validation if installed.
8. Make summary, validation, and unmapped-content reports.

## Validation commands

```bash
npm run test:agent-skills
npm run test:agent-adapters
npm run test:cursor-support
npm run test:oscal-document-workbench
npm run test:draft-ssp
npm run test:trestle-integration
npm run test:oscal-review-workflow
```

If a dependency is missing, report the missing command and the exact install path.
Do not skip required validation with no record.
