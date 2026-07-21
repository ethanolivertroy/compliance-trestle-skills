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

Or use the repo wrapper for consistent reports:

```bash
bash scripts/trestle-workflow.sh validate <workspace>
```

For a single model:

```bash
trestle validate -t <type> -n <name>
```

## Output

- Capture validation output in `reports/` when working inside an import workspace.
- If Trestle is missing, write a skipped/missing-tool status instead of implying success.
- Explain schema, reference, and markdown-authoring failures separately when possible.

## Follow-up

After successful assembly, import, merge, create, or split operations, run validation before reporting the workspace as ready.
