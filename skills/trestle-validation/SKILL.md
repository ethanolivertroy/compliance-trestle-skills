---
name: trestle-validation
description: >-
  Use this skill for Compliance Trestle validation, common errors, and troubleshooting.
  Use it for validation errors, trestle validate failures, and OSCAL schema checks.
  Use it to fix compliance document issues or to troubleshoot trestle problems.
allowed-tools: Bash, Read, Glob, Grep, Write, Edit
---

# Trestle Validation and Troubleshooting

## Validation Commands

### Validate All Models
```bash
trestle validate -a
```
This command validates every OSCAL model in the workspace. `-a` is short for `--all`.
This skill uses `-a` in all examples.

**What a clean run looks like:** On a new workspace with no models, `trestle validate -a` finds no models.
The command exits with code 0. Little or no output is normal. No output means pass. It is not a failure.
After you add models, a pass lists each validated model. There are no `ERROR` lines. The exit code is 0.

### Validate by Type
```bash
trestle validate -t catalog -n my-catalog
trestle validate -t profile -n my-profile
trestle validate -t component-definition -n my-compdef
trestle validate -t system-security-plan -n my-ssp
trestle validate -t assessment-plan -n my-assessment
trestle validate -t assessment-results -n my-results
trestle validate -t plan-of-action-and-milestones -n my-poam
```

### Validate Specific File
```bash
trestle validate -f catalogs/my-catalog/catalog.json
```

## Common Validation Errors

### Schema Validation Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `Additional properties not allowed` | Extra fields in JSON that are not in the OSCAL schema | Remove the unexpected field |
| `required property 'uuid' missing` | Required UUID field is missing | Add a valid UUID (`python -c "import uuid; print(uuid.uuid4())"`) |
| `is not of type 'string'` | Wrong data type for a field | Check the OSCAL schema for the expected type |
| `does not match pattern` | Value does not match the expected regex | Check format rules. Examples: UUID, date-time |

### Workspace Structure Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `Not in a trestle workspace` | No `.trestle/` directory found | Run `trestle init` or go to the workspace root |
| `Model not found` | Model directory or file does not exist | Check spelling. Make sure you imported the model |
| `Duplicate model names` | Two models share the same name | Rename one of the conflicting models |

### Authoring Errors (Generate/Assemble)

| Error | Cause | Fix |
|-------|-------|-----|
| `Markdown directory not found` | Generated markdown directory is missing | Run `trestle author *-generate` first |
| `YAML header parse error` | Invalid YAML in markdown frontmatter | Fix YAML syntax in the control markdown file |
| `Unexpected markdown structure` | Manual edits broke the expected format | Generate markdown again. Then apply your changes |
| `Parameter not found` | Reference to a parameter ID that does not exist | Check parameter IDs in the catalog or profile |

### Import Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `Invalid OSCAL model` | Source file is not valid OSCAL | Validate the source file against the OSCAL schema |
| `Model type mismatch` | File content does not match the `-t` flag | Check the model type. Or omit `-t` for auto-detection |
| `File format not supported` | Unsupported file extension | Use `.json` or `.yaml`/`.yml` |

## Troubleshooting Guide

### Step 1: Check Workspace Health
```bash
# Verify workspace
ls -la .trestle/

# Check config
cat .trestle/config.ini

# List all models
ls catalogs/ profiles/ component-definitions/ system-security-plans/ 2>/dev/null
```

### Step 2: Run Full Validation
```bash
trestle validate -a 2>&1
```

### Step 3: Check Individual Models
For each model that fails validation:
```bash
# Validate specific model with verbose output
trestle validate -t <type> -n <name>

# Check the model file directly
python -c "import json; json.load(open('<path>/model.json'))"
```

### Step 4: Common Fixes

#### Fix Invalid UUIDs
```python
import uuid
print(str(uuid.uuid4()))
```
Replace any bad or missing UUIDs with new ones.

#### Fix YAML Header Issues in Markdown
Common YAML problems in control markdown:
- Missing quotes around values with special characters
- Incorrect indentation (YAML requires consistent spaces, not tabs)
- Missing `---` delimiters around frontmatter

#### Fix Broken Import References
Profiles reference catalogs by href. Check:
```json
"imports": [
  { "href": "trestle://catalogs/nist-800-53/catalog.json" }
]
```
The referenced catalog must exist at that path in the workspace.

#### Fix Assembly Failures
If assemble fails after markdown edits:
1. Check that the YAML header is not corrupt.
2. Check that no structural markdown elements were deleted. Keep headers and dividers.
3. Generate again. Then apply your changes:
   ```bash
   trestle author ssp-generate --name <ssp> --output <md_dir>-fresh
   ```
   Then diff the fresh output against your edited version.

### Step 5: Reset and Recover

If a model is corrupt:
1. Check if `dist/` has a previously assembled good copy.
2. Import again from the original source.
3. Use git history to recover previous versions.

## Validation Best Practices

1. **Validate after every change**: Run `trestle validate` after imports, edits, and assemblies.
2. **Validate before committing**: Add validation to your pre-commit workflow.
3. **Use CI/CD validation**: Run `trestle validate -a` in pipelines.
4. **Keep backups**: Assemble to `dist/` often. Keep those files as validated snapshots.
5. **Version control**: Use git to track all changes to OSCAL models.
6. **One format per directory**: Do not mix JSON and YAML in the same model directory.

## Error Message Reference

Trestle validation errors follow this pattern:
```
ERROR: [model_type] [model_name]: [error_description]
```

When you report an issue:
- Include the full error message.
- Note which command caused the error.
- Give the trestle version (`trestle version`).
- Give the Python version (`python --version`).

## What Each Validator Checks

Trestle includes several specialized validators. These go beyond basic schema validation:

| Validator | What It Checks | What It Misses | When to Use |
|-----------|---------------|----------------|-------------|
| `duplicates` | Duplicate UUIDs inside one model | Cross-model UUID collisions | After manual UUID edits or model merges |
| `refs` | Internal UUID references resolve. Example: a finding `related-observations` value points to a real observation UUID | References to external models | After you edit assessment-results or POA&M files with UUID references |
| `links` | `href` values point to files and resources that exist | Whether the linked content is valid OSCAL | After you restructure workspace directories or rename files |
| `catalog` | Catalog-specific structure: valid groups, controls, parameters, and back-matter | Semantic correctness of control text | After you import or manually edit catalogs |
| `rules` | Component-definition rule consistency: rule IDs, parameter references, and control mappings | Whether rules are testable | After `csv-to-oscal-cd` or manual component-definition edits |

Run specific validators with:
```bash
trestle validate -t <model-type> -n <model-name>
```

All validators run automatically as part of `trestle validate -a`.

## Validating Split Files

After you use `trestle split`, individual fragment files are not valid OSCAL documents by themselves.
Follow this workflow:

1. **Do not validate during a split.** A split model's root file references child files with the trestle split convention. The individual pieces do not pass schema validation on their own.

2. **Always merge before you validate**:
   ```bash
   trestle merge -e catalog.*        # merge all split parts back
   trestle validate -t catalog -n my-catalog
   ```

3. **Partial check.** Do not run schema validation on split files. You can check that they are valid JSON:
   ```bash
   python -c "import json, pathlib; [json.loads(p.read_text()) for p in pathlib.Path('.').rglob('*.json')]"
   ```

4. **Pattern**: The correct workflow is always **split → edit → merge → validate**. Do not skip the merge step before validation.

## CI/CD Validation Patterns

CI/CD validation is optional for first tests.
Run `trestle validate -a` on your machine during exploration.
Add the pipeline patterns below after models are in version control and change often.

### GitHub Actions Workflow

```yaml
name: OSCAL Validation

on:
  pull_request:
    paths:
      - 'catalogs/**'
      - 'profiles/**'
      - 'component-definitions/**'
      - 'system-security-plans/**'
      - 'assessment-results/**'
      - 'plan-of-action-and-milestones/**'

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Install trestle
        run: pip install compliance-trestle

      - name: Initialize trestle workspace
        run: |
          cd ${{ github.workspace }}
          trestle init --govdocs

      - name: Validate all OSCAL models
        run: |
          trestle validate -a 2>&1 | tee validation-report.txt
          if grep -q "ERROR" validation-report.txt; then
            echo "::error::OSCAL validation failed"
            exit 1
          fi

      - name: Validate governed docs
        run: trestle author docs validate -tn policies -hv

      - name: Upload validation report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: validation-report
          path: validation-report.txt
```

### Pre-commit Hook

```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: trestle-validate
        name: Validate OSCAL models
        entry: bash -c 'trestle validate -a'
        language: system
        pass_filenames: false
        files: '\.(json|yaml|yml)$'
```

**Tip**: For faster feedback during development, validate only the model you changed:
```bash
trestle validate -t system-security-plan -n my-ssp
```
Reserve `trestle validate -a` for CI/CD pipelines.

## Validation After Assessment and POA&M Edits

Assessment results and POA&M documents use a JSON workflow.
Use split and merge. Do not use generate and assemble.
Validate after every merge. These models have many UUID references.

### Common Assessment Validation Issues

| Issue | Cause | Fix |
|-------|-------|-----|
| Missing `import-ap` href | Assessment results must reference an assessment plan | Set `import-ap.href` to a valid path. Example: `trestle://assessment-plans/my-plan/assessment-plan.json` |
| Findings without `target.status` | Every finding needs a determination status | Add `target.status.state` with value `satisfied` or `not-satisfied` |
| Orphaned observation UUIDs | A finding refers to a deleted observation | Update the finding `related-observations` list. Or restore the observation |

### Common POA&M Validation Issues

| Issue | Cause | Fix |
|-------|-------|-----|
| Broken observation UUID references | POA&M item refers to an observation that does not exist | Check `poam-items[].related-observations` UUIDs against actual observations |
| Broken risk UUID references | POA&M item refers to a risk that does not exist | Check `poam-items[].related-risks` UUIDs against actual risks in the model |
| Missing `import-ssp` href | POA&M must reference its parent SSP | Set `import-ssp.href` to the SSP path |

**Tip**: Always validate with the specific type for faster feedback:
```bash
trestle validate -t assessment-results -n my-results
trestle validate -t plan-of-action-and-milestones -n my-poam
```

## Cross-References

- **trestle-authoring-workflow**: The generate-assemble cycle. Validation finds structure errors before they spread.
- **trestle-assessment**: JSON assessment-results workflow. The `refs` validator is required.
- **trestle-poam**: JSON POA&M workflow with many UUID references. Use `refs` and `duplicates` validation.
- **trestle-governance**: Combine OSCAL schema validation with document structure validation.
