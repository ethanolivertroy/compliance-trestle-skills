# Legacy SSP to OSCAL Example

This synthetic example shows the first step of the OSCAL document modernization flow.
It does not commit sensitive customer data.

## Run

```bash
bash examples/legacy-ssp-to-oscal/scripts/run-example.sh
bash examples/legacy-ssp-to-oscal/full-demo.sh
```

When Compliance Trestle is installed, the scripts draft a schema-valid OSCAL SSP from extracted legacy sections.
They use FedRAMP Rev 5 heading conventions.

`run-example.sh` writes a basic demo under `examples/legacy-ssp-to-oscal/workspace/basic-demo/`.
It does not delete `workspace/full-demo/`.

## Expected outputs

- `workspace/basic-demo/extracted/extracted.md`
- `workspace/basic-demo/extracted/source-map.csv`
- `workspace/basic-demo/extracted/extract-manifest.json`
- `workspace/basic-demo/trestle-workspace/`
- `workspace/basic-demo/reports/`

This example is small and synthetic by design.
Do not commit real SSPs or customer evidence.
