---
description: Full catalog authoring workflow - generate, edit, and assemble
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
user-invocable: true
disable-model-invocation: true
argument-hint: "<catalog_name>"
---

Run the full catalog authoring roundtrip workflow.

## Steps

1. Check that you are in a trestle workspace.

2. Read $ARGUMENTS for the catalog name.
   If the name is missing, list available catalogs and ask the user to choose.

3. **Generate phase**: generate markdown from the catalog:
   ```
   trestle author catalog-generate --name <catalog_name> --output <catalog_name>-markdown
   ```

4. Show the generated markdown structure. Tell the user:
   - Each control has its own `.md` file in group directories.
   - The YAML header contains `x-trestle-set-params` with parameter values.
   - You can change the control statement. You can add items or change prose.
   - You can set parameter values in the YAML header.

5. **Edit phase**: help the user edit the markdown files:
   - Show a sample control file.
   - Tell the user what they can change: prose, parameter values, and guidance.
   - Ask the user what they want to edit, or if they want to continue.

6. **Assemble phase**: when the user is ready, assemble back to JSON:
   ```
   trestle author catalog-assemble --markdown <catalog_name>-markdown --output <catalog_name> --set-parameters
   ```

7. Validate the assembled catalog:
   ```
   trestle validate -t catalog -n <catalog_name>
   ```

8. Report results. Tell the user the cycle can be repeated.
