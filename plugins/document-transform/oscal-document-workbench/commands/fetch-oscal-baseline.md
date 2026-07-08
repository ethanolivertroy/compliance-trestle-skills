---
name: Fetch OSCAL Baseline
description: Download the NIST SP 800-53 Rev 5 catalog and a FedRAMP Rev 5 baseline profile, then import both into a Compliance Trestle workspace for real-baseline SSP drafting.
---

# /oscal-document-workbench:fetch-oscal-baseline

Download the NIST SP 800-53 Rev 5 OSCAL catalog and a FedRAMP Rev 5 baseline profile, cache them locally, and import both into a Compliance Trestle workspace.

## How to run

```bash
bash plugins/document-transform/oscal-document-workbench/scripts/fetch-oscal-baseline.sh <trestle-workspace> [--baseline low|moderate|high|li-saas] [--cache-dir <dir>] [--overwrite]
```

Then draft the SSP against the real baseline:

```bash
bash plugins/document-transform/oscal-document-workbench/scripts/draft-ssp-from-extraction.sh <workspace> --baseline-profile fedramp-rev5-moderate --overwrite
```

## Arguments

- `<trestle-workspace>` — an initialized Trestle workspace (contains `.trestle/`).
- `--baseline <level>` — FedRAMP Rev 5 baseline: `low`, `moderate` (default), `high`, or `li-saas`.
- `--cache-dir <dir>` — download cache (default `~/.cache/oscal-baselines`, override with `OSCAL_BASELINE_CACHE`).
- `--overwrite` — replace existing imported catalog/profile models.
- `--skip-validate` — skip post-import profile validation.

## Sources

- NIST SP 800-53 Rev 5 catalog: `usnistgov/oscal-content` on GitHub.
- FedRAMP Rev 5 baseline profiles: `OSCAL-Foundation/fedramp-resources` on GitHub (per [fedramp.gov Rev 5 documents and templates](https://www.fedramp.gov/rev5/documents-templates/), OSCAL packages are managed through the FedRAMP automation GitHub ecosystem).

Override source URLs with `OSCAL_NIST_CATALOG_URL` and `OSCAL_FEDRAMP_BASE_URL` for mirrors or air-gapped environments. Pre-populate the cache directory when network egress is restricted.

## Outputs

- `catalogs/nist-800-53-rev5/` — imported NIST catalog.
- `profiles/fedramp-rev5-<baseline>/` — imported FedRAMP profile with its import href rewritten to the local trestle catalog.
- Cached downloads under the cache directory.

## Exit codes

- `0` — success
- `2` — bad arguments or not a trestle workspace
- `3` — import or validation failed
- `5` — missing dependency (trestle, curl) or download failure

## Safety notes

- Downloaded content is official NIST/FedRAMP OSCAL data; do not edit it in place. Tailor via profiles.
- Mark uncertain control mappings as `needs_review` in the source map.
- Do not treat structural validation as an audit opinion.
- Do not commit sensitive customer evidence or real SSPs.
