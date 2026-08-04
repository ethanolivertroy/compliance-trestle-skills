---
name: workspace-validate
description: Validate the current Compliance Trestle workspace with trestle validate, report failures clearly, and recommend fixes using the validation assistant workflow.
disable-model-invocation: true
---

# Workspace Validate

Run Compliance Trestle validation from Cursor.

## Read first

- `commands/workspace/validate.md`
- `agents/validation-assistant.md`
- `skills/trestle-validation/SKILL.md`

## Run

From the workspace root that contains `.trestle/`:

```bash
trestle validate -a
```

Or use the repository wrapper for consistent reports:

```bash
bash scripts/trestle-workflow.sh validate <workspace>
```

For one model:

```bash
trestle validate -t <type> -n <name>
```

## Output

- Capture validation output in `reports/` when you work inside an import workspace.
- If Trestle is missing, write a skipped or missing-tool status.
- Do not imply success when the tool is missing.
- Explain schema, reference, and markdown-authoring failures separately when possible.

## Follow-up

After successful assembly, import, merge, create, or split operations, run validation before you report the workspace as ready.
