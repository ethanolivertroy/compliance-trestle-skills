#!/usr/bin/env python3
"""Draft a schema-valid OSCAL SSP from extracted legacy sections."""

from __future__ import annotations

import argparse
import csv
import json
import re
import subprocess
import sys
import uuid
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

CONTROL_HEADING_RE = re.compile(
    r"^(?P<id>[A-Za-z]{2,3}-\d+(?:\.\d+)?(?:\(\w+\))?)\s*(?P<title>.*)$"
)
OWNER_RE = re.compile(r"(?i)(system owner|isso|authorizing official|information system security officer)\s*:\s*(.+)")


@dataclass
class SectionMapping:
    source_id: str
    heading: str
    excerpt: str
    oscal_target: str
    status: str
    notes: str
    control_id: str | None = None


@dataclass
class DraftPlan:
    system_name: str
    ssp_alias: str
    catalog_alias: str
    profile_alias: str
    profile_label: str
    sections: list[SectionMapping] = field(default_factory=list)
    control_ids: list[str] = field(default_factory=list)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Draft a schema-valid OSCAL SSP from extracted legacy sections."
    )
    parser.add_argument("workspace", help="Import workspace containing extracted/ and trestle-workspace/")
    parser.add_argument("--ssp-name", help="Trestle SSP alias (default: derived from system name)")
    parser.add_argument(
        "--profile-label",
        default="fedramp-moderate",
        help="Profile label recorded in reports (default: fedramp-moderate)",
    )
    parser.add_argument(
        "--templates-dir",
        help="Directory containing fedramp-rev5-heading-map.json (default: plugin templates/)",
    )
    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="Replace existing draft catalog/profile/SSP models",
    )
    parser.add_argument(
        "--skip-validate",
        action="store_true",
        help="Skip trestle validate after drafting",
    )
    return parser.parse_args()


def slugify(value: str) -> str:
    slug = re.sub(r"[^a-z0-9]+", "-", value.lower()).strip("-")
    return (slug[:48] or "draft-ssp").strip("-")


def normalize_control_id(raw: str) -> str:
    return raw.lower().split("(")[0]


def load_section_rules(templates_dir: Path) -> list[tuple[re.Pattern[str], str, str, str]]:
    map_file = templates_dir / "fedramp-rev5-heading-map.json"
    rules: list[tuple[re.Pattern[str], str, str, str]] = []
    if not map_file.exists():
        return rules
    data = json.loads(map_file.read_text(encoding="utf-8"))
    for entry in data.get("section_rules", []):
        rules.append(
            (
                re.compile(entry["pattern"], re.IGNORECASE),
                entry["oscal_target"],
                entry.get("default_status", "mapped"),
                entry.get("fedramp_template_section", ""),
            )
        )
    return rules


def infer_system_name(sections: list[dict[str, Any]]) -> str:
    for section in sections:
        heading = section.get("heading", "")
        if re.search(r"(?i)system security plan", heading):
            name = re.sub(r"(?i)\bsystem security plan\b", "", heading).strip(" -–—")
            if name:
                return name
    for section in sections:
        heading = section.get("heading", "")
        if heading and not heading.lower().startswith("extracted "):
            return heading.splitlines()[0][:120]
    return "Draft System"


def full_excerpt(section: dict[str, Any], extracted_md: Path) -> str:
    excerpt = (section.get("excerpt") or "").strip()
    if excerpt:
        return excerpt
    if not extracted_md.exists():
        return ""
    lines = extracted_md.read_text(encoding="utf-8", errors="replace").splitlines()
    start = int(section.get("start_line", 1)) - 1
    end = int(section.get("end_line", len(lines)))
    return "\n".join(lines[start:end]).strip()


def map_sections(
    sections: list[dict[str, Any]],
    extracted_md: Path,
    rules: list[tuple[re.Pattern[str], str, str, str]],
) -> DraftPlan:
    system_name = infer_system_name(sections)
    plan = DraftPlan(
        system_name=system_name,
        ssp_alias=slugify(system_name),
        catalog_alias=f"{slugify(system_name)}-catalog",
        profile_alias=f"{slugify(system_name)}-profile",
        profile_label="fedramp-moderate",
    )

    for section in sections:
        heading = (section.get("heading") or "").strip()
        if not heading or heading.lower().startswith("extracted "):
            continue

        source_id = section.get("source_id", "")
        body = full_excerpt(section, extracted_md)
        control_match = CONTROL_HEADING_RE.match(heading)

        if control_match:
            control_id = normalize_control_id(control_match.group("id"))
            plan.control_ids.append(control_id)
            plan.sections.append(
                SectionMapping(
                    source_id=source_id,
                    heading=heading,
                    excerpt=body,
                    oscal_target=f"system-security-plan.control-implementation.implemented-requirements.{control_id}",
                    status="mapped" if body else "needs_review",
                    notes="Mapped from FedRAMP Appendix A-style control heading",
                    control_id=control_id,
                )
            )
            continue

        matched = False
        for pattern, target, default_status, fedramp_section in rules:
            if pattern.search(heading):
                status = default_status if body else "needs_review"
                plan.sections.append(
                    SectionMapping(
                        source_id=source_id,
                        heading=heading,
                        excerpt=body,
                        oscal_target=target,
                        status=status,
                        notes=f"FedRAMP template section: {fedramp_section}" if fedramp_section else "",
                    )
                )
                matched = True
                break

        if not matched and body:
            plan.sections.append(
                SectionMapping(
                    source_id=source_id,
                    heading=heading,
                    excerpt=body,
                    oscal_target="system-security-plan.metadata.remarks",
                    status="needs_review",
                    notes="Unmapped legacy heading; review manually",
                )
            )

    plan.control_ids = sorted(set(plan.control_ids))
    return plan


def run_trestle(cwd: Path, *args: str) -> None:
    result = subprocess.run(
        ["trestle", *args],
        cwd=cwd,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        sys.stderr.write(result.stderr or result.stdout)
        raise RuntimeError(f"trestle {' '.join(args)} failed with exit code {result.returncode}")


def remove_model(root: Path, model_type: str, alias: str) -> None:
    dirs = {
        "catalog": root / "catalogs" / alias,
        "profile": root / "profiles" / alias,
        "system-security-plan": root / "system-security-plans" / alias,
    }
    target = dirs.get(model_type)
    if target and target.exists():
        import shutil

        shutil.rmtree(target)


def patch_catalog(path: Path, plan: DraftPlan, mappings: list[SectionMapping]) -> None:
    catalog = json.loads(path.read_text(encoding="utf-8"))
    root = catalog["catalog"]
    root["metadata"]["title"] = f"{plan.system_name} draft catalog"
    controls: dict[str, dict[str, Any]] = {}
    for mapping in mappings:
        if not mapping.control_id:
            continue
        title = mapping.heading.split(maxsplit=1)[1] if " " in mapping.heading else mapping.control_id.upper()
        family = mapping.control_id.split("-")[0]
        controls[mapping.control_id] = {
            "id": mapping.control_id,
            "class": "SP800-53",
            "title": title[:120],
            "params": [],
            "props": [],
            "links": [],
            "parts": [
                {
                    "id": f"{mapping.control_id.replace('.', '_')}_smt",
                    "name": "statement",
                    "prose": (
                        f"Legacy SSP source section {mapping.source_id} mapped to {mapping.control_id}. "
                        "Replace with authoritative catalog content before authorization use."
                    ),
                }
            ],
        }
        controls[mapping.control_id].setdefault("_family", family)

    groups: dict[str, list[dict[str, Any]]] = {}
    for control in controls.values():
        family = control.pop("_family")
        groups.setdefault(family, []).append(control)

    root["groups"] = [
        {
            "id": family,
            "class": "SP800-53",
            "title": f"{family.upper()} controls (draft stubs)",
            "controls": group_controls,
        }
        for family, group_controls in sorted(groups.items())
    ]
    path.write_text(json.dumps(catalog, indent=2) + "\n", encoding="utf-8")


def patch_profile(path: Path, plan: DraftPlan) -> None:
    profile = json.loads(path.read_text(encoding="utf-8"))
    root = profile["profile"]
    root["metadata"]["title"] = f"{plan.system_name} draft profile ({plan.profile_label})"
    root["imports"] = [
        {
            "href": f"trestle://catalogs/{plan.catalog_alias}/catalog.json",
            "include-controls": [{"with-ids": plan.control_ids}] if plan.control_ids else [],
        }
    ]
    path.write_text(json.dumps(profile, indent=2) + "\n", encoding="utf-8")


def patch_ssp(path: Path, plan: DraftPlan, mappings: list[SectionMapping]) -> None:
    ssp = json.loads(path.read_text(encoding="utf-8"))
    root = ssp["system-security-plan"]
    root["metadata"]["title"] = f"{plan.system_name} System Security Plan"
    root["metadata"].setdefault("roles", [])
    root["import-profile"] = {"href": f"trestle://profiles/{plan.profile_alias}/profile.json"}

    sc = root["system-characteristics"]
    sc["system-name"] = plan.system_name
    sc["system-ids"][0]["id"] = slugify(plan.system_name)
    sc.setdefault("status", {"state": "operational"})

    description = next(
        (m.excerpt for m in mappings if m.oscal_target.endswith(".description") and "system-characteristics" in m.oscal_target),
        "",
    )
    boundary = next(
        (
            m.excerpt
            for m in mappings
            if m.oscal_target.endswith("authorization-boundary.description")
        ),
        "",
    )
    if description:
        sc["description"] = description
    if boundary:
        sc["authorization-boundary"]["description"] = boundary

    component = root["system-implementation"]["components"][0]
    component["title"] = plan.system_name
    component["description"] = description or "Draft component generated from legacy SSP extraction."
    component["status"]["state"] = "operational"
    component_uuid = component["uuid"]

    implemented = []
    for mapping in mappings:
        if not mapping.control_id or not mapping.excerpt:
            continue
        state = "implemented" if mapping.status == "mapped" else "planned"
        implemented.append(
            {
                "uuid": str(uuid.uuid4()),
                "control-id": mapping.control_id,
                "by-components": [
                    {
                        "uuid": str(uuid.uuid4()),
                        "component-uuid": component_uuid,
                        "description": mapping.excerpt,
                        "implementation-status": {"state": state},
                    }
                ],
            }
        )

    root["control-implementation"]["description"] = (
        "Draft control implementations mapped from legacy SSP extraction using FedRAMP Rev 5 heading conventions."
    )
    root["control-implementation"]["implemented-requirements"] = implemented

    remarks = [
        f"{mapping.heading}: {mapping.excerpt[:240]}"
        for mapping in mappings
        if mapping.status == "needs_review" and mapping.excerpt and not mapping.control_id
    ]
    if remarks:
        root.setdefault("metadata", {})["remarks"] = " | ".join(remarks[:6])

    path.write_text(json.dumps(ssp, indent=2) + "\n", encoding="utf-8")


def write_source_map(source_map: Path, sections: list[dict[str, Any]], mappings: list[SectionMapping], basename: str) -> None:
    mapping_by_id = {m.source_id: m for m in mappings}
    with source_map.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle)
        writer.writerow(
            [
                "source_id",
                "source_file",
                "page_or_section",
                "heading",
                "extracted_text_hash",
                "oscal_target",
                "status",
                "notes",
            ]
        )
        for section in sections:
            heading = section.get("heading", "")
            if heading.lower().startswith("extracted "):
                continue
            source_id = section.get("source_id", "")
            mapped = mapping_by_id.get(source_id)
            writer.writerow(
                [
                    source_id,
                    basename,
                    f"lines {section.get('start_line')}-{section.get('end_line')}",
                    heading,
                    section.get("text_sha256", ""),
                    mapped.oscal_target if mapped else "",
                    mapped.status if mapped else "pending",
                    mapped.notes if mapped else "Review and map to OSCAL target",
                ]
            )


def write_draft_summary(report_path: Path, plan: DraftPlan, ssp_path: Path, validation_status: str) -> None:
    mapped = sum(1 for m in plan.sections if m.status == "mapped")
    review = sum(1 for m in plan.sections if m.status == "needs_review")
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(
        "\n".join(
            [
                "# Draft SSP Summary",
                "",
                f"- System name: {plan.system_name}",
                f"- SSP alias: {plan.ssp_alias}",
                f"- Profile label: {plan.profile_label}",
                f"- Draft SSP: `{ssp_path}`",
                f"- Mapped sections: {mapped}",
                f"- needs_review sections: {review}",
                f"- Control IDs drafted: {', '.join(plan.control_ids) if plan.control_ids else '(none)'}",
                f"- Validation status: {validation_status}",
                "",
                "This draft uses FedRAMP Rev 5 SSP heading conventions for structure mapping only.",
                "Replace catalog stubs with authoritative FedRAMP/NIST OSCAL content before authorization use.",
                "Schema-valid OSCAL does not prove compliance effectiveness.",
                "",
            ]
        ),
        encoding="utf-8",
    )


def main() -> int:
    args = parse_args()
    workspace = Path(args.workspace).resolve()
    extracted_dir = workspace / "extracted"
    trestle_root = workspace / "trestle-workspace"
    sections_path = extracted_dir / "sections.json"
    source_map_path = extracted_dir / "source-map.csv"
    extracted_md = extracted_dir / "extracted.md"
    metadata_path = extracted_dir / "extracted-metadata.json"

    if not shutil_exists(trestle_root / ".trestle"):
        sys.stderr.write("draft-ssp-from-extraction: trestle workspace missing; run bootstrap-trestle-workspace.sh first\n")
        return 2
    if not sections_path.exists():
        sys.stderr.write("draft-ssp-from-extraction: missing extracted/sections.json\n")
        return 2
    if subprocess.run(["bash", "-lc", "command -v trestle"], capture_output=True).returncode != 0:
        sys.stderr.write(
            "draft-ssp-from-extraction: Compliance Trestle CLI not found. Install with: pip install compliance-trestle\n"
        )
        return 5

    script_dir = Path(__file__).resolve().parent
    templates_dir = Path(args.templates_dir) if args.templates_dir else script_dir.parent / "templates"
    sections = json.loads(sections_path.read_text(encoding="utf-8")).get("sections", [])
    basename = (
        json.loads(metadata_path.read_text(encoding="utf-8")).get("input_file", "legacy-source")
        if metadata_path.exists()
        else "legacy-source"
    )

    plan = map_sections(sections, extracted_md, load_section_rules(templates_dir))
    if args.ssp_name:
        plan.ssp_alias = slugify(args.ssp_name)
    plan.profile_label = args.profile_label

    if args.overwrite:
        for model_type, alias in (
            ("catalog", plan.catalog_alias),
            ("profile", plan.profile_alias),
            ("system-security-plan", plan.ssp_alias),
        ):
            remove_model(trestle_root, model_type, alias)

    run_trestle(trestle_root, "create", "-t", "catalog", "-o", plan.catalog_alias)
    run_trestle(trestle_root, "create", "-t", "profile", "-o", plan.profile_alias)
    run_trestle(trestle_root, "create", "-t", "system-security-plan", "-o", plan.ssp_alias)

    catalog_path = trestle_root / "catalogs" / plan.catalog_alias / "catalog.json"
    profile_path = trestle_root / "profiles" / plan.profile_alias / "profile.json"
    ssp_path = trestle_root / "system-security-plans" / plan.ssp_alias / "system-security-plan.json"

    patch_catalog(catalog_path, plan, plan.sections)
    patch_profile(profile_path, plan)
    patch_ssp(ssp_path, plan, plan.sections)
    write_source_map(source_map_path, sections, plan.sections, basename)

    validation_status = "skipped"
    if not args.skip_validate:
        result = subprocess.run(
            ["trestle", "validate", "-t", "system-security-plan", "-n", plan.ssp_alias],
            cwd=trestle_root,
            capture_output=True,
            text=True,
        )
        if result.returncode != 0:
            sys.stderr.write(result.stderr or result.stdout)
            validation_status = "fail"
            write_draft_summary(workspace / "reports" / "draft-summary.md", plan, ssp_path, validation_status)
            return 3
        validation_status = "pass"

    write_draft_summary(workspace / "reports" / "draft-summary.md", plan, ssp_path, validation_status)
    print(f"draft-ssp-from-extraction: drafted SSP {plan.ssp_alias}")
    print(f"  ssp: {ssp_path}")
    print(f"  source map: {source_map_path}")
    print(f"  summary: {workspace / 'reports' / 'draft-summary.md'}")
    print(f"  validation: {validation_status}")
    return 0


def shutil_exists(path: Path) -> bool:
    return path.exists()


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except RuntimeError as exc:
        sys.stderr.write(f"draft-ssp-from-extraction: {exc}\n")
        raise SystemExit(3) from exc
