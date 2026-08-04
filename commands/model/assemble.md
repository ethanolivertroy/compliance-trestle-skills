---
description: Assemble a split OSCAL model into a single file in dist/
allowed-tools: Bash, Read, Glob
user-invocable: true
argument-hint: "<type> <name>"
---

Assemble all split parts of an OSCAL model into one file in the dist/ directory.

## Steps

1. Check that you are in a trestle workspace.

2. Read $ARGUMENTS for:
   - `type`: the model type (catalog, profile, or another supported type)
   - `name`: the model name

3. Run the assemble command:
   ```
   trestle assemble <type> -n <name>
   ```

4. This walks the model directory.
   It combines all split files into one OSCAL file at `dist/<type_plural>/<name>.json`.

5. On success, show:
   - The output file location
   - That assembly also validates the content

6. On failure, tell the user the error and suggest fixes.

Note: this is the basic `trestle assemble` for recombining split files.
For author workflow assembly (markdown to JSON), use the author-specific assemble commands.
Examples: `/trestle-catalog-assemble` or `/trestle-ssp-assemble`.
