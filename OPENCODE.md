# OpenCode Instructions

OpenCode can use this repository as a local Compliance Trestle and OSCAL engineering workspace.
The Claude Code plugin files are useful.
OpenCode must treat them as markdown command specifications and direct scripts.
OpenCode must not treat them as native slash commands.

Write project documentation in ASD-STE100 Simplified Technical English.

## Start here

1. Read `AGENTS.md` for generic agent rules.
2. Read `docs/AGENT-COMPATIBILITY.md` for supported harness behavior.
3. For OSCAL and SSP work, read `agent-skills/oscal-document-engineering/SKILL.md`.
4. Use command markdown in `commands/` and `plugins/**/commands/` as procedure docs.

## Running workflows

When a command doc shows a Claude slash command, map it to the related script or steps.
For example, workspace validation maps to `trestle validate` or the `/compliance-trestle:workspace-validate` command runbook.

## Legacy SSP to OSCAL prompt template

```text
Use this repository's portable OSCAL document engineering skill. Convert <source-file> into a traceable OSCAL SSP workspace. Preserve source references for every mapped field, mark uncertain content as needs_review, validate with Compliance Trestle and OSCAL CLI if available, and produce import-summary.md, validation-report.json, and unmapped-items.md.
```

## Safety rules

- Never invent compliance facts.
- Never commit real customer evidence.
- Never treat validation as authorization.
- Schema-valid OSCAL does not prove compliance effectiveness.
- Prefer repeatable shell scripts and source maps.
- Do not do one-off prose transformations when a script exists.
- Use Python 3.10-3.12 with Compliance Trestle. Python 3.14+ prints an expected Pydantic V1 warning on every trestle command.

## Validation commands

```bash
npm test
```
