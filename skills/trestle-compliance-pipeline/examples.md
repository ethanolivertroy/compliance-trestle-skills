# Pipeline Examples

Worked examples for end-to-end compliance pipelines using Trestle.

## Example 1: Full Pipeline Walkthrough

This walkthrough shows the full flow from catalog import to SSP assembly.

### Step 1: Import a Catalog

```bash
# Initialize trestle workspace
trestle init

# Import NIST 800-53 catalog
trestle import -f https://raw.githubusercontent.com/usnistgov/oscal-content/main/nist.gov/SP800-53/rev5/json/NIST_SP-800-53_rev5_catalog.json -o nist-800-53
```

### Step 2: Create a Profile (Baseline)

```bash
# Import an existing profile (example: FedRAMP High)
trestle import -f fedramp-high-profile.json -o fedramp-high

# Generate markdown for editing
trestle author profile-generate --name fedramp-high --output md_profiles/fedramp-high

# Edit markdown: adjust parameters, add org-specific guidance
# Then reassemble
trestle author profile-assemble --markdown md_profiles/fedramp-high --output fedramp-high --set-parameters
```

### Step 3: Create Component Definition: Phase 1 (Rules with CSV)

Create a CSV file `data/my-service-controls.csv`:

```csv
Rule_Id,Rule_Description,Component_Title,Component_Type,Control_Id_List,Parameter_Id,Parameter_Value_Alternatives,Profile_Source,Namespace
rule-ac-2-accounts,Ensure account types are defined and managed,My Cloud Service,Service,ac-2,,,trestle://profiles/fedramp-high/profile.json,https://my-org.com/ns/oscal
rule-ac-2-timeout,Check session timeout configuration,My Cloud Service,Service,ac-2,ac-2-timeout,15 30 60,trestle://profiles/fedramp-high/profile.json,https://my-org.com/ns/oscal
rule-ac-3-rbac,Enforce RBAC for all API access,My Cloud Service,Service,ac-3,,,trestle://profiles/fedramp-high/profile.json,https://my-org.com/ns/oscal
rule-sc-7-boundary,Verify network boundary protection,My Cloud Service,Service,sc-7,,,trestle://profiles/fedramp-high/profile.json,https://my-org.com/ns/oscal
```

Configure `.trestle/config.ini`:

```ini
[task.csv-to-oscal-cd]
title = My Cloud Service Controls
version = 1.0
csv-file = data/my-service-controls.csv
output-dir = component-definitions/my-service
output-overwrite = true
```

Run the task:

```bash
trestle task csv-to-oscal-cd
trestle validate -f component-definitions/my-service/component-definition.json
```

### Step 4: Create Component Definition: Phase 2 (Responses with Markdown)

```bash
# Generate markdown from the component definition
trestle author component-generate --name my-service --output md_compdefs/my-service

# Edit each control markdown: write implementation prose
# Example: md_compdefs/my-service/My Cloud Service/ac-2.md
#   Add prose below "## Implementation for part a."

# Reassemble with markdown content merged
trestle author component-assemble --markdown md_compdefs/my-service --output my-service
```

### Step 5: Generate and Author SSP

```bash
# Generate SSP from profile + component definitions
trestle author ssp-generate \
  --profile fedramp-high \
  --compdefs my-service \
  --output md_ssp/my-system

# Edit control markdown files in md_ssp/my-system/
# Fill in system-specific ssp-values and "This System" implementation prose

# Reassemble
trestle author ssp-assemble --markdown md_ssp/my-system --output my-system
```

### Step 6: Validate Everything

```bash
# Validate all models in workspace
trestle validate -a
```

## Example 2: Multi-Repo CI/CD Pattern

### GitHub Actions: Catalog Repository

```yaml
# .github/workflows/catalog-assemble.yml
name: Assemble Catalog
on:
  push:
    branches: [main]
    paths: ['md_catalogs/**']

jobs:
  assemble:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install trestle
        run: pip install compliance-trestle

      - name: Assemble catalog
        run: |
          trestle author catalog-assemble \
            --markdown md_catalogs/nist-800-53 \
            --output nist-800-53

      - name: Validate
        run: trestle validate -t catalog -n nist-800-53

      - name: Commit if changed
        run: |
          git diff --quiet catalogs/ || {
            git config user.name "github-actions"
            git config user.email "actions@github.com"
            git add catalogs/
            git commit -m "chore: reassemble catalog from markdown changes"
            git push
          }

      - name: Trigger downstream profile repo
        if: steps.commit.outcome == 'success'
        uses: peter-evans/repository-dispatch@v2
        with:
          repository: my-org/profile-repo
          event-type: catalog-updated
          token: ${{ secrets.CROSS_REPO_TOKEN }}
```

### GitHub Actions: Profile Repository

```yaml
# .github/workflows/profile-assemble.yml
name: Assemble Profile
on:
  push:
    branches: [main]
    paths: ['md_profiles/**']
  repository_dispatch:
    types: [catalog-updated]

jobs:
  assemble:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install trestle
        run: pip install compliance-trestle

      - name: Pull latest catalog
        run: |
          # Fetch updated catalog from catalog-repo
          curl -o catalogs/nist-800-53/catalog.json \
            https://raw.githubusercontent.com/my-org/catalog-repo/main/catalogs/nist-800-53/catalog.json

      - name: Assemble profile
        run: |
          trestle author profile-assemble \
            --markdown md_profiles/my-baseline \
            --output my-baseline --set-parameters

      - name: Validate
        run: trestle validate -t profile -n my-baseline

      - name: Commit and propagate
        run: |
          git diff --quiet profiles/ catalogs/ || {
            git add profiles/ catalogs/
            git commit -m "chore: reassemble profile (upstream catalog update)"
            git push
          }
```

### Key CI/CD Principles

1. **Assemble only writes if changed**: This prevents infinite CI/CD loops.
2. **Validate after assembly**: This finds schema violations before propagation.
3. **Cross-repo triggers**: `repository_dispatch` events propagate changes downstream.
4. **Conditional commits**: Commit and propagate only if the assembled JSON actually changed.

## Example 3: Dual Component Definition CSV

### Service Component CSV (Control-to-Rule)

`data/my-service-rules.csv`:

```csv
Rule_Id,Rule_Description,Component_Title,Component_Type,Control_Id_List,Parameter_Id,Parameter_Value_Alternatives,Profile_Source,Namespace
rule-ac-2-accounts,Manage account lifecycle,My Service,Service,ac-2,,,trestle://profiles/fedramp-high/profile.json,https://my-org.com/ns
rule-ac-2-timeout,Enforce session timeout,My Service,Service,ac-2,timeout-minutes,"15,30,60",trestle://profiles/fedramp-high/profile.json,https://my-org.com/ns
rule-sc-7-boundary,Protect network boundaries,My Service,Service,sc-7,,,trestle://profiles/fedramp-high/profile.json,https://my-org.com/ns
```

### Validation Component CSV (Rule-to-Check)

`data/my-service-checks.csv`:

```csv
Rule_Id,Rule_Description,Component_Title,Component_Type,Control_Id_List,Check_Id,Check_Description,Profile_Source,Namespace
rule-ac-2-accounts,Manage account lifecycle,Auditree PVP,Validation,ac-2,demo_examples.checks.test_github.GitHubOrgs.test_members_is_not_empty,Verify GitHub org members exist,trestle://profiles/fedramp-high/profile.json,https://my-org.com/ns
rule-ac-2-timeout,Enforce session timeout,Auditree PVP,Validation,ac-2,demo_examples.checks.test_github.GitHubOrgs.test_timeout_configured,Verify session timeout is set,trestle://profiles/fedramp-high/profile.json,https://my-org.com/ns
rule-sc-7-boundary,Protect network boundaries,Kyverno PVP,Validation,sc-7,kyverno.policies.check-network-boundary,Verify boundary protection CRDs,trestle://profiles/fedramp-high/profile.json,https://my-org.com/ns
```

### Configuration for Both

```ini
# .trestle/config.ini

[task.csv-to-oscal-cd]
title = My Service Controls
version = 1.0
csv-file = data/my-service-rules.csv
output-dir = component-definitions/my-service
output-overwrite = true

[task.csv-to-oscal-cd.validation]
title = My Service Validation
version = 1.0
csv-file = data/my-service-checks.csv
output-dir = component-definitions/my-service-validation
output-overwrite = true
```

```bash
# Generate both component definitions
trestle task csv-to-oscal-cd
# (Run with second config section for validation, or use separate config file)
```

**Note**: Service and Validation component definitions can be separate files.
They can also be one file.
Separate files are easier when different teams own each type.

## Example 4: C2P Pipeline (Auditree)

### Step 1: Author Component Definition with Check Mappings

Create the Service component definition (rules) and Validation component definition
(checks) as shown in Example 3 above using `csv-to-oscal-cd`.

### Step 2: Generate Auditree Configuration with C2P

```bash
# C2P reads component-definition.json and generates auditree.json
python compliance_to_policy.py \
  -i auditree_template.json \
  -c component-definitions/my-service/component-definition.json \
  -o auditree.json
```

C2P reads parameter values from the component definition.
C2P writes those values into the `auditree.json` template.
Example: if the component definition has parameter `org.gh.orgs = ["my-org"]`, C2P writes this into the auditree config.

### Step 3: Execute Auditree

```bash
# Run fetchers (collect evidence)
compliance --fetch --evidence local -C auditree.json -v

# Run checks (validate against desired state)
compliance --check demo.custom.accred --evidence local -C auditree.json -v
```

Auditree produces `check_results.json` in the evidence locker.

### Step 4: Generate OSCAL Assessment Results with C2P

```bash
# C2P maps check results back to controls through component definition traceability
python result_to_compliance.py \
  -i ${LOCKER_PATH}/check_results.json \
  -c component-definitions/my-service/component-definition.json \
  > assessment-results.json
```

### Step 5: Import Results and View

```bash
# Import into trestle workspace
trestle import -f assessment-results.json -o latest-scan

# View as human-readable markdown
c2p tools viewer -ar assessment-results.json \
  -cdef component-definitions/my-service/component-definition.json \
  > assessment-results.md
```

The assessment results show per-control posture (`satisfied` or `not-satisfied`).
The chain traces back through rules and checks to the original regulatory controls.
