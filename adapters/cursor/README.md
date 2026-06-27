# Cursor Adapter

Native Cursor support for the Compliance Trestle and OSCAL Document Workbench toolkit.

## Install

1. Clone or open this repository in Cursor.
2. Confirm project rules load from `.cursor/rules/`.
3. Open **Customize → Skills** and verify project skills under `.cursor/skills/`.
4. Read `CURSOR.md` before starting OSCAL or Trestle work.

No marketplace install is required.

## What Cursor gets natively

- `CURSOR.md` — Cursor-specific entry point and slash-command mapping
- `.cursor/rules/` — always-on and file-scoped guardrails
- `.cursor/skills/` — discoverable project skills, including explicit workflow commands
- Shared portable content in `agent-skills/`, `commands/`, and workbench scripts

## Recommended first run

Try the synthetic demo:

```bash
bash examples/legacy-ssp-to-oscal/scripts/run-example.sh
npm run test:cursor-support
```

In Agent chat:

```text
/import-legacy-ssp

Walk through examples/legacy-ssp-to-oscal/ and explain the source traceability workflow.
```

## Workflow skills

| Skill | Purpose |
| --- | --- |
| `/oscal-document-engineering` | Legacy document to OSCAL engineering playbook |
| `/compliance-trestle-engineering` | Trestle workspace operations |
| `/import-legacy-ssp` | End-to-end legacy SSP import |
| `/validate-oscal-package` | Package/workspace validation |
| `/review-oscal-mappings` | Mapping review queue workflow |
| `/workspace-validate` | Trestle workspace validation |

## Limitations

- Claude Code slash commands are runbooks, not native Cursor commands.
- Claude session hooks do not run in Cursor; equivalent behavior lives in rules and skills.
- Context loading depends on which files are open and which skills/rules match.

## Related docs

- `CURSOR.md`
- `docs/AGENT-COMPATIBILITY.md`
- `docs/OSCAL-DOCUMENT-WORKBENCH.md`
- `docs/tutorials/legacy-ssp-to-oscal-with-agent.md`
