# Tutorial: legacy SSP to OSCAL with an agent

This tutorial uses synthetic data only. Do not commit real SSPs, customer evidence, secrets, or authorization artifacts.

## Goal

Take a legacy Markdown/PDF/DOCX/TXT SSP package, extract it, build a source map, bootstrap a Compliance Trestle workspace, and generate a review queue before relying on generated OSCAL.

## Run the demo

```bash
bash examples/legacy-ssp-to-oscal/full-demo.sh
```

Review:

- `examples/legacy-ssp-to-oscal/workspace/full-demo/extracted/extracted.md`
- `examples/legacy-ssp-to-oscal/workspace/full-demo/extracted/source-map.csv`
- `examples/legacy-ssp-to-oscal/workspace/full-demo/reports/review-queue.md`
- `examples/legacy-ssp-to-oscal/workspace/full-demo/reports/validation-report.json`

## Agent prompt

Ask your agent:

```text
Use this repository's AGENTS.md and agent-skills/oscal-document-engineering/SKILL.md. Import my legacy SSP package into an OSCAL/Trestle workbench. Preserve source traceability, mark uncertain mappings as needs_review, generate a review queue, and do not claim schema-valid OSCAL proves compliance effectiveness.
```

## Human review

Before using generated OSCAL for assessment work, review all pending, unmapped, and `needs_review` rows. Require evidence for implementation claims.
