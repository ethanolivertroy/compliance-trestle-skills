---
description: Check and apply YAML header consistency across markdown documents
allowed-tools: Bash, Read, Glob, Grep
user-invocable: true
argument-hint: "<mode> -tn <task_name>"
---

Check or apply YAML header consistency across governed markdown documents.

## Steps

1. Check that you are in a trestle workspace.

2. Read $ARGUMENTS for:
   - `mode` (positional): one of `setup`, `template-validate`, `validate`, `create-sample`
   - `-tn` / `--task-name` (required unless `--global`): name of the governance task
   - `-g` / `--global` (optional): use the global template at `.trestle/author/__global__/`
   - `-r` / `--recurse` (optional): go into subdirectories during validation
   - `-rv` / `--readme-validate` (optional): include README.md files in the check
   - `-tv` / `--template-version` (optional): template version to use
   - `-ig` / `--ignore` (optional): regex pattern for files or folders to ignore

3. Run the matching mode:

   **setup**: Make the template directory and the initial template:
   ```
   trestle author headers setup -tn <task_name>
   ```
   This makes `.trestle/author/<task_name>/` with a template file.

   **template-validate**: Check that the template is valid:
   ```
   trestle author headers template-validate -tn <task_name>
   ```
   This checks markdown and drawio template files for structural integrity.

   **validate**: Check instance documents against the template:
   ```
   trestle author headers validate -tn <task_name> [-r]
   ```
   This checks that markdown files in `<task_name>/` have YAML headers that match the template structure.

4. Show results. Tell the user about any validation failures:
   - Missing required header fields
   - Header fields with wrong types
   - Extra fields that are not in the template (if strict mode)

5. Note: `create-sample` is not supported for headers-only governance.
   Use `trestle author docs` for full document governance with sample creation.
