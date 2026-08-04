---
description: Assemble edited component markdown back into OSCAL JSON
allowed-tools: Bash, Read, Glob
user-invocable: true
argument-hint: "<markdown_dir> <output_compdef>"
---

Assemble edited component definition markdown into OSCAL JSON.

## Steps

1. Check that you are in a trestle workspace.

2. Read $ARGUMENTS for:
   - `markdown_dir` (`--markdown`): markdown directory
   - `output_compdef` (`--output`): name for the assembled component definition
   - Optional: `--name`: source component definition
   - Optional: `--version`, `--regenerate`

3. Run:
   ```
   trestle author component-assemble --markdown <markdown_dir> --output <output_compdef>
   ```

4. This assembles all component directories and their control markdown into one component-definition JSON.

5. Show the output. Suggest next steps.
