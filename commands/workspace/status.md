---
description: Show the status of this Trestle workspace
allowed-tools: Bash, Read, Glob, Grep
user-invocable: true
argument-hint: ""
---

Show the status of the Compliance Trestle workspace.

## Steps

1. Check if the working directory or any parent contains a `.trestle/` directory.
   If not, tell the user they are not in a trestle workspace.

2. List all OSCAL models in the workspace. Scan each model directory:
   - `catalogs/`: list catalog names
   - `profiles/`: list profile names
   - `component-definitions/`: list component definition names
   - `system-security-plans/`: list SSP names
   - `assessment-plans/`: list assessment plan names
   - `assessment-results/`: list assessment result names
   - `plan-of-action-and-milestones/`: list POA&M names

3. For each model found, show:
   - Model name
   - If the model is split (check for subdirectories)
   - If an assembled version exists in `dist/`

4. Check for any markdown authoring directories (output of generate commands).

5. **Check configured tasks**: read `.trestle/config.ini` for `[task.*]` sections and report:
   - Task name (from the section header, such as `[task.csv-to-oscal-cd]`)
   - Input path (from `input-dir`, `input-file`, or `csv-file` keys)
   - Output path (from `output-dir` key)
   - If the output directory exists and contains generated files

6. Show the trestle version: `trestle version`

7. Show a summary table of workspace contents.
