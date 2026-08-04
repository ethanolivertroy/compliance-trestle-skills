---
description: Generate markdown from an OSCAL component definition
allowed-tools: Bash, Read, Glob, Grep
user-invocable: true
argument-hint: "<compdef_name> <output_dir>"
---

Generate editable markdown from an OSCAL component definition.

## Steps

1. Check that you are in a trestle workspace.

2. Read $ARGUMENTS for:
   - `compdef_name` (`--name`): component definition name
   - `output_dir` (`--output`): markdown output directory
   - Optional: `--yaml`, `--overwrite-header-values`, `--force-overwrite`

3. Run:
   ```
   trestle author component-generate --name <compdef_name> --output <output_dir>
   ```

4. Show the generated structure:
   - Separate directories per component
   - One markdown file per control in each component directory
   - YAML headers with rules, parameters, and implementation details

5. Tell the user what they can edit:
   - Implementation prose per control per component
   - Parameter values (`component-values`)
   - Implementation status
   - Rules are read-only. They come from the component definition.

6. Next steps: edit the markdown, then run `component-assemble`.
