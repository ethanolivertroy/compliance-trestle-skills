# Trestle OSCAL operations reference

## Catalogs and profiles

- Use catalogs for source control sets.
- Use profiles for tailoring/importing controls.
- Resolve profiles before generating SSP implementation statements.
- If a profile cannot be resolved locally, mark dependent mappings `needs_review`.

## Component definitions

Use component definitions for reusable services, platforms, applications, and inherited controls. Do not hide inherited responsibility in SSP prose; model it explicitly where possible.

## SSPs

For SSPs, preserve these source-linked sections:

- system name and identifiers
- system characteristics
- authorization boundary
- responsible roles and parties
- inventory/components
- implemented requirements/control statements
- diagrams and evidence references

## Markdown authoring

Trestle markdown is useful for human review. Treat markdown as a review surface and OSCAL JSON/YAML as the exchange package. Keep both synchronized through logged assemble/regenerate commands.

## Validation

Validation means:

- schema/model checks passed;
- references resolve where tooling can check them;
- known warnings are captured.

Validation does not mean:

- controls are effective;
- mappings are authoritative;
- evidence proves implementation.
