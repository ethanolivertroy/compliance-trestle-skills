---
name: trestle-validation
description: >-
  Knowledge about Compliance Trestle validation, common errors, and troubleshooting.
  Use when users ask about validation errors, trestle validate failures, OSCAL schema
  validation, fixing compliance document issues, or troubleshooting trestle problems.
allowed-tools: Bash, Read, Glob, Grep, Write, Edit
---

# Trestle Validation and Troubleshooting

## Validation Commands

### Validate All Models
```bash
trestle validate -a
```
Validates every OSCAL model in the workspace. (`-a` is shorthand for `--all`;
this skill uses `-a` throughout.)

**What a clean run looks like:** On a freshly initialized workspace with no
models, `trestle validate -a` finds nothing to validate and exits successfully
with little or no output. Silence is a pass, not a failure. Once models exist,
a passing run reports each validated model with no `ERROR` lines and exits 0.

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
| `Additional properties not allowed` | Extra fields in JSON not in OSCAL schema | Remove the unexpected field |
| `required property 'uuid' missing` | Missing required UUID field | Add a valid UUID (`python -c "import uuid; print(uuid.uuid4())"`) |
| `is not of type 'string'` | Wrong data type for a field | Check the OSCAL schema for expected type |
| `does not match pattern` | Value doesn't match expected regex | Check format requirements (e.g., UUID, date-time) |

### Workspace Structure Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `Not in a trestle workspace` | No `.trestle/` directory found | Run `trestle init` or navigate to workspace root |
| `Model not found` | Model directory or file doesn't exist | Check spelling, ensure model was imported |
| `Duplicate model names` | Two models share the same name | Rename one of the conflicting models |

### Authoring Errors (Generate/Assemble)

| Error | Cause | Fix |
|-------|-------|-----|
| `Markdown directory not found` | Generated markdown directory missing | Run `trestle author *-generate` first |
| `YAML header parse error` | Invalid YAML in markdown frontmatter | Fix YAML syntax in the control markdown file |
| `Unexpected markdown structure` | Manual edits broke expected format | Regenerate markdown and reapply changes |
| `Parameter not found` | Reference to non-existent parameter ID | Check parameter IDs in catalog/profile |

### Import Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `Invalid OSCAL model` | Source file isn't valid OSCAL | Validate the source file against OSCAL schema |
| `Model type mismatch` | File content doesn't match `-t` flag | Verify the model type or omit `-t` for auto-detection |
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
Replace any malformed or missing UUIDs with fresh ones.

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
1. Check the YAML header hasn't been corrupted
2. Verify no structural markdown elements were deleted (headers, dividers)
3. Try regenerating and re-applying changes:
   ```bash
   trestle author ssp-generate --name <ssp> --output <md_dir>-fresh
   ```
   Then diff the fresh output against your edited version.

### Step 5: Reset and Recover

If a model is badly corrupted:
1. Check if `dist/` has a previously assembled good copy
2. Re-import from the original source
3. Use git history to recover previous versions

## Validation Best Practices

1. **Validate after every change**: Run `trestle validate` after imports, edits, and assemblies
2. **Validate before committing**: Add validation to your pre-commit workflow
3. **Use CI/CD validation**: Run `trestle validate -a` in pipelines
4. **Keep backups**: Assemble to `dist/` regularly as validated snapshots
5. **Version control**: Use git to track all changes to OSCAL models
6. **One format per directory**: Don't mix JSON and YAML in the same model directory

## Error Message Reference

Trestle validation errors follow this pattern:
```
ERROR: [model_type] [model_name]: [error_description]
```

When reporting issues:
- Include the full error message
- Note which command triggered the error
- Provide the trestle version (`trestle version`)
- Include the Python version (`python --version`)

## What Each Validator Checks

Trestle includes several specialized validators that go beyond basic schema validation:

| Validator | What It Checks | What It Misses | When to Use |
|-----------|---------------|----------------|-------------|
| `duplicates` | Duplicate UUIDs within a single model | Cross-model UUID collisions | After manual UUID edits or model merges |
| `refs` | Internal UUID cross-references resolve (e.g., a finding's `related-observations` points to a real observation UUID) | References to external models | After editing assessment-results or POA&M files with UUID references |
| `links` | `href` values point to files and resources that exist | Whether the linked content is valid OSCAL | After restructuring workspace directories or renaming files |
| `catalog` | Catalog-specific structure: valid groups, controls, parameters, and back-matter | Semantic correctness of control text | After importing or manually editing catalogs |
| `rules` | Component-definition rule consistency: rule IDs, parameter references, and control mappings | Whether rules are actually testable | After `csv-to-oscal-cd` or manual component-definition edits |

Run specific validators with:
```bash
trestle validate -t <model-type> -n <model-name>
```

All validators run automatically as part of `trestle validate -a`.

## Validating Split Files

After using `trestle split`, individual fragment files are not standalone valid OSCAL documents. Validation must follow the correct workflow:

1. **Never validate mid-split** — a split model's root file references child files via the trestle split convention. The individual pieces won't pass schema validation on their own.

2. **Always merge before validating**:
   ```bash
   trestle merge -e catalog.*        # merge all split parts back
   trestle validate -t catalog -n my-catalog
   ```

3. **Partial sanity check** — while you shouldn't schema-validate split files, you can verify they are valid JSON:
   ```bash
   python -c "import json, pathlib; [json.loads(p.read_text()) for p in pathlib.Path('.').rglob('*.json')]"
   ```

4. **Pattern**: The correct workflow is always **split → edit → merge → validate**. Never skip the merge step before validation.

## CI/CD Validation Patterns

CI/CD integration is optional for initial testing and evaluation. Running
`trestle validate -a` locally is sufficient while you explore the workflows;
add the pipeline patterns below once models are under version control and
changing regularly.

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

Assessment results and POA&M documents use JSON-based workflows (split/merge rather than generate/assemble). Validation is critical after every merge because these models have dense UUID cross-references.

### Common Assessment Validation Issues

| Issue | Cause | Fix |
|-------|-------|-----|
| Missing `import-ap` href | Assessment results must reference an assessment plan | Set `import-ap.href` to a valid path (e.g., `trestle://assessment-plans/my-plan/assessment-plan.json`) |
| Findings without `target.status` | Every finding needs a determination status | Add `target.status.state` with value `satisfied` or `not-satisfied` |
| Orphaned observation UUIDs | A finding references an observation that was deleted | Update the finding's `related-observations` list or restore the observation |

### Common POA&M Validation Issues

| Issue | Cause | Fix |
|-------|-------|-----|
| Broken observation UUID references | POA&M item references a non-existent observation | Check `poam-items[].related-observations` UUIDs match actual observations |
| Broken risk UUID references | POA&M item references a non-existent risk | Check `poam-items[].related-risks` UUIDs match actual risks in the model |
| Missing `import-ssp` href | POA&M must reference its parent SSP | Set `import-ssp.href` to the SSP path |

**Tip**: Always validate with the specific type for faster feedback:
```bash
trestle validate -t assessment-results -n my-results
trestle validate -t plan-of-action-and-milestones -n my-poam
```

## Cross-References

- **trestle-authoring-workflow**: The generate → assemble cycle where validation catches structural errors before they propagate
- **trestle-assessment**: JSON-based assessment-results workflow where `refs` validation is essential
- **trestle-poam**: JSON-based POA&M workflow with dense UUID cross-references requiring `refs` and `duplicates` validation
- **trestle-governance**: Combining OSCAL schema validation with document structure validation for complete coverage
