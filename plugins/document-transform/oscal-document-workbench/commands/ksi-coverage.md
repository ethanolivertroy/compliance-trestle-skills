---
name: KSI Coverage Report
description: Cross-reference an OSCAL SSP against the FedRAMP 20x Key Security Indicators from the 2026 Consolidated Rules and report documentation coverage.
---

# /oscal-document-workbench:ksi-coverage

FedRAMP is moving from the legacy Rev 5 document templates toward the 2026 Consolidated Rules, where FedRAMP 20x certification is organized around Key Security Indicators (KSIs) instead of narrative SSP documents. This command bridges the two worlds: it maps the SP 800-53 control IDs implemented in an OSCAL SSP onto the 46 KSIs and reports which KSIs already have documented control coverage.

## How to run

```bash
bash plugins/document-transform/oscal-document-workbench/scripts/fetch-fedramp-2026-rules.sh
bash plugins/document-transform/oscal-document-workbench/scripts/ksi-coverage-report.sh <ssp.json> --output <workspace>/reports/ksi-coverage.md --json-output <workspace>/reports/ksi-coverage.json
```

## Arguments

- `<ssp.json>` — an OSCAL system-security-plan JSON file (for example one drafted by `draft-ssp-from-extraction.sh`).
- `--rules <path>` — path to `fedramp-consolidated-rules.json` (default: the baseline cache populated by `fetch-fedramp-2026-rules.sh`).
- `--output <path>` — write the markdown report here (default: stdout).
- `--json-output <path>` — also write machine-readable coverage JSON.

## Sources

- `FedRAMP/rules` on GitHub — `fedramp-consolidated-rules.json`, the machine-readable source of FRD definitions, FRR requirements, KSI indicators, and CTL control requirements.
- `FedRAMP/2026-markdown` on GitHub — the same rules rendered as markdown for AI agents and text tooling.

Override the source URL with `FEDRAMP_2026_RULES_URL` for mirrors or air-gapped environments.

## Outputs

- `ksi-coverage.md` — per-KSI table: covered, partial, or uncovered, with missing control IDs.
- `ksi-coverage.json` — machine-readable coverage details for downstream tooling.

## Exit codes

- `0` — success
- `2` — bad arguments, missing SSP, or missing rules file
- `5` — download failure (fetch script)

## Safety notes

- Coverage means the SSP documents the KSI's related SP 800-53 controls. It is documentation evidence only, not a FedRAMP 20x validation or certification result; KSIs are validated by assessment and telemetry.
- Mark uncertain mappings as `needs_review` in the source map before relying on coverage numbers.
- Do not treat structural validation as an audit opinion.
- Do not commit sensitive customer evidence or real SSPs.
