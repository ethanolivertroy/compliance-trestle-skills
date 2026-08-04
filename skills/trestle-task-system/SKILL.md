---
name: trestle-task-system
description: >-
  Use this skill for the Compliance Trestle task system for data conversion and transformation.
  Use it for CSV import, XLSX import, XCCDF results, Tanium results, and CIS benchmarks.
  Use it for config.ini task configuration, trestle tasks, or conversion of scan results to assessment results.
allowed-tools: Bash, Read, Glob, Grep, Write, Edit
---

# Trestle Task System

The trestle task system converts external data formats into OSCAL documents.
It also converts OSCAL documents into external formats.
Supported formats include CSV, XLSX, XCCDF, Tanium, and CIS benchmarks.
Configure tasks in `config.ini` sections.
Run a task with `trestle task <name>`.

## Available Tasks

### Into OSCAL

| Task Name | Input Format | Output OSCAL Type |
|-----------|-------------|-------------------|
| `csv-to-oscal-cd` | CSV | Component Definition |
| `xlsx-to-oscal-cd` | XLSX | Component Definition |
| `xlsx-to-oscal-profile` | XLSX | Profile |
| `xccdf-result-to-oscal-ar` | XCCDF XML results | Assessment Results |
| `tanium-result-to-oscal-ar` | Tanium JSON results | Assessment Results |
| `cis-xlsx-to-oscal-catalog` | CIS benchmark XLSX | Catalog |
| `cis-xlsx-to-oscal-cd` | CIS benchmark XLSX | Component Definition |
| `ocp4-cis-profile-to-oscal-catalog` | OCP4 CIS profile YAML | Catalog |
| `ocp4-cis-profile-to-oscal-cd` | OCP4 CIS profile YAML | Component Definition |

### From OSCAL

| Task Name | Input OSCAL Type | Output Format |
|-----------|-----------------|---------------|
| `oscal-catalog-to-csv` | Catalog | CSV |
| `oscal-profile-to-osco-profile` | Profile | OSCO YAML |

## Configuration Format

Configure tasks in `.trestle/config.ini` with INI-style sections:

```ini
[task.csv-to-oscal-cd]
title = My Component Definition
version = 1.0
csv-file = data/controls.csv
output-dir = component-definitions/my-component
output-overwrite = true
```

The section name follows the pattern `[task.<task-name>]`.

## Task-Specific Configuration

### csv-to-oscal-cd

This task is used often.
It converts a CSV file with control mappings into an OSCAL Component Definition.

**Required keys:**
- `title`: Component definition title
- `version`: Component definition version
- `csv-file`: Path to the CSV file
- `output-dir`: Output directory for the generated OSCAL JSON

**Optional keys:**
- `component-definition`: Path to an existing component-definition to merge with
- `class.column-name`: Class to associate with a CSV column name
- `output-overwrite`: `true` (default) or `false`
- `validate-controls`: `on`, `warn`, or `off` (default)

**CSV Column Mapping:**
The CSV file must contain columns that map to OSCAL control implementation fields.
The task reads column headers and maps them to the component definition structure.
Common columns include: Rule_Id, Rule_Description, Component_Title, Control_Id_List, Parameter_Id, Parameter_Value.

### xccdf-result-to-oscal-ar

This task converts XCCDF scan results into OSCAL Assessment Results.
OpenSCAP is one source of XCCDF results.

**Required keys:**
- `input-dir`: Directory containing XCCDF result XML files
- `output-dir`: Output directory

**Optional keys:**
- `checking`: `true`/`false` (default: `false`)
- `output-overwrite`: `true`/`false` (default: `true`)
- `quiet`: `true`/`false` (default: `false`)
- `title`: Title for the assessment results (default: "XCCDF")
- `description`: Description (default: "XCCDF Scan Results")
- `type`: Assessor type (default: "Validator")
- `timestamp`: ISO 8601 timestamp override

### tanium-result-to-oscal-ar

This task converts Tanium compliance scan results into OSCAL Assessment Results.

**Required keys:**
- `input-dir`: Directory containing Tanium result JSON files
- `output-dir`: Output directory

**Optional keys:**
- `blocksize`: Lines per CPU for parallel processing
- `cpus-max`: Maximum CPUs (default: 1)
- `cpus-min`: Minimum CPUs
- `aggregate`: `true` (default) or `false`
- `caching`: `true` (default) or `false`
- `checking`: `true`/`false` (default: `false`)
- `output-overwrite`: `true`/`false` (default: `true`)
- `quiet`: `true`/`false` (default: `false`)
- `timestamp`: ISO 8601 timestamp override

### oscal-catalog-to-csv

This task exports an OSCAL Catalog to CSV format.

**Required keys:**
- `input-file`: Path to the catalog JSON/YAML file
- `output-dir`: Output directory

**Optional keys:**
- `output-name`: CSV filename
- `output-overwrite`: `true`/`false` (default: `true`)
- `level`: `control` or `statement` (default: `statement`)

### cis-xlsx-to-oscal-cd

This task converts CIS benchmark spreadsheets into OSCAL Component Definitions.

**Required keys:**
- `benchmark-file`: Path to the CIS benchmark .xlsx file
- `benchmark-title`: CIS benchmark title
- `benchmark-version`: Benchmark version
- `component-name`: Component name
- `component-description`: Component description
- `component-type`: Component type
- `namespace`: Namespace for properties
- `output-dir`: Output directory
- `profile-version`: Profile version
- `profile-source`: Profile source
- `profile-description`: Profile description

**Optional keys:**
- `benchmark-control-prefix`: Default: `cisc-`
- `benchmark-rule-prefix`: Default: `CIS-`
- `benchmark-sheet-name`: Default: `Combined Profiles`
- `output-overwrite`: `true`/`false` (default: `true`)

## Running Tasks

```bash
# List available tasks
trestle task -l

# Show config requirements for a task
trestle task csv-to-oscal-cd -i

# Run a task (uses .trestle/config.ini by default)
trestle task csv-to-oscal-cd

# Run with a specific config file
trestle task csv-to-oscal-cd -c my-config.ini
```

## Common Patterns

### Import scan results for continuous monitoring
```ini
[task.xccdf-result-to-oscal-ar]
input-dir = scan-results/latest
output-dir = assessment-results/latest-scan
output-overwrite = true
title = Weekly Compliance Scan
description = Automated XCCDF scan results
```

### Build component definitions from spreadsheets
```ini
[task.csv-to-oscal-cd]
title = Application Controls
version = 1.0
csv-file = data/app-controls.csv
output-dir = component-definitions/my-app
validate-controls = warn
```

### Export catalog for review
```ini
[task.oscal-catalog-to-csv]
input-file = catalogs/nist-800-53/catalog.json
output-dir = exports
output-name = nist-controls.csv
level = control
```

## CSV Column Reference for csv-to-oscal-cd

The `csv-to-oscal-cd` task reads specific column headers from the CSV file to build the component definition.
All column names are case-sensitive.

| Column Header | Required | Description |
|--------------|----------|-------------|
| `Rule_Id` | Yes | Unique identifier for the rule. Example: `rule-ac-1` |
| `Rule_Description` | Yes | Human-readable description of what the rule checks |
| `Component_Title` | Yes | Name of the component this rule belongs to |
| `Component_Type` | No | Component type (default: `Service`). Valid: `Software`, `Hardware`, `Service`, `Policy`, `Process`, `Plan`, `Guidance`, `Standard`, `Validation` |
| `Control_Id_List` | Yes | OSCAL control IDs this rule maps to (comma-separated). Example: `ac-1,ac-2` |
| `Parameter_Id` | No | Parameter identifier for the rule |
| `Parameter_Description` | No | Human-readable description of the parameter |
| `Parameter_Value_Alternatives` | No | Allowed values for the parameter (comma-separated) |
| `Profile_Source` | No | Profile href. Example: `trestle://profiles/my-profile/profile.json` |
| `Profile_Description` | No | Description of the referenced profile |
| `Namespace` | No | Namespace for rule properties. Example: `https://my-org.com/ns/oscal` |
| `Check_Id` | No | Identifier for an automated check. Example: XCCDF check ID |
| `Check_Description` | No | Description of the automated check |

### Example CSV

```csv
Rule_Id,Rule_Description,Component_Title,Component_Type,Control_Id_List,Parameter_Id,Parameter_Value_Alternatives,Profile_Source,Namespace
rule-ac-1,Ensure access control policy exists,My Application,Service,ac-1,,,trestle://profiles/nist-800-53/profile.json,https://my-org.com/ns/oscal
rule-ac-2-a,Validate account types are defined,My Application,Service,ac-2,,,,https://my-org.com/ns/oscal
rule-ac-2-timeout,Check session timeout,My Application,Service,ac-2,ac-2-timeout-param,"15,30,60",trestle://profiles/nist-800-53/profile.json,https://my-org.com/ns/oscal
rule-cm-1,Configuration management policy review,My Application,Service,cm-1,,,trestle://profiles/nist-800-53/profile.json,https://my-org.com/ns/oscal
rule-ia-2,MFA for privileged accounts,Identity Provider,Service,"ia-2,ia-2.1",,,trestle://profiles/nist-800-53/profile.json,https://my-org.com/ns/oscal
```

Note: When `Control_Id_List` contains multiple controls, wrap the value in quotes if it contains commas.

## Testing Tasks Before Full Runs

Before you run a task on production data:

1. **Check required configuration.** Use `-i` (info) to see what config keys are needed:
   ```bash
   trestle task csv-to-oscal-cd -i
   ```
   This prints all required and optional configuration keys with descriptions.

2. **Use a small test input.** Make a 3-5 row CSV or a small XML/JSON file. Check the mapping before you process full datasets.

3. **Validate the output.** After the task completes, run validation on the generated OSCAL:
   ```bash
   trestle validate -f <output-dir>/component-definition.json
   ```

4. **Import into the workspace.** Import the result only after validation passes:
   ```bash
   trestle import -f <output-dir>/component-definition.json -o my-component
   ```

## Troubleshooting Task Failures

| Error | Cause | Fix |
|-------|-------|-----|
| `KeyError: 'csv-file'` | Required config key is missing from `.trestle/config.ini` | Add the missing key to the `[task.<name>]` section. Run `trestle task <name> -i` to see all required keys |
| `FileNotFoundError` or `File not found` | Input file path does not exist. Relative paths resolve from the workspace root | Use absolute paths. Or check the path relative to the directory that contains `.trestle/` |
| `No controls found` | CSV column headers do not match expected names (case-sensitive) | Check that column names match the reference table above. Example: `Rule_Id`, not `rule_id` |
| `Validation error in output` | Input data refers to invalid control IDs or bad UUIDs | Check that control IDs exist in the target catalog or profile. Fix UUIDs with `python -c "import uuid; print(uuid.uuid4())"` |
| `UnicodeDecodeError` | File uses a non-UTF-8 encoding. Example: Windows Latin-1 | Save the file again as UTF-8. In Python: `open(f, encoding='utf-8-sig')` handles BOM |
| `XML parse error` (XCCDF tasks) | Malformed or incomplete XCCDF XML file | Validate the XML with `xmllint --noout <file>`. Make sure the file is a complete XCCDF result, not a partial extract |
| `JSON decode error` (Tanium tasks) | Malformed Tanium JSON output or truncated file | Validate JSON with `python -m json.tool <file>`. Check for truncation from export tools |
| `configparser.NoSectionError` | Task section is missing from config.ini | Make sure the section header matches `[task.<exact-task-name>]` |

**Debugging tip**: Run trestle with the `--verbose` flag for detailed logging:
```bash
trestle -v task csv-to-oscal-cd
```

## Dual Component Definition Pattern

The `csv-to-oscal-cd` task supports two distinct component types.
Together they connect compliance controls to automated assessment.
This pattern comes from the COMPASS architecture for end-to-end compliance automation.

### Service Component CSV (Control-to-Rule)

Service components declare which rules implement a regulation control for a specific product:

| Column | Example Value | Purpose |
|--------|--------------|---------|
| `Rule_Id` | `rule-ac-2-accounts` | Unique rule identifier |
| `Rule_Description` | `Manage account lifecycle` | What the rule checks |
| `Component_Title` | `My Cloud Service` | Product or service name |
| `Component_Type` | `Service` | Marks this as a service component |
| `Control_Id_List` | `ac-2` | Regulation controls this rule implements |
| `Parameter_Id` | `timeout-minutes` | Configurable parameter for the rule |

**Owner**: Product vendors and service providers.

### Validation Component CSV (Rule-to-Check)

Validation components declare which PVP checks validate a rule:

| Column | Example Value | Purpose |
|--------|--------------|---------|
| `Rule_Id` | `rule-ac-2-accounts` | Must match a Service component rule |
| `Rule_Description` | `Manage account lifecycle` | Same rule, different perspective |
| `Component_Title` | `Auditree PVP` | Assessment tool name |
| `Component_Type` | `Validation` | Marks this as a validation component |
| `Control_Id_List` | `ac-2` | Same controls as the service rule |
| `Check_Id` | `demo.checks.test_github.GitHubOrgs.test_members` | PVP-specific check identifier |
| `Check_Description` | `Verify org members exist` | What the check validates |

**Owner**: Assessment tool vendors, PVP providers, compliance engineers.

### Example Validation CSV

```csv
Rule_Id,Rule_Description,Component_Title,Component_Type,Control_Id_List,Check_Id,Check_Description,Profile_Source,Namespace
rule-ac-2-accounts,Manage account lifecycle,Auditree PVP,Validation,ac-2,demo.checks.test_github.GitHubOrgs.test_members_is_not_empty,Verify GitHub org members exist,trestle://profiles/nist-high/profile.json,https://my-org.com/ns
rule-ac-2-timeout,Enforce session timeout,Auditree PVP,Validation,ac-2,demo.checks.test_github.GitHubOrgs.test_timeout,Verify timeout is configured,trestle://profiles/nist-high/profile.json,https://my-org.com/ns
rule-sc-7-boundary,Protect network boundaries,Kyverno PVP,Validation,sc-7,kyverno.check-network-boundary,Verify boundary protection policies,trestle://profiles/nist-high/profile.json,https://my-org.com/ns
```

### When to Use the Dual Pattern

Use the dual pattern when you connect OSCAL compliance artifacts to automated assessment:
- **Auditree**: `Check_Id` = full Python module path of the check method
- **OCM/Kubernetes**: `Check_Id` = policy resource directory name
- **XCCDF/OpenSCAP**: `Check_Id` = XCCDF rule identifier
- **Custom tools**: `Check_Id` = the identifier the tool uses to select checks

The meaning of `Check_Id` depends on the PVP.
Trestle stores the value in the component definition.
C2P (Compliance-to-Policy) reads it when it makes PVP-specific configuration.

For the full pipeline context, see the **trestle-compliance-pipeline** skill.

## Cross-References

- **trestle-assessment**: Use XCCDF or Tanium task output in the assessment-results workflow (import → split → edit → merge).
- **trestle-validation**: Validate task output before you import into the workspace.
- **trestle-control-implementation**: Understand the component-definition structure that `csv-to-oscal-cd` produces.
- **trestle-compliance-pipeline**: End-to-end pipeline, persona ownership, and C2P bridge.
