---
description: Generate SSP markdown from a profile and optional component definitions
allowed-tools: Bash, Read, Glob, Grep
user-invocable: true
argument-hint: "<profile_name> [--compdefs comp1,comp2] <output_dir>"
---

Generate System Security Plan (SSP) markdown from a profile and optional component definitions.

## Steps

1. Verify we are in a trestle workspace.

2. Parse $ARGUMENTS for:
   - `profile_name` (`--profile`): Profile defining the control baseline
   - `output_dir` (`--output`): Markdown output directory
   - Optional: `--compdefs`: Comma-separated list of component-definition names
   - Optional: `--yaml`, `--overwrite-header-values`, `--force-overwrite`
   - Optional: `--include-all-parts`: Include all parts (default: only parts with rules)

3. Ensure the profile's imports resolve correctly (use `trestle href` if needed).

4. Check the profile file is writable. Some import paths create `profile.json` read-only,
   which makes `ssp-generate` fail with errors like `sed: permission denied`. Fix with:
   ```
   chmod u+w profiles/<profile_name>/profile.json
   ```

5. Run:
   ```
   trestle author ssp-generate --profile <profile_name> --output <output_dir> [--compdefs <comp1,comp2>]
   ```

   Note: for a fresh baseline (e.g., NIST 800-53 High), expect a long stream of
   parameter/ODP warnings about values not being set. These are expected for an
   unpopulated template and are resolved as `ssp-values` are filled in. They do
   not indicate a failure.

6. Show the generated structure:
   - One markdown file per control
   - Each control has sections per statement part
   - Each part has response sections per component
   - "This System" component is always present
   - Named components come from component definitions
   - If no `--compdefs` were provided, only "This System" sections appear

7. Explain the markdown structure:
   - YAML header: parameters, rules, rule parameters
   - Control statement (read-only)
   - Implementation sections per part per component
   - `#### Implementation Status:` per component
   - `#### Rules:` (read-only, from component definitions)

8. Explain what to edit:
   - Replace `<!-- Add control implementation description here -->` comments with prose
   - Set `ssp-values:` for parameters
   - Set implementation status values
   - Add implementation prose for each component per statement part

9. Next steps: Edit all control responses, then `ssp-assemble` (the author command,
   `trestle author ssp-assemble`, not the generic `trestle assemble`).
