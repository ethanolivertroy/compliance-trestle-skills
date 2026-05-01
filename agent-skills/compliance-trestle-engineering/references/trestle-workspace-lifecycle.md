# Compliance Trestle workspace lifecycle

## 1. Pre-flight

Record:

- Workspace path
- Trestle version or missing-tool status
- OSCAL model type(s)
- Source document package
- Applicable baseline/profile
- Reviewer/owner

Do not proceed to generated control mappings until the source package and applicable profile are known.

## 2. Initialize

```bash
mkdir -p workspaces/acme/trestle-workspace
cd workspaces/acme/trestle-workspace
trestle init
```

If Trestle is unavailable, create a scaffold but mark validation as skipped/missing-tool. Do not pretend that skipped validation passed.

## 3. Import/create models

Common model directories:

- `catalogs/`
- `profiles/`
- `component-definitions/`
- `system-security-plans/`
- `assessment-plans/`
- `assessment-results/`
- `plan-of-action-and-milestones/`

Keep file names stable and human-readable.

## 4. Author markdown

Use Trestle authoring for SSP markdown when available. Keep generated markdown sections source-linked. Each paragraph generated from legacy material should have either an inline source marker or an entry in `source-map.csv`.

## 5. Assemble and validate

Run `trestle validate -a` after imports and assemblies. If `trestle author ... assemble` changes OSCAL output, re-run validation and update the command log.

## 6. Review and close loop

Before a package is treated as ready for assessor or stakeholder review:

- all `needs_review` rows are triaged;
- all generated control mappings have a source;
- validation failures are either fixed or documented;
- schema-valid versus compliance-effective is clearly distinguished.
