---
description: Assemble edited profile markdown back into OSCAL JSON
allowed-tools: Bash, Read, Glob
user-invocable: true
argument-hint: "<markdown_dir> <output_profile>"
---

Assemble edited profile markdown into an OSCAL JSON profile.

## Steps

1. Check that you are in a trestle workspace.

2. Read $ARGUMENTS for:
   - `markdown_dir` (`--markdown`): directory with edited markdown
   - `output_profile` (`--output`): name for the assembled profile
   - Optional: `--name`: source profile for metadata
   - Optional: `--set-parameters`: apply parameter changes
   - Optional: `--sections`: define sections (`short_name:Long Name,...`)
   - Optional: `--required-sections`: required sections (comma-separated short names)
   - Optional: `--allowed-sections`: allowed sections (comma-separated short names)
   - Optional: `--version`: version string
   - Optional: `--regenerate`: new UUIDs

3. Run:
   ```
   trestle author profile-assemble --markdown <markdown_dir> --output <output_profile> [--set-parameters] [--sections "impl:Implementation Guidance"]
   ```

4. Assembly fails when `--required-sections` are missing.
   Assembly also fails when disallowed sections are present.

5. Show the output. Suggest next steps.
