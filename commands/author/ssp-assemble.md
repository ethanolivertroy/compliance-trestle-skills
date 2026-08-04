---
description: Assemble SSP markdown into an OSCAL System Security Plan JSON
allowed-tools: Bash, Read, Glob
user-invocable: true
argument-hint: "<markdown_dir> <output_ssp>"
---

Assemble edited SSP markdown into an OSCAL System Security Plan JSON file.

## Steps

1. Check that you are in a trestle workspace.

2. Read $ARGUMENTS for:
   - `markdown_dir` (`--markdown`): SSP markdown directory
   - `output_ssp` (`--output`): name for the assembled SSP
   - Optional: `--name`: source SSP for metadata
   - Optional: `--version`, `--regenerate`

3. Run:
   ```
   trestle author ssp-assemble --markdown <markdown_dir> --output <output_ssp>
   ```

4. This makes an OSCAL SSP that contains:
   - The resolved profile catalog
   - Implementation responses per component per control
   - Parameters and properties from component definitions
   - Implementation status per component

5. The command does not write the file when content is unchanged.
   This stops false CI/CD triggers.

6. Show the output location. Suggest next steps: validate, distribute, or filter.
