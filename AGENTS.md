# Agent Instructions for Compliance Trestle

This repository is an agent-portable Compliance Trestle and OSCAL engineering toolkit. Claude Code plugins are one distribution format, but the canonical capabilities live in root `commands/`, root `skills/`, `agents/`, `hooks/`, `plugins/document-transform/`, `agent-skills/`, `docs/`, and `tests/` so coding agents can use them directly.

## What this repo does

Use this repo to help teams:

- convert legacy SSP, PDF, DOCX, Markdown, and evidence material into OSCAL workflows;
- manage OSCAL with Compliance Trestle and validate output with OSCAL tooling;
- generate SSP, assessment, POA&M, validation, governance, and review artifacts without copying licensed standard text.

## Canonical layout

- `commands/` — canonical Compliance Trestle Claude command runbooks.
- `skills/` — canonical Compliance Trestle skill instructions for this plugin.
- `agents/` — focused role agents for Trestle authoring, validation, review, and governance.
- `plugins/document-transform/` — add-on OSCAL document workbench commands, scripts, templates, and skill.
- `agent-skills/` — portable skill packs for non-Claude agent harnesses.
- `docs/` — architecture, compatibility, quickstarts, and implementation plans.
- `tests/` — shell validation checks for portable skills, adapters, and workbench scripts.

## Agent safety rules

- Do not invent compliance facts, control implementation details, system boundaries, or authorization conclusions.
- Preserve source traceability when transforming legacy documents into OSCAL.
- Mark uncertain mappings as `needs_review` and list what evidence is missing.
- Do not paste licensed framework text into repo files. Use control IDs and original guidance only.
- Treat OSCAL validation as structural validation, not an audit opinion.
- Do not commit real customer SSPs, diagrams, credentials, or sensitive evidence.

## Legacy SSP/PDF/DOCX to OSCAL workflow

When a user asks to convert an old document into OSCAL:

1. Create a workspace under `workspaces/<system>-ssp-import/` or another user-approved path.
2. Copy source documents into `input/` without modifying originals.
3. Extract source text to Markdown and create a source traceability map.
4. Initialize or reuse a Compliance Trestle workspace.
5. Map extracted content to OSCAL SSP metadata, system characteristics, control implementations, roles, parties, inventory, diagrams, and back matter.
6. Keep every mapped OSCAL field tied to a source reference or user-supplied assertion.
7. Validate with Compliance Trestle and OSCAL CLI where available.
8. Produce an import summary, validation report, and unmapped/needs-review report.

The portable skill `agent-skills/oscal-document-engineering/SKILL.md` contains the detailed procedure.

## Useful commands

Run these from the repository root:

```bash
npm run test:agent-skills
npm run test:agent-adapters
npm run test:oscal-document-workbench
npm run test:draft-ssp
npm run test:trestle-integration
npm run test:oscal-review-workflow
```

Validate JSON manually:

```bash
node -e "JSON.parse(require('fs').readFileSync('agent-skills/manifest.json','utf8')); console.log('agent skills manifest ok')"
node -e "JSON.parse(require('fs').readFileSync('.claude-plugin/marketplace.json','utf8')); console.log('marketplace ok')"
```

Check shell scripts:

```bash
bash -n tests/validate-agent-skills.sh
bash -n tests/validate-agent-adapters.sh
```

## How to use portable skills

If your agent supports local skills, copy or point it at subdirectories in `agent-skills/`. If it does not, read the relevant `SKILL.md` and linked `references/` files before acting. Each portable skill is designed to work without Claude slash commands.

## Claude plugin commands vs direct scripts

Claude Code users may run slash commands from the root plugin command set. Other agents should read command markdown under `commands/` and `plugins/**/commands/`, then run the underlying script or equivalent Trestle command when a script exists.

## Development expectations

- Keep changes small and testable.
- Add validation scripts when adding new package formats or manifests.
- Update `docs/AGENT-COMPATIBILITY.md` when adding or changing an agent harness.
- Prefer additive compatibility changes; do not break existing Claude Code installs.
