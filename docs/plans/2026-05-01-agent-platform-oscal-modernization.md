# Agent Platform + OSCAL Document Modernization Implementation Plan

> Historical plan snapshot from 2026-05-01. Paths such as `plugins/oscal`, `plugins/fedramp-ssp`, `docs/CLAUDE-COWORK.md`, `docs/ARCHITECTURE.md`, and `ROADMAP.md` can be absent now. Use `AGENTS.md`, `docs/OSCAL-DOCUMENT-WORKBENCH.md`, and `docs/AGENT-COMPATIBILITY.md` for the current layout. Do not treat this plan as current product documentation.

> **For Hermes:** Use subagent-driven-development skill to implement this plan task-by-task.

**Goal:** Reposition this repository from a Claude Code-only GRC plugin marketplace into a portable GRC/OSCAL engineering toolkit that works across top coding agents, desktop agent apps, and agent skill/plugin harnesses while making legacy PDF/DOCX SSP-to-OSCAL workflows simple and reliable.

**Architecture:** Keep `plugins/` as the canonical source of GRC capabilities, then add thin adapters for each agent runtime. Introduce a portable skill-pack layer, explicit command contracts, documentation for each supported agent, and a document-to-OSCAL ingestion workflow centered on Compliance Trestle plus the existing `oscal` and `fedramp-ssp` plugins.

**Tech Stack:** Markdown skills/commands, Claude Code plugin manifests, agent adapter docs (`AGENTS.md`, `GEMINI.md`, opencode/Codex guidance), Node.js/Bash scripts, Compliance Trestle CLI, OSCAL CLI, DOCX/PDF extraction tools, JSON Schema contract tests, GitHub Actions.

---

## 0. Product direction and naming

### New positioning

Current positioning:
- Claude Code plugin marketplace for Compliance Trestle Community workflows.

Target positioning:
- Agent-portable GRC engineering toolkit for compliance-as-code, OSCAL document engineering, evidence collection, and legacy document modernization.
- Claude Code remains a first-class distribution channel, but not the only one.
- Skills and workflows should be usable from Claude Code, Claude Work/Cowork desktop-style workflows, OpenAI Codex CLI/app, OpenCode, Gemini CLI, Cursor/Windsurf-style coding agents, and generic agent skill folders.

### Primary user promise

A user should be able to say to their coding agent:

```text
Take this old SSP PDF/DOCX, convert it into OSCAL with Compliance Trestle, validate it, create a manageable workspace, and help me keep it current with evidence, findings, POA&Ms, and framework mappings.
```

The repo should give the agent all instructions, scripts, prompts, schemas, examples, and validation commands needed to do that safely.

### Non-goals

- Do not build a full GRC SaaS platform.
- Do not copy licensed framework text.
- Do not require one specific LLM vendor.
- Do not make the agent invent OSCAL mappings without traceable source evidence.
- Do not hide Compliance Trestle; embrace it as the durable OSCAL authoring engine.

---

## 1. Current-state findings from inspection

### Observed structure

- Root docs currently describe a Claude Code plugin marketplace.
- `.claude-plugin/marketplace.json` is the primary marketplace manifest.
- `plugins/oscal` wraps `oscal-cli` with `setup`, `validate`, and `convert` commands.
- `plugins/fedramp-ssp` wraps FedRAMP DOCX SSP-to-OSCAL conversion.
- Root `commands/`, `skills/`, and `agents/` are the hub for Compliance Trestle workspace authoring, validation, assessment, and POA&M workflows.
- `docs/CLAUDE-COWORK.md` exists for desktop/file-oriented compatibility, but the root README still leads with Claude Code.
- `docs/ARCHITECTURE.md` explicitly says this is shaped as a Claude Code plugin marketplace and has a non-goal saying everything is operator-invoked via Claude Code.
- `ROADMAP.md` already calls out Document Transformation as an Architecture v2 category.

### Main gaps to close

1. Brand and docs are too Claude-specific.
2. No first-class portable skill-pack format.
3. No root `AGENTS.md` / `GEMINI.md` / opencode guidance for generic coding agents.
4. OSCAL workflows exist, but legacy PDF/DOCX SSP ingestion is not documented as the main path.
5. Compliance Trestle is referenced, but not installed, tested, or taught as the core document management loop.
6. No adapter/compatibility matrix for Claude Code, Claude Work/Cowork, Codex, OpenCode, Gemini CLI, Cursor, Windsurf, or generic desktop agent apps.
7. No golden fixtures that prove old docs can become validated OSCAL artifacts.
8. Marketplace manifest only covers Claude Code plugin distribution.
9. The repo name and package metadata still say `compliance-trestle-skills` / `claude-code-plugin`.

---

## 2. Target architecture

```text
                      user document / system context
                     PDF, DOCX, Markdown, evidence
                                  │
                                  ▼
                    document ingestion workspace
              text extraction + source traceability map
                                  │
                                  ▼
                    Compliance Trestle project
              catalogs, profiles, SSP, component defs,
                   assessment results, POA&M
                                  │
                                  ▼
                    validation + normalization layer
               oscal-cli, trestle validate, schemas
                                  │
                                  ▼
               Compliance Trestle portable capabilities
      skills, commands, prompts, scripts, schemas, examples
             ┌──────────────┬─────────────┬───────────────┐
             ▼              ▼             ▼               ▼
       Claude Code      Codex CLI      Gemini CLI       OpenCode
       plugin/skills    AGENTS.md      GEMINI.md        agent docs
             ▼              ▼             ▼               ▼
       desktop agent apps / cloud plugin packages / generic skills
```

Canonical source remains `plugins/`. New adapter layers should be generated or lightly maintained from canonical content where possible.

---

## 3. Proposed repository additions

### 3.1 Portable agent docs

Create:

- `AGENTS.md`
  - Generic instructions for coding agents and Codex-compatible tools.
  - Points agents to portable skills, docs, scripts, and safety rules.
  - Explains OSCAL/Trestle workflows and exact commands.

- `GEMINI.md`
  - Gemini CLI-specific project instructions.
  - Mirrors `AGENTS.md` but uses Gemini phrasing and command expectations.

- `OPENCODE.md`
  - OpenCode-specific instructions.
  - Explains how to load/use skills as local instructions.

- `CURSOR.md` or `.cursor/rules/compliance-trestle.mdc`
  - Cursor/Windsurf-style rules for repository-level agent context.

- `docs/AGENT-COMPATIBILITY.md`
  - Compatibility matrix across Claude Code, Claude Work/Cowork, Codex CLI/app, OpenCode, Gemini CLI, Cursor, Windsurf, and generic desktop apps.

- `docs/PORTABLE-SKILLS.md`
  - Defines the portable skill-pack contract independent of Claude Code.

### 3.2 Portable skill packs

Create:

```text
agent-skills/
├── README.md
├── manifest.json
├── oscal-document-engineering/
│   ├── SKILL.md
│   ├── references/
│   │   ├── trestle-workflow.md
│   │   ├── legacy-doc-ingestion.md
│   │   └── oscal-validation.md
│   └── templates/
│       ├── ssp-import-plan.md
│       ├── control-implementation-record.md
│       └── source-traceability-map.csv
├── compliance-trestle/
│   ├── SKILL.md
│   ├── references/
│   │   ├── install.md
│   │   ├── authoring-loop.md
│   │   └── troubleshooting.md
│   └── scripts/
│       └── bootstrap-trestle-project.sh
├── grc-evidence-engineering/
│   └── SKILL.md
├── framework-crosswalks/
│   └── SKILL.md
└── poam-management/
    └── SKILL.md
```

Purpose:
- These are not Claude-only.
- They are directly copyable into agent skill folders for tools that support local skills.
- They can be referenced by `AGENTS.md`, `GEMINI.md`, and desktop app docs.
- Claude plugin skills can either point to them or be synchronized from them later.

### 3.3 Agent adapter packages

Create:

```text
adapters/
├── README.md
├── claude-code/
│   ├── README.md
│   └── marketplace-notes.md
├── claude-work/
│   └── README.md
├── codex/
│   ├── README.md
│   └── AGENTS.template.md
├── gemini-cli/
│   ├── README.md
│   └── GEMINI.template.md
├── opencode/
│   └── README.md
├── cursor-windsurf/
│   └── README.md
└── generic-desktop-agent/
    └── README.md
```

Each adapter doc must answer:
- How do I install or expose this repo to the agent?
- Which instruction file does this agent read?
- How do I run the OSCAL/Trestle flow?
- How do I validate outputs?
- What does not work natively in this harness?

### 3.4 Document transformation plugin

Add a first-class plugin category for document-to-OSCAL work:

```text
plugins/document-transform/
└── oscal-document-workbench/
    ├── .claude-plugin/plugin.json
    ├── README.md
    ├── commands/
    │   ├── ingest-ssp.md
    │   ├── extract-legacy-doc.md
    │   ├── build-trestle-workspace.md
    │   ├── validate-oscal-package.md
    │   └── update-ssp-from-evidence.md
    ├── skills/
    │   └── oscal-document-workbench-expert/
    │       └── SKILL.md
    ├── scripts/
    │   ├── extract-legacy-doc.sh
    │   ├── bootstrap-trestle-workspace.sh
    │   ├── validate-oscal-package.sh
    │   └── summarize-source-map.js
    └── templates/
        ├── source-map.csv
        ├── ssp-import-plan.md
        └── oscal-package-checklist.md
```

This should become the easiest entry point for the old-document conversion promise.

### 3.5 Compliance Trestle integration

Add:

- `plugins/compliance-trestle/` or fold into `plugins/document-transform/oscal-document-workbench`.
- Scripts should install/check `trestle`, initialize a workspace, import catalogs/profiles, split/merge markdown, validate OSCAL, and run common authoring loops.
- Docs should prefer repeatable commands over hand-wavy agent instructions.

Suggested commands:

```text
/compliance-trestle:setup
/compliance-trestle:init-workspace
/compliance-trestle:import-oscal
/compliance-trestle:author-ssp
/compliance-trestle:validate
/compliance-trestle:export
```

If fewer plugins are preferred, implement these as commands under `oscal-document-workbench`.

### 3.6 Examples and fixtures

Create:

```text
examples/
├── legacy-ssp-to-oscal/
│   ├── README.md
│   ├── input/
│   │   ├── sample-ssp.md
│   │   └── source-map.csv
│   ├── expected/
│   │   ├── ssp.json
│   │   └── validation-report.json
│   └── scripts/
│       └── run-example.sh
└── agent-prompts/
    ├── codex-legacy-ssp-to-oscal.md
    ├── gemini-legacy-ssp-to-oscal.md
    ├── opencode-legacy-ssp-to-oscal.md
    └── claude-code-legacy-ssp-to-oscal.md
```

Do not commit real sensitive SSPs. Use synthetic or sanitized examples.

---

## 4. Legacy document to OSCAL workflow

### Happy path

1. User places old PDF/DOCX/Markdown SSP in a workspace:

```text
workspaces/acme-ssp-import/input/acme-old-ssp.docx
```

2. Agent runs extraction:

```bash
bash plugins/document-transform/oscal-document-workbench/scripts/extract-legacy-doc.sh \
  workspaces/acme-ssp-import/input/acme-old-ssp.docx \
  --output workspaces/acme-ssp-import/extracted
```

3. Agent creates a source traceability map:

```text
source_id,source_file,page_or_section,heading,extracted_text_hash,oscal_target,status,notes
DOC-001,acme-old-ssp.docx,3,Information System Name,sha256:...,metadata.title,mapped,
DOC-002,acme-old-ssp.docx,14,AC-2 Account Management,sha256:...,control-implementation.ac-2,mapped,
```

4. Agent initializes Trestle workspace:

```bash
bash plugins/document-transform/oscal-document-workbench/scripts/bootstrap-trestle-workspace.sh \
  workspaces/acme-ssp-import \
  --profile fedramp-moderate \
  --oscal-version 1.1.3
```

5. Agent drafts SSP sections into Trestle markdown / OSCAL structure.

6. Agent validates:

```bash
trestle validate -f workspaces/acme-ssp-import/trestle-workspace/system-security-plans/acme/ssp.json
bash plugins/oscal/scripts/validate.sh workspaces/acme-ssp-import/trestle-workspace/system-security-plans/acme/ssp.json
```

7. Agent produces an import report:

```text
workspaces/acme-ssp-import/reports/import-summary.md
workspaces/acme-ssp-import/reports/validation-report.json
workspaces/acme-ssp-import/reports/unmapped-items.md
```

8. User reviews unmapped content and control implementation uncertainty.

### Required guardrails

- Every mapped OSCAL field must link back to source text or a user-supplied assertion.
- Agent must mark uncertain mappings as `needs_review`, not silently invent content.
- Validation success is structural, not an authorization decision.
- Generated OSCAL should be reviewed by a qualified GRC/security owner.
- PDF extraction should preserve page references when possible.
- DOCX extraction should preserve heading hierarchy when possible.

---

## 5. Detailed task plan

### Phase 1: Reposition root docs without breaking Claude Code

#### Task 1.1: Update root README positioning

**Objective:** Make the README describe a vendor-neutral agent toolkit while retaining Claude Code install instructions.

**Files:**
- Modify: `README.md`
- Test: markdown/link check after edits

**Steps:**
1. Change line 9 style copy from “Open-source GRC automation for Claude Code” to “Open-source GRC and OSCAL engineering for coding agents.”
2. Add a “Supported agent harnesses” section near install:
   - Claude Code plugin marketplace
   - Claude Work/Cowork file-oriented workflows
   - OpenAI Codex CLI/app via `AGENTS.md`
   - Gemini CLI via `GEMINI.md`
   - OpenCode via `OPENCODE.md`
   - Cursor/Windsurf/generic desktop apps via portable skills
3. Add a “Legacy SSP/PDF/DOCX to OSCAL” workflow section.
4. Keep existing Claude Code install snippet under “Claude Code install.”
5. Add links to new docs once created.
6. Run markdown validation.

**Verification:**
- README no longer implies Claude Code is the only runtime.
- Claude Code users can still find marketplace install commands in under 60 seconds.

#### Task 1.2: Update package metadata

**Objective:** Make npm/package metadata agent-neutral.

**Files:**
- Modify: `package.json`

**Steps:**
1. Change `description` from Claude-specific to agent-portable.
2. Add keywords: `coding-agents`, `agent-skills`, `compliance-trestle`, `oscal-ssp`, `codex`, `gemini-cli`, `opencode`.
3. Keep `claude-code-plugin` keyword for discoverability.

**Verification:**
- `node -e "JSON.parse(require('fs').readFileSync('package.json','utf8')); console.log('ok')"` passes.

#### Task 1.3: Update architecture docs

**Objective:** Replace Claude-only architecture claims with portable adapter model.

**Files:**
- Modify: `docs/ARCHITECTURE.md`
- Modify: `docs/ARCHITECTURE-V2-RFC.md`
- Modify: `ROADMAP.md`

**Steps:**
1. Update opening architecture statement to “agent-portable toolkit with Claude Code marketplace adapter.”
2. Add adapter layer diagram.
3. Replace non-goal “Everything is operator-invoked via Claude Code” with “No hosted runtime required; workflows are local agent/CLI invoked unless a specific adapter provides cloud execution.”
4. Expand roadmap Document Transformation item into OSCAL Document Workbench.

**Verification:**
- Search for Claude-only claims and ensure they are either still accurate for Claude adapter or updated.

---

### Phase 2: Add generic agent instruction files

#### Task 2.1: Create `AGENTS.md`

**Objective:** Give Codex-compatible and generic coding agents exact repo instructions.

**Files:**
- Create: `AGENTS.md`

**Content requirements:**
- Explain repository purpose in agent-neutral terms.
- State that `plugins/` is canonical source.
- List safe validation commands.
- Include legacy SSP-to-OSCAL workflow.
- Include “do not invent compliance facts” guardrail.
- Include how to use `agent-skills/`.
- Include test commands:
  - `npm run test:agent-skills`
  - `npm run test:agent-adapters`
  - `npm run test:oscal-document-workbench`
  - targeted script validation for OSCAL/Trestle once implemented.

**Verification:**
- A fresh coding agent can read only `AGENTS.md` and know how to proceed.

#### Task 2.2: Create `GEMINI.md`

**Objective:** Add Gemini CLI-specific repo context.

**Files:**
- Create: `GEMINI.md`

**Content requirements:**
- Mirror `AGENTS.md` but use concise Gemini CLI conventions.
- Point to `agent-skills/` and `docs/AGENT-COMPATIBILITY.md`.
- Include exact shell commands.

**Verification:**
- No Claude-specific slash-command dependency is required to understand workflows.

#### Task 2.3: Create `OPENCODE.md`

**Objective:** Add OpenCode-specific setup and usage guidance.

**Files:**
- Create: `OPENCODE.md`

**Content requirements:**
- Explain how to open repo, load instructions, and call scripts directly.
- Include the old-doc-to-OSCAL prompt template.
- Explain that Claude plugin commands map to shell scripts or markdown instructions.

**Verification:**
- OpenCode users have a direct starting point from root.

#### Task 2.4: Create Cursor/Windsurf rules

**Objective:** Support IDE-style agents that read project rules.

**Files:**
- Create: `.cursor/rules/compliance-trestle.mdc`
- Optional create: `.windsurf/rules/compliance-trestle.md`

**Content requirements:**
- Short, high-signal rules.
- Reference `AGENTS.md` for full instructions.
- Include OSCAL uncertainty/source-traceability guardrails.

**Verification:**
- Rules are short enough not to overload IDE agents.

---

### Phase 3: Define portable skill-pack contract

#### Task 3.1: Create `docs/PORTABLE-SKILLS.md`

**Objective:** Define a skill format that is not tied to Claude Code.

**Files:**
- Create: `docs/PORTABLE-SKILLS.md`

**Content requirements:**
- Directory structure.
- Required `SKILL.md` frontmatter fields.
- Optional `references/`, `templates/`, `scripts/`, `assets/` folders.
- Runtime assumptions.
- How Claude plugin skills relate to portable skills.
- How to package/copy skills into agent tools.

**Verification:**
- A contributor can add a new portable skill without asking maintainers.

#### Task 3.2: Create `agent-skills/manifest.json`

**Objective:** Add index of portable skills.

**Files:**
- Create: `agent-skills/manifest.json`
- Create: `agent-skills/README.md`

**Schema draft:**

```json
{
  "name": "compliance-trestle-agent-skills",
  "version": "0.1.0",
  "skills": [
    {
      "name": "oscal-document-engineering",
      "path": "./oscal-document-engineering",
      "description": "Convert, validate, and maintain OSCAL documents from legacy source material.",
      "tags": ["oscal", "ssp", "compliance-trestle", "document-transformation"]
    }
  ]
}
```

**Verification:**
- JSON parses.
- README explains how to use skills in generic agents.

#### Task 3.3: Add `oscal-document-engineering` portable skill

**Objective:** Create the core user-facing skill for old docs to OSCAL.

**Files:**
- Create: `agent-skills/oscal-document-engineering/SKILL.md`
- Create: `agent-skills/oscal-document-engineering/references/legacy-doc-ingestion.md`
- Create: `agent-skills/oscal-document-engineering/references/oscal-validation.md`
- Create: `agent-skills/oscal-document-engineering/templates/ssp-import-plan.md`
- Create: `agent-skills/oscal-document-engineering/templates/source-traceability-map.csv`

**Content requirements:**
- Step-by-step legacy PDF/DOCX to OSCAL process.
- Trestle workspace loop.
- Mapping rules for SSP sections and controls.
- Validation rules.
- Source traceability requirements.
- Review checklist.

**Verification:**
- Skill can be used without Claude Code commands.

#### Task 3.4: Add `compliance-trestle` portable skill

**Objective:** Teach agents how to use Compliance Trestle reliably.

**Files:**
- Create: `agent-skills/compliance-trestle/SKILL.md`
- Create: `agent-skills/compliance-trestle/references/install.md`
- Create: `agent-skills/compliance-trestle/references/authoring-loop.md`
- Create: `agent-skills/compliance-trestle/references/troubleshooting.md`
- Create: `agent-skills/compliance-trestle/scripts/bootstrap-trestle-project.sh`

**Content requirements:**
- Install checks.
- Workspace init.
- Catalog/profile/SSP organization.
- Split/merge markdown loop.
- Validate and export.
- Common errors and fixes.

**Verification:**
- Bootstrap script is shellcheck-clean where shellcheck is available.

---

### Phase 4: Build OSCAL Document Workbench plugin

#### Task 4.1: Add plugin skeleton

**Objective:** Create first-class plugin for document transformation.

**Files:**
- Create: `plugins/document-transform/oscal-document-workbench/.claude-plugin/plugin.json`
- Create: `plugins/document-transform/oscal-document-workbench/README.md`
- Create directories: `commands/`, `skills/`, `scripts/`, `templates/`

**Plugin metadata:**
- name: `oscal-document-workbench`
- description: “Convert legacy SSP/PDF/DOCX source material into traceable, validated OSCAL workspaces using Compliance Trestle and OSCAL CLI.”
- version: `0.1.0`

**Verification:**
- Manifest JSON parses.

#### Task 4.2: Add command docs

**Objective:** Provide user-facing command instructions for Claude Code and as docs for other agents.

**Files:**
- Create: `commands/ingest-ssp.md`
- Create: `commands/extract-legacy-doc.md`
- Create: `commands/build-trestle-workspace.md`
- Create: `commands/validate-oscal-package.md`
- Create: `commands/update-ssp-from-evidence.md`

**Content requirements:**
- Each command includes purpose, arguments, examples, outputs, exit codes, and safety notes.
- Commands must work as plain markdown instructions in non-Claude harnesses.

**Verification:**
- Each command has exact underlying script invocation.

#### Task 4.3: Add workbench skill

**Objective:** Make the document workbench usable by agents.

**Files:**
- Create: `plugins/document-transform/oscal-document-workbench/skills/oscal-document-workbench-expert/SKILL.md`

**Content requirements:**
- Reference portable skill content or duplicate carefully.
- Include guardrails and review checklist.
- Include how it composes with root Compliance Trestle commands, external OSCAL validators, and reviewed evidence packages.

**Verification:**
- Skill frontmatter parses like existing skills.

#### Task 4.4: Implement extraction script

**Objective:** Extract text from PDF/DOCX/MD/TXT into normalized markdown and source map skeleton.

**Files:**
- Create: `plugins/document-transform/oscal-document-workbench/scripts/extract-legacy-doc.sh`

**Implementation requirements:**
- Accept input path and `--output` directory.
- Support `.docx`, `.pdf`, `.md`, `.txt`.
- Prefer available tools in this order:
  - DOCX: `pandoc`, fallback Python `python-docx` if installed, otherwise fail with install guidance.
  - PDF: `pdftotext`, fallback `python -m pymupdf` if installed, otherwise fail with install guidance.
  - MD/TXT: copy with metadata.
- Produce:
  - `extracted.md`
  - `source-map.csv`
  - `extract-manifest.json`
- Exit codes:
  - `0` success
  - `2` bad args/input unreadable
  - `5` missing extractor dependency
  - `6` unsupported format

**Verification:**
- Test with synthetic markdown fixture first.
- Add PDF/DOCX fixtures only if generation is easy and license-safe.

#### Task 4.5: Implement Trestle bootstrap script

**Objective:** Create repeatable Trestle workspace setup.

**Files:**
- Create: `plugins/document-transform/oscal-document-workbench/scripts/bootstrap-trestle-workspace.sh`

**Implementation requirements:**
- Check `trestle` availability.
- Create workspace directory.
- Run Trestle init commands.
- Add README/checklist inside workspace.
- Optionally pull known catalogs/profiles if flags request them.
- Never overwrite existing workspace unless `--overwrite` is passed.

**Verification:**
- Running twice without `--overwrite` fails safely.

#### Task 4.6: Implement validation script

**Objective:** Validate package with both Trestle and oscal-cli where available.

**Files:**
- Create: `plugins/document-transform/oscal-document-workbench/scripts/validate-oscal-package.sh`

**Implementation requirements:**
- Accept path to OSCAL file or package directory.
- Run `trestle validate` if available.
- Run `plugins/oscal/scripts/validate.sh` if configured.
- Write JSON-ish validation summary.
- Exit nonzero on structural validation failure.

**Verification:**
- Bad fixture fails.
- Minimal valid fixture passes or is explicitly marked pending if real fixture is not ready.

---

### Phase 5: Register plugin and adapters

#### Task 5.1: Register workbench in marketplace

**Objective:** Make Claude Code users discover the new plugin.

**Files:**
- Modify: `.claude-plugin/marketplace.json`

**Steps:**
1. Add `oscal-document-workbench` entry.
2. Include command list.
3. Set category/tags if marketplace supports them.

**Verification:**
- JSON parses.
- Existing validation workflow passes.

#### Task 5.2: Update plugin map in README and architecture

**Objective:** Surface the new Document Transformation category.

**Files:**
- Modify: `README.md`
- Modify: `docs/ARCHITECTURE.md`
- Modify: `ROADMAP.md`

**Verification:**
- User can discover legacy doc conversion from README, not just plugin internals.

#### Task 5.3: Add adapter docs

**Objective:** Make each target harness usable.

**Files:**
- Create: `adapters/README.md`
- Create: `adapters/claude-code/README.md`
- Create: `adapters/claude-work/README.md`
- Create: `adapters/codex/README.md`
- Create: `adapters/gemini-cli/README.md`
- Create: `adapters/opencode/README.md`
- Create: `adapters/cursor-windsurf/README.md`
- Create: `adapters/generic-desktop-agent/README.md`

**Verification:**
- Every adapter doc includes “install/load,” “run old SSP to OSCAL,” and “validate.”

---

### Phase 6: Examples and tests

#### Task 6.1: Add synthetic legacy SSP example

**Objective:** Provide a safe demo that exercises the document flow.

**Files:**
- Create: `examples/legacy-ssp-to-oscal/README.md`
- Create: `examples/legacy-ssp-to-oscal/input/sample-ssp.md`
- Create: `examples/legacy-ssp-to-oscal/input/source-map.csv`
- Create: `examples/legacy-ssp-to-oscal/scripts/run-example.sh`

**Verification:**
- Example script runs extraction and produces expected files.

#### Task 6.2: Add prompt templates for each agent

**Objective:** Give users copy-paste prompts.

**Files:**
- Create: `examples/agent-prompts/claude-code-legacy-ssp-to-oscal.md`
- Create: `examples/agent-prompts/codex-legacy-ssp-to-oscal.md`
- Create: `examples/agent-prompts/gemini-legacy-ssp-to-oscal.md`
- Create: `examples/agent-prompts/opencode-legacy-ssp-to-oscal.md`

**Prompt requirements:**
- Reference source file path.
- Ask agent to preserve source traceability.
- Require validation.
- Require review report and unmapped content report.

**Verification:**
- Prompt does not assume Claude slash commands except Claude-specific one.

#### Task 6.3: Add validation tests

**Objective:** Add CI checks for new files and scripts.

**Files:**
- Create: `tests/validate-agent-skills.sh`
- Create: `tests/validate-agent-adapters.sh`
- Create: `tests/validate-oscal-document-workbench.sh`
- Modify: `package.json` scripts
- Modify or create GitHub workflow if needed

**Test requirements:**
- JSON manifests parse.
- Required files exist.
- Shell scripts pass `bash -n`.
- Command markdown contains “How to run” and “Exit codes.”
- Portable skills have frontmatter with name and description.

**Verification:**
- `npm run test:agent-skills` passes.
- `npm run test:agent-adapters` passes.
- `npm run test:oscal-document-workbench` passes.

---

### Phase 7: Update existing OSCAL and FedRAMP SSP plugins

#### Task 7.1: Update `plugins/oscal` docs

**Objective:** Make `oscal` plugin clearly part of the larger Trestle workflow.

**Files:**
- Modify: `plugins/oscal/skills/oscal-expert/SKILL.md`
- Modify: `plugins/oscal/commands/convert.md`
- Modify: `plugins/oscal/commands/validate.md`
- Modify: `plugins/oscal/commands/setup.md`

**Content requirements:**
- Link to OSCAL Document Workbench.
- Clarify when to use Trestle vs raw `oscal-cli`.
- Clarify supported OSCAL versions.

**Verification:**
- No contradiction with new workbench docs.

#### Task 7.2: Update `plugins/fedramp-ssp` docs

**Objective:** Position FedRAMP DOCX conversion as one path inside the broader legacy document workbench.

**Files:**
- Modify: `plugins/fedramp-ssp/skills/fedramp-ssp-expert/SKILL.md`
- Modify: `plugins/fedramp-ssp/commands/convert.md`
- Modify: `plugins/fedramp-ssp/commands/setup.md`

**Content requirements:**
- Explain when FedRAMP-specific converter is better than generic extraction.
- Link to source traceability and validation steps.

**Verification:**
- Users understand FedRAMP official templates vs arbitrary old SSPs.

---

### Phase 8: Compatibility matrix and release prep

#### Task 8.1: Create compatibility matrix

**Objective:** Show what works where.

**Files:**
- Create: `docs/AGENT-COMPATIBILITY.md`

**Matrix columns:**
- Harness
- Native install method
- Reads repo instructions from
- Supports skills/plugins directly?
- Uses slash commands?
- Best workflow for old SSP-to-OSCAL
- Limitations

**Rows:**
- Claude Code
- Claude Work/Cowork
- OpenAI Codex CLI
- Codex app
- Gemini CLI
- OpenCode
- Cursor
- Windsurf
- Generic desktop agent app
- CI/headless shell

**Verification:**
- README links to it.

#### Task 8.2: Add migration guide

**Objective:** Help existing users understand the shift.

**Files:**
- Create: `docs/MIGRATING-FROM-CLAUDE-ONLY.md`

**Content requirements:**
- Existing Claude Code plugin commands still work.
- New agent-neutral docs and portable skills are additive.
- How to move from old Compliance Trestle skills to this repo.
- How to choose between Claude plugin, portable skill, and direct script usage.

**Verification:**
- No existing install instructions are removed without replacement.

#### Task 8.3: Add changelog entry

**Objective:** Document modernization direction.

**Files:**
- Modify: `CHANGELOG.md`

**Content requirements:**
- Added agent-portable skill packs.
- Added OSCAL Document Workbench plan/plugin.
- Added generic agent adapters.
- Updated docs from Claude-only to agent-portable.

**Verification:**
- Changelog reflects compatibility expectations.

---

## 6. Suggested implementation order

1. Docs repositioning first: README, ARCHITECTURE, ROADMAP.
2. Root agent instruction files: `AGENTS.md`, `GEMINI.md`, `OPENCODE.md`.
3. Portable skill contract and first two skills.
4. OSCAL Document Workbench plugin skeleton and command docs.
5. Scripts for extraction, Trestle bootstrap, validation.
6. Examples and prompt templates.
7. Tests and CI.
8. Existing plugin doc updates.
9. Compatibility and migration docs.
10. Final pass for naming, links, and marketplace manifest.

---

## 7. Acceptance criteria

The update is complete when all of these are true:

- Root README says the project supports multiple agent harnesses, not just Claude Code.
- Claude Code plugin marketplace install still works and is documented.
- `AGENTS.md`, `GEMINI.md`, and `OPENCODE.md` exist and contain direct usable instructions.
- `agent-skills/` contains portable skills for OSCAL document engineering and Compliance Trestle.
- `plugins/document-transform/oscal-document-workbench/` exists with command docs, skill, scripts, templates, and manifest.
- A synthetic legacy SSP example can be extracted into a workspace with a source map.
- Validation commands exist and fail loudly when dependencies are missing.
- Compatibility matrix covers Claude Code, Claude Work/Cowork, Codex, Gemini CLI, OpenCode, Cursor/Windsurf, generic desktop agents, and headless shell.
- Existing `plugins/oscal` and `plugins/fedramp-ssp` docs point users into the new workbench flow.
- Tests validate new manifests, scripts, and skill docs.
- No sensitive real SSP data is committed.
- All generated OSCAL workflows require source traceability and human review for uncertain mappings.

---

## 8. First execution slice

Start with this PR-sized slice:

1. Create `AGENTS.md`, `GEMINI.md`, `OPENCODE.md`.
2. Create `docs/AGENT-COMPATIBILITY.md` and `docs/PORTABLE-SKILLS.md`.
3. Create `agent-skills/README.md`, `agent-skills/manifest.json`, and `agent-skills/oscal-document-engineering/SKILL.md` with references/templates.
4. Update README positioning and package metadata.
5. Add tests that validate these docs/manifests exist and parse.

Then second slice:

1. Add `oscal-document-workbench` plugin skeleton.
2. Add extraction/bootstrap/validation scripts.
3. Add example and prompt templates.
4. Register in marketplace.
5. Update OSCAL/FedRAMP SSP docs.

---

## 9. Open decisions

1. Keep repo name as `compliance-trestle-skills` for continuity or rename later to an agent-neutral Compliance Trestle package name?
   - Recommendation: keep repo name for now; change positioning first to avoid breaking marketplace links.

2. Should Compliance Trestle be its own plugin or part of OSCAL Document Workbench?
   - Recommendation: start inside OSCAL Document Workbench to reduce plugin sprawl; split later if usage justifies it.

3. What exactly is meant by “PI extension” in the requirement?
   - Assumption for now: cover it under generic desktop/agent extension docs until the target platform name and extension format are confirmed.

4. What exactly is meant by “cloud plugin”?
   - Assumption for now: document a generic cloud plugin package target and keep Claude Code marketplace intact; add provider-specific package once the target cloud plugin API is known.

5. What is meant by “codecs app”?
   - Assumption for now: treat as Codex app/desktop-style agent workflow and support through `AGENTS.md` plus adapter docs.
