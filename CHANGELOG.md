# Changelog

All notable changes to the compliance-trestle Claude Code plugin are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-07-21

### Added
- Draft OSCAL SSP pipeline: `draft-ssp-from-extraction` script produces a schema-valid draft SSP from extracted legacy sections using the FedRAMP Rev 5 heading map
- `fetch-oscal-baseline` script and command to download and import the NIST SP 800-53 Rev 5 catalog and FedRAMP Rev 5 baseline profiles (low, moderate, high, li-saas) with local caching and mirror/air-gap overrides
- FedRAMP 2026 Consolidated Rules fetch and 20x KSI coverage reporting (`ksi-coverage` command, Markdown and JSON reports)
- Native Cursor support: `CURSOR.md`, project skills under `.cursor/skills/`, and scoped rules under `.cursor/rules/` for import workspaces and OSCAL JSON edits
- Explicit Cursor workflow skills: import-legacy-ssp, validate-oscal-package, review-oscal-mappings, workspace-validate
- GitHub Actions `validate` workflow running the full test suite on push and pull request
- New test suites: `test:cursor-support` and `test:draft-ssp` (with live Trestle integration run when Trestle is installed)

### Fixed
- Agent compatibility matrix no longer references non-existent Claude-specific docs; headless shell row reflects available extraction, review-queue, and validation scripts
- Draft SSP integration test canonicalizes macOS temp paths so Trestle workspace validation passes locally

## [0.1.0] - 2026-02-13

### Added
- Initial release of the compliance-trestle Claude Code plugin
- 10 skills: workspace, authoring workflow, OSCAL models, control implementation, assessment, POA&M, validation, task system, Jinja templating, governance
- Compliance pipeline skill — end-to-end pipeline covering GRC personas, artifact ownership, per-persona workflows, component definition bridge, multi-repo coordination, CI/CD integration, and Compliance-to-Policy (C2P)
- 9 agents: compliance-reviewer, ssp-author, control-mapper, workspace-explorer, assessment-reviewer, poam-manager, validation-assistant, data-importer, pipeline-architect
- 41 slash commands across workspace, author, model, task, and workflow categories
- 3 event hooks: session-start workspace detection, post-tool-use validation reminder, pre-tool-use OSCAL edit warning
- Worked examples and step-by-step walkthroughs across all skills
- Troubleshooting sections with common errors and solutions
- Cross-references between related skills
- Per-project configuration via `.claude/compliance-trestle.local.md`
