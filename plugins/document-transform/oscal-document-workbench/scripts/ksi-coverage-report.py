#!/usr/bin/env python3
"""Report FedRAMP 20x Key Security Indicator coverage for an OSCAL SSP.

Cross-references the control IDs implemented in an OSCAL SSP against the
Key Security Indicators in the FedRAMP Consolidated Rules for 2026
(fedramp-consolidated-rules.json from the FedRAMP/rules repository).

Coverage here means "the SSP documents related SP 800-53 controls", which is
evidence a reviewer can start from. It is NOT a FedRAMP 20x certification
result; KSIs are validated by assessment and telemetry, not documentation.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("ssp", help="Path to an OSCAL system-security-plan JSON file")
    parser.add_argument(
        "--rules",
        default=str(Path.home() / ".cache/oscal-baselines/fedramp-consolidated-rules.json"),
        help="Path to fedramp-consolidated-rules.json (default: baseline cache; run fetch-fedramp-2026-rules.sh first)",
    )
    parser.add_argument("--output", help="Write the markdown report to this path (default: stdout)")
    parser.add_argument(
        "--json-output",
        help="Also write machine-readable coverage JSON to this path",
    )
    return parser.parse_args()


def load_ssp_controls(ssp_path: Path) -> set[str]:
    ssp = json.loads(ssp_path.read_text(encoding="utf-8"))
    root = ssp.get("system-security-plan")
    if not root:
        raise SystemExit(f"not an OSCAL SSP: {ssp_path}")
    requirements = root.get("control-implementation", {}).get("implemented-requirements", [])
    return {req["control-id"].lower() for req in requirements if req.get("control-id")}


def base_control(control_id: str) -> str:
    return control_id.split(".")[0]


def main() -> int:
    args = parse_args()
    ssp_path = Path(args.ssp)
    rules_path = Path(args.rules)
    if not ssp_path.exists():
        sys.stderr.write(f"ksi-coverage-report: SSP not found: {ssp_path}\n")
        return 2
    if not rules_path.exists():
        sys.stderr.write(
            f"ksi-coverage-report: rules file not found: {rules_path}\n"
            "Run fetch-fedramp-2026-rules.sh first.\n"
        )
        return 2

    ssp_controls = load_ssp_controls(ssp_path)
    ssp_bases = {base_control(c) for c in ssp_controls}
    rules = json.loads(rules_path.read_text(encoding="utf-8"))
    info = rules.get("info", {})
    ksi_families = rules.get("KSI", {})

    rows = []
    totals = {"covered": 0, "partial": 0, "uncovered": 0, "not_applicable": 0}
    for family_key, family in sorted(ksi_families.items()):
        for ksi_id, indicator in sorted(family.get("indicators", {}).items()):
            related = [c.lower() for c in indicator.get("controls", [])]
            exact = sorted(c for c in related if c in ssp_controls)
            base_only = sorted(
                c for c in related if c not in ssp_controls and base_control(c) in ssp_bases
            )
            missing = sorted(c for c in related if c not in ssp_controls and base_control(c) not in ssp_bases)
            if not related:
                status = "not_applicable"
            elif len(exact) == len(related):
                status = "covered"
            elif exact or base_only:
                status = "partial"
            else:
                status = "uncovered"
            totals[status] += 1
            rows.append(
                {
                    "ksi": ksi_id,
                    "family": family.get("name", family_key),
                    "name": indicator.get("name", ""),
                    "status": status,
                    "related_controls": related,
                    "exact_matches": exact,
                    "base_control_matches": base_only,
                    "missing_controls": missing,
                }
            )

    lines = [
        "# FedRAMP 20x KSI coverage report",
        "",
        f"- SSP: `{ssp_path}`",
        f"- Rules: {info.get('title', 'FedRAMP Consolidated Rules')} "
        f"version {info.get('version', '?')} (updated {info.get('last_updated', '?')})",
        f"- SSP implemented control IDs: {len(ssp_controls)}",
        f"- KSIs covered: {totals['covered']} | partial: {totals['partial']} | "
        f"uncovered: {totals['uncovered']} | not applicable: {totals['not_applicable']}",
        "",
        "Coverage means the SSP documents the related SP 800-53 controls for the KSI.",
        "Coverage is documentation evidence only.",
        "Coverage is not a FedRAMP 20x validation result.",
        "",
        "| KSI | Name | Status | Matched | Missing controls |",
        "| --- | --- | --- | --- | --- |",
    ]
    for row in rows:
        matched_count = len(row["exact_matches"]) + len(row["base_control_matches"])
        missing = ", ".join(row["missing_controls"][:6])
        if len(row["missing_controls"]) > 6:
            missing += ", ..."
        lines.append(
            f"| {row['ksi']} | {row['name']} | {row['status']} "
            f"| {matched_count}/{len(row['related_controls'])} | {missing} |"
        )
    lines.append("")
    report = "\n".join(lines)

    if args.output:
        out = Path(args.output)
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(report, encoding="utf-8")
        print(f"ksi-coverage-report: wrote {out}")
    else:
        print(report)

    if args.json_output:
        json_out = Path(args.json_output)
        json_out.parent.mkdir(parents=True, exist_ok=True)
        json_out.write_text(
            json.dumps(
                {
                    "ssp": str(ssp_path),
                    "rules_version": info.get("version"),
                    "totals": totals,
                    "indicators": rows,
                    "note": "Documentation coverage only. Not a FedRAMP 20x validation result.",
                },
                indent=2,
            )
            + "\n",
            encoding="utf-8",
        )
        print(f"ksi-coverage-report: wrote {json_out}")

    print(
        f"ksi-coverage-report: covered={totals['covered']} partial={totals['partial']} "
        f"uncovered={totals['uncovered']}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
