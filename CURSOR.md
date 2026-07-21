# Cursor Instructions

This repository includes native Cursor support: project rules, discoverable skills under `.cursor/skills/`, and the same portable Compliance Trestle playbooks used by other agent harnesses.

Open this repo in Cursor and start with this file plus `AGENTS.md`.

## Native Cursor features

| Feature | Location | Purpose |
| --- | --- | --- |
| Always-on rules | `.cursor/rules/compliance-trestle.mdc` | Repository guardrails and skill routing |
| Workspace guardrails | `.cursor/rules/oscal-workspace-guardrails.mdc` | Traceability and evidence handling in import workspaces |
| OSCAL edit guidance | `.cursor/rules/oscal-json-edit.mdc` | Prefer markdown roundtrip over direct JSON edits |
| Project skills | `.cursor/skills/` | Slash-invokable and auto-discovered workflows |
| Canonical playbooks | `agent-skills/` | Source of truth for portable skill content |

## Invoke skills in Cursor

Type `/` in Agent chat and choose a skill, or `@`-attach it as context.

| Skill | Invocation | When to use |
| --- | --- | --- |
| `oscal-document-engineering` | `/oscal-document-engineering` | Legacy SSP/PDF/DOCX/Markdown to OSCAL |
| `compliance-trestle-engineering` | `/compliance-trestle-engineering` | Trestle workspace lifecycle and validation |
| `import-legacy-ssp` | `/import-legacy-ssp` | End-to-end legacy SSP import |
| `validate-oscal-package` | `/validate-oscal-package` | Validate an OSCAL package or workspace |
| `review-oscal-mappings` | `/review-oscal-mappings` | Human review of source-to-OSCAL mappings |
| `workspace-validate` | `/workspace-validate` | Run Trestle validation on the current workspace |

Workflow skills with explicit invocation use `disable-model-invocation: true` so they behave like slash commands.

## Key paths

- `AGENTS.md` — canonical agent instructions for all harnesses
- `agent-skills/` — portable skill source of truth
- `commands/` — Compliance Trestle command runbooks (Claude slash-command equivalents)
- `plugins/document-transform/oscal-document-workbench/` — legacy document workbench scripts and command docs
- `agents/` — role playbooks (SSP author, validation assistant, POA&M manager, and others)
- `docs/AGENT-COMPATIBILITY.md` — harness comparison matrix
- `docs/OSCAL-DOCUMENT-WORKBENCH.md` — legacy SSP import architecture
- `examples/legacy-ssp-to-oscal/` — synthetic demo workspace

## Claude slash commands in Cursor

Cursor does not install the Claude Code marketplace plugin. Treat slash commands as runbook names and execute the underlying steps in the terminal.

| Claude command | Cursor runbook | Typical shell step |
| --- | --- | --- |
| `/compliance-trestle:workspace-init` | `commands/workspace/init.md` | `trestle init` or `bash scripts/trestle-workflow.sh init <workspace>` |
| `/compliance-trestle:workspace-validate` | `commands/workspace/validate.md` | `trestle validate -a` |
| `/compliance-trestle:workflow-ssp-roundtrip` | `commands/workflow/ssp-roundtrip.md` | `trestle author ssp-generate` then `trestle author ssp-assemble` |
| `/oscal-document-workbench:ingest-ssp` | `plugins/document-transform/oscal-document-workbench/commands/ingest-ssp.md` | extract, bootstrap, validate script pipeline |
| `/oscal-document-workbench:extract-legacy-doc` | `plugins/document-transform/oscal-document-workbench/commands/extract-legacy-doc.md` | `bash plugins/document-transform/oscal-document-workbench/scripts/extract-legacy-doc.sh` |
| `/oscal-document-workbench:validate-oscal-package` | `plugins/document-transform/oscal-document-workbench/commands/validate-oscal-package.md` | `bash plugins/document-transform/oscal-document-workbench/scripts/validate-oscal-package.sh` |

When a runbook references `${CLAUDE_PLUGIN_ROOT}`, substitute the repo path instead.

## Legacy SSP to OSCAL quick path

1. Read `agent-skills/oscal-document-engineering/SKILL.md`.
2. Run `/import-legacy-ssp` or follow `plugins/document-transform/oscal-document-workbench/commands/ingest-ssp.md`.
3. Keep source traceability in `source-map.csv`.
4. Mark uncertain mappings as `needs_review`.
5. Validate with Trestle and document missing tools instead of skipping silently.
6. Produce import summary, validation report, and unmapped-items report.

Example prompt:

```text
/import-legacy-ssp

Use AGENTS.md and the OSCAL document engineering skill. Import my legacy SSP into a workspace under workspaces/<system>-ssp-import/. Preserve source references for every mapped field, mark uncertain content as needs_review, and run validation.
```

## Role routing

| User intent | Start with |
| --- | --- |
| Write SSP control responses | `agents/ssp-author.md` + `commands/workflow/ssp-roundtrip.md` |
| Find compliance gaps | `agents/compliance-reviewer.md` + `/workspace-validate` |
| Fix validation errors | `agents/validation-assistant.md` + `skills/trestle-validation/SKILL.md` |
| Import CSV/XCCDF/Tanium data | `agents/data-importer.md` + `commands/workflow/data-import.md` |
| Manage POA&M items | `agents/poam-manager.md` + `commands/workflow/poam-roundtrip.md` |
| Review assessment coverage | `agents/assessment-reviewer.md` |

## Required guardrails

- Preserve source traceability for legacy document conversion.
- Do not infer missing system details as facts. Mark them `needs_review`.
- Do not copy licensed framework text.
- Validate generated OSCAL structurally before claiming success.
- Do not commit real customer SSPs, credentials, or sensitive evidence.
- Schema-valid OSCAL does not prove compliance effectiveness or authorization.

## Validation commands

```bash
npm run test:agent-skills
npm run test:agent-adapters
npm run test:cursor-support
npm run test:oscal-document-workbench
npm run test:trestle-integration
npm run test:oscal-review-workflow
```

If `compliance-trestle` or `trestle` is missing, report the install path (`pip install compliance-trestle`) and write a skipped/missing-tool status instead of claiming validation passed.

## Differences from Claude Code

- No native Claude marketplace plugin or `hooks.json` lifecycle in Cursor.
- Use `.cursor/rules/` and `.cursor/skills/` instead of Claude hooks for guardrails and reminders.
- After `trestle assemble`, `trestle import`, `trestle merge`, `trestle create`, or `trestle split`, run or recommend validation explicitly.
- Prefer markdown authoring roundtrips for catalogs, profiles, component definitions, and SSPs instead of direct JSON edits.
