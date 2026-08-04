---
description: Full component definition authoring workflow
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
user-invocable: true
disable-model-invocation: true
argument-hint: "<compdef_name>"
---

Run the full component definition authoring roundtrip workflow.

## Steps

1. Check that you are in a trestle workspace.

2. Read $ARGUMENTS for the component definition name.
   If the name is missing, list available component-definitions.

3. **Generate phase**:
   ```
   trestle author component-generate --name <compdef_name> --output <compdef_name>-markdown
   ```

4. Show the structure:
   - Separate directories per component
   - One markdown file per control in each component
   - Rules and parameters in the YAML header
   - Implementation prose sections

5. **Edit phase**: help the user:
   - Show a sample control for one component.
   - Tell the user that rules are read-only and come from JSON.
   - Tell the user how to add implementation prose.
   - Set component-values for rule parameters.
   - Set implementation status.

6. **Assemble phase**:
   ```
   trestle author component-assemble --markdown <compdef_name>-markdown --output <compdef_name>
   ```

7. Validate and report results.

8. Suggest this next step: use the component definition with `ssp-generate --compdefs` to make SSPs.
