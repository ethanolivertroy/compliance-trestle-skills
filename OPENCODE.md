# OpenCode Instructions

OpenCode can use this repository as a local Compliance Trestle/OSCAL engineering workspace. The Claude Code plugin files are still useful, but OpenCode should treat them as markdown command specs and direct scripts rather than native slash commands.

## Start here

1. Read `AGENTS.md` for generic agent rules.
2. Read `docs/AGENT-COMPATIBILITY.md` for supported harness behavior.
3. For OSCAL/SSP work, read `agent-skills/oscal-document-engineering/SKILL.md`.
4. Use command markdown in `commands/` and `plugins/**/commands/` as runnable procedure docs.

## Running workflows

When a command doc shows a Claude slash command, map it to the underlying script or steps. For example, workspace validation maps to `trestle validate` or the `/compliance-trestle:workspace-validate` command runbook.

## Legacy SSP to OSCAL prompt template

```text
Use this repository's portable OSCAL document engineering skill. Convert <source-file> into a traceable OSCAL SSP workspace. Preserve source references for every mapped field, mark uncertain content as needs_review, validate with Compliance Trestle and OSCAL CLI if available, and produce import-summary.md, validation-report.json, and unmapped-items.md.
```

## Safety rules

- Never invent compliance facts.
- Never commit real customer evidence.
- Never treat validation as authorization.
- Prefer repeatable shell scripts and source maps over one-off prose transformations.
