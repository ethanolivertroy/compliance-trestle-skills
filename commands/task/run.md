---
description: Run a trestle data conversion task (CSV/XLSX/XCCDF to OSCAL)
allowed-tools: Bash, Read, Glob, Grep
user-invocable: true
argument-hint: "<task_name> [-c config.ini]"
---

Run a trestle task to convert external data formats into OSCAL documents.

## Steps

1. Check that you are in a trestle workspace. Look for a `.trestle/` directory.

2. Read $ARGUMENTS for:
   - `task_name`: the task to run, such as `csv-to-oscal-cd` or `xccdf-result-to-oscal-ar`
   - `-c` / `--config` (optional): path to the config file (default: `.trestle/config.ini`)

3. Check that the task name is valid. Known tasks are:
   - `csv-to-oscal-cd`: CSV to Component Definition
   - `xlsx-to-oscal-cd`: XLSX to Component Definition
   - `xlsx-to-oscal-profile`: XLSX to Profile
   - `xccdf-result-to-oscal-ar`: XCCDF scan results to Assessment Results
   - `tanium-result-to-oscal-ar`: Tanium results to Assessment Results
   - `oscal-catalog-to-csv`: Catalog to CSV
   - `oscal-profile-to-osco-profile`: Profile to OSCO YAML
   - `cis-xlsx-to-oscal-catalog`: CIS benchmark XLSX to Catalog
   - `cis-xlsx-to-oscal-cd`: CIS benchmark XLSX to Component Definition
   - `ocp4-cis-profile-to-oscal-catalog`: OCP4 CIS profile to Catalog
   - `ocp4-cis-profile-to-oscal-cd`: OCP4 CIS profile to Component Definition

4. Read the config file. Check for a `[task.<task_name>]` section.
   Show the user the config.
   If no config section exists, tell the user to add one.

5. Run the task:
   ```
   trestle task <task_name> -c <config_file>
   ```

6. Check the output directory from the config for the generated OSCAL file or files.

7. Suggest validation of the output:
   ```
   trestle validate -f <output_file>
   ```
