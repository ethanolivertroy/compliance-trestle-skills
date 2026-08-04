# Agent Instructions for Compliance Trestle

This repository is an agent-portable Compliance Trestle and OSCAL engineering toolkit.
Claude Code plugins are one distribution format.
The primary functions are in these directories:

- `commands/`
- `skills/`
- `agents/`
- `hooks/`
- `plugins/document-transform/`
- `agent-skills/`
- `docs/`
- `tests/`

Coding agents can use these directories directly.

Write project documentation in ASD-STE100 Simplified Technical English.
Use short sentences.
Use the same word for the same meaning.
Keep technical names such as OSCAL, Compliance Trestle, SSP, and FedRAMP.

## Purpose of this repository

Use this repository to help teams do these tasks:

- Convert legacy SSP, PDF, DOCX, Markdown, and evidence material into OSCAL workflows.
- Manage OSCAL with Compliance Trestle.
- Validate output with OSCAL tools.
- Make SSP, assessment, POA&M, validation, governance, and review artifacts.
- Do not copy licensed standard text.

## Primary directory layout

- `commands/` : primary Compliance Trestle Claude command runbooks.
- `skills/` : primary Compliance Trestle skill instructions for this plugin.
- `agents/` : role agents for Trestle authoring, validation, review, and governance.
- `plugins/document-transform/` : OSCAL document workbench commands, scripts, templates, and skill.
- `agent-skills/` : portable skill packs for non-Claude agent harnesses.
- `docs/` : architecture, compatibility, quick starts, and implementation plans.
- `tests/` : shell validation checks for portable skills, adapters, and workbench scripts.

## Agent safety rules

- Do not invent compliance facts, control implementation details, system boundaries, or authorization conclusions.
- Preserve source traceability when you convert legacy documents into OSCAL.
- Mark uncertain mappings as `needs_review`.
- List the missing evidence.
- Do not paste licensed framework text into repository files.
- Use control IDs and original guidance only.
- Treat OSCAL validation as structural validation.
- Do not treat OSCAL validation as an audit opinion.
- Do not commit real customer SSPs, diagrams, credentials, or sensitive evidence.

## Legacy SSP, PDF, and DOCX to OSCAL workflow

When a user asks you to convert an old document into OSCAL, do these steps:

1. Make a workspace in `workspaces/<system>-ssp-import/` or in another path that the user approves.
2. Copy source documents into `input/`.
3. Do not change the original files.
4. Extract source text to Markdown.
5. Make a source traceability map.
6. Start or reuse a Compliance Trestle workspace.
7. Map extracted content to OSCAL SSP metadata, system characteristics, control implementations, roles, parties, inventory, diagrams, and back matter.
8. Keep each mapped OSCAL field tied to a source reference or a user-supplied assertion.
9. Validate with Compliance Trestle and OSCAL CLI when those tools are available.
10. Make an import summary, a validation report, and an unmapped or `needs_review` report.

The portable skill `agent-skills/oscal-document-engineering/SKILL.md` contains the detailed procedure.

## Useful commands

Run these commands from the repository root:

```bash
npm run test:agent-skills
npm run test:agent-adapters
npm run test:cursor-support
npm run test:oscal-document-workbench
npm run test:draft-ssp
npm run test:trestle-integration
npm run test:oscal-review-workflow
```

Cursor users must also read `CURSOR.md`.
Use native project skills in `.cursor/skills/`.

Use Python 3.10-3.12 with Compliance Trestle.
Python 3.14+ prints an expected Pydantic V1 warning on every trestle command.

Validate JSON with these commands:

```bash
node -e "JSON.parse(require('fs').readFileSync('agent-skills/manifest.json','utf8')); console.log('agent skills manifest ok')"
node -e "JSON.parse(require('fs').readFileSync('.claude-plugin/marketplace.json','utf8')); console.log('marketplace ok')"
```

Check shell scripts with these commands:

```bash
bash -n tests/validate-agent-skills.sh
bash -n tests/validate-agent-adapters.sh
```

## How to use portable skills

If your agent supports local skills, copy or point it at subdirectories in `agent-skills/`.
If your agent does not support local skills, read the applicable `SKILL.md` file and the linked `references/` files before you act.
Each portable skill can operate without Claude slash commands.

## Claude plugin commands and direct scripts

Claude Code users can run slash commands from the root plugin command set.
Other agents must read command markdown in `commands/` and `plugins/**/commands/`.
Then run the related script or the equivalent Trestle command when a script exists.

## Development rules

- Keep changes small and testable.
- Add validation scripts when you add new package formats or manifests.
- Update `docs/AGENT-COMPATIBILITY.md` when you add or change an agent harness.
- Add compatibility. Do not break existing Claude Code installs.
- Write new and changed documentation in ASD-STE100 Simplified Technical English.
