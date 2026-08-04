---
name: Build Trestle Workspace
description: Start a Compliance Trestle workspace for OSCAL authoring and validation.
---

# /oscal-document-workbench:build-trestle-workspace

Start a Compliance Trestle workspace for OSCAL authoring and validation.

## How to run

```bash
bash plugins/document-transform/oscal-document-workbench/scripts/bootstrap-trestle-workspace.sh <workspace> [--profile <name>] [--oscal-version <version>] [--overwrite]
```

## Arguments

- `<workspace>` : import workspace that will contain `trestle-workspace/` and `reports/`
- `--profile <name>` : optional baseline or profile label such as `fedramp-moderate`
- `--oscal-version <version>` : optional OSCAL version note. Defaults to the installed Trestle OSCAL version when available.
- `--overwrite` : replace an existing generated `trestle-workspace/`

## Outputs

- `trestle-workspace/`
- `reports/import-summary.md`
- `reports/unmapped-items.md`

## Exit codes

- `0` : success
- `2` : bad arguments or unsafe overwrite attempt
- `3` : `trestle init` failed

## Safety notes

- Keep source files unchanged.
- Maintain source traceability for every mapped OSCAL field.
- Mark uncertain mappings as `needs_review`.
- Do not treat structural validation as an audit opinion.
- Do not commit sensitive customer evidence or real SSPs.
