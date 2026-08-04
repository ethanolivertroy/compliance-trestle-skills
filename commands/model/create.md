---
description: Create a new OSCAL model in the workspace
allowed-tools: Bash, Read, Glob
user-invocable: true
argument-hint: "<type> <name> [--include-optional-fields]"
---

Create a new basic OSCAL model in the Trestle workspace.

## Steps

1. Check that you are in a trestle workspace.

2. Read $ARGUMENTS for:
   - `type`: one of catalog, profile, component-definition, system-security-plan, assessment-plan, assessment-results, plan-of-action-and-milestones
   - `name`: the name or alias for the model
   - Optional `--include-optional-fields` or `-iof`: include optional OSCAL fields

3. Run the create command:
   ```
   trestle create -t <type> -o <name> [-iof]
   ```

4. Check that the model was created. Look in the matching directory.

5. Show the user the created file structure. Tell the user:
   - The model file location, such as `catalogs/<name>/catalog.json`
   - That `REPLACE_ME` placeholders need to be filled in
   - How to edit the model: split for large edits, or edit JSON directly
   - Next steps: import content, use author commands, or edit directly
