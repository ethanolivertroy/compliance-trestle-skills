---
name: validate-oscal-package
description: Validate an OSCAL package or Compliance Trestle workspace and produce a validation report, failing loudly when required tools are missing.
disable-model-invocation: true
---

# Validate OSCAL Package

Validate an OSCAL package or Trestle workspace from Cursor.

## Read first

- `plugins/document-transform/oscal-document-workbench/commands/validate-oscal-package.md`
- `agent-skills/oscal-document-engineering/references/oscal-validation.md`
- `commands/workspace/validate.md`

## Run

```bash
bash plugins/document-transform/oscal-document-workbench/scripts/validate-oscal-package.sh <path> --output <workspace>/reports/validation-report.json
```

For a Trestle workspace without the workbench wrapper:

```bash
trestle validate -a
```

Or use the repo helper:

```bash
bash scripts/trestle-workflow.sh validate <workspace>
```

## Report requirements

- Record validator output or a documented skipped/missing-tool status.
- Do not claim validation passed if Trestle or OSCAL CLI was unavailable unless the user accepted partial validation.
- Distinguish structural validation from compliance effectiveness or authorization.

## After assemble/import/merge/create/split

If the user recently ran `trestle assemble`, `trestle import`, `trestle merge`, `trestle create`, or `trestle split`, recommend targeted validation such as:

```bash
trestle validate -t <type> -n <name>
```
