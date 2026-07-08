# FedRAMP Rev 5 SSP section map (structure only)

This file documents how legacy SSP headings — including those from the [FedRAMP Rev 5 documents and templates](https://www.fedramp.gov/rev5/documents-templates/) — map into OSCAL SSP fields during draft generation.

Machine-readable rules live in `fedramp-rev5-heading-map.json` and are consumed by `scripts/draft-ssp-from-extraction.py`.

## FedRAMP template sections → OSCAL targets

| FedRAMP Rev 5 SSP area | Typical legacy heading | OSCAL target |
| --- | --- | --- |
| System Description | System Description | `system-characteristics.description` |
| System Boundaries | Boundary, Authorization Boundary | `system-characteristics.authorization-boundary.description` |
| System Environment | System Environment | `security-sensitivity-level` (often `needs_review`) |
| Roles and Responsibilities | Roles and Responsibilities, Points of Contact | `metadata.party` (often `needs_review`) |
| System Users | Users | `system-information` (often `needs_review`) |
| Inventory | Inventory | `system-implementation.inventory-items` (often `needs_review`) |
| Attachments / open items | Open Items, Network Diagram | `back-matter.resources` (`needs_review`) |
| Leveraged Authorizations | Leveraged Authorizations | `system-implementation.leveraged-authorizations` (`needs_review`) |
| Appendix A control implementation | `AC-2 Account Management`, etc. | `control-implementation.implemented-requirements` |

## Control headings

Legacy SSP control sections that match `AC-2`, `IA-2`, `SC-13`, and similar IDs are mapped to `implemented-requirements` using the control ID from the heading. Catalog entries are stubbed with titles taken from the legacy heading remainder, not from NIST or FedRAMP baseline text.

## Authoritative machine-readable packages

For production FedRAMP OSCAL packages, prefer the [GSA FedRAMP Automation](https://github.com/GSA/fedramp-automation) repository and official FedRAMP machine-readable guidance. This workbench draft step creates a **reviewable starting point**, not an authorization-ready FedRAMP submission.

## Guardrails

- Preserve source traceability in `source-map.csv`.
- Mark ambiguous mappings as `needs_review`.
- Do not copy licensed framework text into generated OSCAL.
- Schema-valid OSCAL does not prove compliance effectiveness.
