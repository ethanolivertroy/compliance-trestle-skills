# Legacy SSP to OSCAL Example

This synthetic example demonstrates the first step of the OSCAL document modernization flow without committing sensitive customer data.

## Run

```bash
bash examples/legacy-ssp-to-oscal/scripts/run-example.sh
```

The script extracts `input/sample-ssp.md`, creates a traceability map, bootstraps a Trestle workspace scaffold, and writes reports under `examples/legacy-ssp-to-oscal/workspace/`.

## Expected outputs

- `workspace/extracted/extracted.md`
- `workspace/extracted/source-map.csv`
- `workspace/extracted/extract-manifest.json`
- `workspace/trestle-workspace/`
- `workspace/reports/import-summary.md`
- `workspace/reports/unmapped-items.md`

This example is intentionally small and synthetic. Do not commit real SSPs or customer evidence.
