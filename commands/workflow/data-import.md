---
description: Guided workflow to import data into a trestle workspace with trestle import or trestle tasks
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
user-invocable: true
disable-model-invocation: true
argument-hint: "<file_or_url> [--type catalog|profile|component-definition|ssp]"
---

Run a guided data import workflow.
This workflow handles native OSCAL imports.
It also handles external-format conversions.

## Steps

1. Check that you are in a trestle workspace. Look for a `.trestle/` directory.

2. Read $ARGUMENTS for the source file path or URL and the optional `--type` flag.
   If they are missing, ask the user:
   - What file or URL to import from
   - What model type it is (or let the tool detect it)

3. **Detect format**: examine the source to set the import path:

   **Path A: native OSCAL** (JSON or YAML with OSCAL top-level keys such as `catalog`, `profile`, `component-definition`, or `system-security-plan`):
   - For URLs: fetch the file and save it to a temp location.
   - Detect the model type from the file content if `--type` was not specified.

   **Path B: external format** (requires conversion with `trestle task`):
   - `.csv` to `csv-to-oscal-cd`
   - `.xlsx` / `.xls`: check content for CIS benchmark indicators:
     - CIS benchmark to `cis-xlsx-to-oscal-cd` or `cis-xlsx-to-oscal-catalog`
     - General XLSX to `xlsx-to-oscal-cd` or `xlsx-to-oscal-profile`
   - `.xml`: check for an XCCDF namespace:
     - XCCDF results to `xccdf-result-to-oscal-ar`
   - `.json` (non-OSCAL): check for Tanium format:
     - Tanium results to `tanium-result-to-oscal-ar`

   If the format is ambiguous, ask the user which path to follow.

4. **Check source data**:
   - For OSCAL files: show the model type, title, and key metadata.
   - For CSV: read headers and the first few rows. Show column names.
   - For XLSX: list sheet names and preview the data.
   - For XML: show the root element and namespace to confirm XCCDF.
   - For Tanium JSON: show the top-level structure.

5. **Show import preview**:
   - Show the detected format and import method.
   - Show where the output will go, such as `catalogs/<name>/catalog.json`.
   - Ask the user to confirm before you continue.

6. **Import or convert**:

   **Path A: native OSCAL import**:
   ```
   trestle import -f <source_file> -o <model_name>
   ```

   **Path B: external format conversion**:
   - Read `.trestle/config.ini`. Update an existing `[task.<name>]` section, or make a new one.
   - Set required keys based on the detected task (input path, output directory, title, version).
   - For CSV tasks, help map CSV columns to OSCAL fields.
   - Show the proposed config and confirm before writing.
   - Run:
     ```
     trestle task <task_name>
     ```

7. **Post-import validation**: validate the result:
   ```
   trestle validate -t <model_type> -n <model_name>
   ```
   Or for task output:
   ```
   trestle validate -f <output_file>
   ```

8. **Report results**:
   - Show the output model location in the workspace.
   - Show validation results.
   - Suggest next steps:
     - For catalogs: "Use `/compliance-trestle:catalog-roundtrip` to begin editing"
     - For profiles: "Use `/compliance-trestle:profile-roundtrip` to customize control selections"
     - For component-definitions: "Use `/compliance-trestle:component-roundtrip` to edit component controls"
     - For SSPs: "Use `/compliance-trestle:ssp-roundtrip` to author implementation responses"
     - For assessment results: suggest reviewing findings

## Notes

- **Path A** uses `trestle import`. It supports JSON and YAML OSCAL files.
- **Path B** uses `trestle task`. It supports CSV, XLSX, XML (XCCDF), and Tanium JSON.
- The model name comes from the source filename by default.
- If a model with the same name already exists, warn the user and ask whether to overwrite.
- Config.ini settings for import and conversion tasks can be saved to `.trestle/config.ini` for reuse.
