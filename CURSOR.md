# Cursor Instructions

This repository includes native Cursor support.
It includes project rules, skills in `.cursor/skills/`, and the same portable Compliance Trestle playbooks that other agent harnesses use.

Open this repository in Cursor.
Start with this file and `AGENTS.md`.

Write project documentation in ASD-STE100 Simplified Technical English.

## Native Cursor features

| Feature | Location | Purpose |
| --- | --- | --- |
| Always-on rules | `.cursor/rules/compliance-trestle.mdc` | Repository safety rules and skill routing |
| Workspace guardrails | `.cursor/rules/oscal-workspace-guardrails.mdc` | Traceability and evidence handling in import workspaces |
| OSCAL edit guidance | `.cursor/rules/oscal-json-edit.mdc` | Prefer markdown roundtrip. Do not edit OSCAL JSON first. |
| Project skills | `.cursor/skills/` | Slash skills and auto-discovered workflows |
| Primary playbooks | `agent-skills/` | Source of truth for portable skill content |

## Invoke skills in Cursor

Type `/` in Agent chat and choose a skill.
You can also `@`-attach a skill as context.

| Skill | Invocation | When to use |
| --- | --- | --- |
| `oscal-document-engineering` | `/oscal-document-engineering` | Legacy SSP, PDF, DOCX, or Markdown to OSCAL |
| `compliance-trestle-engineering` | `/compliance-trestle-engineering` | Trestle workspace lifecycle and validation |
| `import-legacy-ssp` | `/import-legacy-ssp` | Full legacy SSP import |
| `validate-oscal-package` | `/validate-oscal-package` | Validate an OSCAL package or workspace |
| `review-oscal-mappings` | `/review-oscal-mappings` | Human review of source-to-OSCAL mappings |
| `workspace-validate` | `/workspace-validate` | Run Trestle validation on the current workspace |

Workflow skills with explicit invocation use `disable-model-invocation: true`.
These skills operate like slash commands.

## Key paths

- `AGENTS.md` : primary agent instructions for all harnesses
- `agent-skills/` : portable skill source of truth
- `commands/` : Compliance Trestle command runbooks
- `plugins/document-transform/oscal-document-workbench/` : legacy document workbench scripts and command docs
- `agents/` : role playbooks such as SSP author, validation assistant, and POA&M manager
- `docs/AGENT-COMPATIBILITY.md` : harness comparison matrix
- `docs/OSCAL-DOCUMENT-WORKBENCH.md` : legacy SSP import architecture
- `examples/legacy-ssp-to-oscal/` : synthetic demo workspace

## Claude slash commands in Cursor

Cursor does not install the Claude Code marketplace plugin.
Treat slash commands as runbook names.
Do the related steps in the terminal.

| Claude command | Cursor runbook | Typical shell step |
| --- | --- | --- |
| `/compliance-trestle:workspace-init` | `commands/workspace/init.md` | `trestle init` or `bash scripts/trestle-workflow.sh init <workspace>` |
| `/compliance-trestle:workspace-validate` | `commands/workspace/validate.md` | `trestle validate -a` |
| `/compliance-trestle:workflow-ssp-roundtrip` | `commands/workflow/ssp-roundtrip.md` | `trestle author ssp-generate` then `trestle author ssp-assemble` |
| `/oscal-document-workbench:ingest-ssp` | `plugins/document-transform/oscal-document-workbench/commands/ingest-ssp.md` | extract, bootstrap, and validate script pipeline |
| `/oscal-document-workbench:extract-legacy-doc` | `plugins/document-transform/oscal-document-workbench/commands/extract-legacy-doc.md` | `bash plugins/document-transform/oscal-document-workbench/scripts/extract-legacy-doc.sh` |
| `/oscal-document-workbench:validate-oscal-package` | `plugins/document-transform/oscal-document-workbench/commands/validate-oscal-package.md` | `bash plugins/document-transform/oscal-document-workbench/scripts/validate-oscal-package.sh` |

When a runbook refers to `${CLAUDE_PLUGIN_ROOT}`, use the repository path.

## Legacy SSP to OSCAL quick path

1. Read `agent-skills/oscal-document-engineering/SKILL.md`.
2. Run `/import-legacy-ssp` or do the steps in `plugins/document-transform/oscal-document-workbench/commands/ingest-ssp.md`.
3. Keep source traceability in `source-map.csv`.
4. Mark uncertain mappings as `needs_review`.
5. Validate with Trestle.
6. Document missing tools. Do not skip validation with no record.
7. Make an import summary, a validation report, and an unmapped-items report.

Example prompt:

```text
/import-legacy-ssp

Use AGENTS.md and the OSCAL document engineering skill. Import my legacy SSP into a workspace under workspaces/<system>-ssp-import/. Preserve source references for every mapped field, mark uncertain content as needs_review, and run validation.
```

## Role routing

| User intent | Start with |
| --- | --- |
| Write SSP control responses | `agents/ssp-author.md` and `commands/workflow/ssp-roundtrip.md` |
| Find compliance gaps | `agents/compliance-reviewer.md` and `/workspace-validate` |
| Repair validation errors | `agents/validation-assistant.md` and `skills/trestle-validation/SKILL.md` |
| Import CSV, XCCDF, or Tanium data | `agents/data-importer.md` and `commands/workflow/data-import.md` |
| Manage POA&M items | `agents/poam-manager.md` and `commands/workflow/poam-roundtrip.md` |
| Review assessment coverage | `agents/assessment-reviewer.md` |

## Required guardrails

- Use Python 3.10-3.12 with Compliance Trestle. Python 3.14+ prints an expected Pydantic V1 warning on every trestle command.
- Preserve source traceability for legacy document conversion.
- Do not treat missing system details as facts. Mark them `needs_review`.
- Do not copy licensed framework text.
- Validate generated OSCAL structurally before you claim success.
- Do not commit real customer SSPs, credentials, or sensitive evidence.
- Schema-valid OSCAL does not prove compliance effectiveness or authorization.

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

If `compliance-trestle` or `trestle` is missing, report the install path (`pip install compliance-trestle`).
Write a skipped or missing-tool status.
Do not claim that validation passed.

## Differences from Claude Code

- Cursor does not include a native Claude marketplace plugin or `hooks.json` lifecycle.
- Use `.cursor/rules/` and `.cursor/skills/` for guardrails and reminders.
- After `trestle assemble`, `trestle import`, `trestle merge`, `trestle create`, or `trestle split`, run or recommend validation.
- Prefer markdown authoring roundtrips for catalogs, profiles, component definitions, and SSPs.
- Do not edit JSON first when a roundtrip is available.
