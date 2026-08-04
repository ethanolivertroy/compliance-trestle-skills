---
description: List all available trestle data conversion tasks
allowed-tools: Bash
user-invocable: true
argument-hint: ""
---

List all available trestle tasks for converting data formats to OSCAL and from OSCAL.

## Steps

1. Run the task list command:
   ```
   trestle task -l
   ```

2. Show the results grouped by conversion direction:

   **Into OSCAL:**
   - `csv-to-oscal-cd`: CSV to Component Definition
   - `xlsx-to-oscal-cd`: XLSX to Component Definition
   - `xlsx-to-oscal-profile`: XLSX to Profile
   - `xccdf-result-to-oscal-ar`: XCCDF scan results to Assessment Results
   - `tanium-result-to-oscal-ar`: Tanium results to Assessment Results
   - `cis-xlsx-to-oscal-catalog`: CIS benchmark XLSX to Catalog
   - `cis-xlsx-to-oscal-cd`: CIS benchmark XLSX to Component Definition
   - `ocp4-cis-profile-to-oscal-catalog`: OCP4 CIS profile to Catalog
   - `ocp4-cis-profile-to-oscal-cd`: OCP4 CIS profile to Component Definition

   **From OSCAL:**
   - `oscal-catalog-to-csv`: Catalog to CSV
   - `oscal-profile-to-osco-profile`: Profile to OSCO YAML

3. Tell the user that task config goes in `.trestle/config.ini` under `[task.<task_name>]` sections.
   Use `trestle task <name> -i` to see the required config for a specific task.
