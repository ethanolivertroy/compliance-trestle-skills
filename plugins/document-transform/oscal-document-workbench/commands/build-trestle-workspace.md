---
name: Build Trestle Workspace
description: Initialize a Compliance Trestle workspace for OSCAL authoring and validation.
---

# /oscal-document-workbench:build-trestle-workspace

Initialize a Compliance Trestle workspace for OSCAL authoring and validation.

## How to run

```bash
bash plugins/document-transform/oscal-document-workbench/scripts/bootstrap-trestle-workspace.sh <workspace> [--profile <name>] [--oscal-version <version>] [--overwrite]
```

## Arguments

- `<input>` — legacy source document path when extraction is required.
- `<workspace>` — working directory for extracted content, Trestle files, reports, and review artifacts.
- `<path>` — OSCAL file or package directory to validate.
- `--output <path>` — output directory or report path depending on the script.
- `--profile <name>` — optional baseline/profile label such as `fedramp-moderate`.
- `--oscal-version <version>` — optional OSCAL version note for generated workspace metadata.
- `--overwrite` — allow replacing an existing generated workspace where supported.

## Outputs

Expected outputs may include:

- `extracted.md`
- `source-map.csv`
- `extract-manifest.json`
- `trestle-workspace/`
- `reports/import-summary.md`
- `reports/validation-report.json`
- `reports/unmapped-items.md`

## Exit codes

- `0` — success
- `2` — bad arguments, unreadable input, or unsafe overwrite attempt
- `3` — validation or transformation failed
- `5` — required external dependency is missing
- `6` — unsupported format or structurally invalid OSCAL

## Safety notes

- Preserve source files unchanged.
- Maintain source traceability for every mapped OSCAL field.
- Mark uncertain mappings as `needs_review`.
- Do not treat structural validation as an audit opinion.
- Do not commit sensitive customer evidence or real SSPs.
