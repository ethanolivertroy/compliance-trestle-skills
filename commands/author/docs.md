---
description: Set up and check governed markdown document structure with templates
allowed-tools: Bash, Read, Glob, Grep
user-invocable: true
argument-hint: "<mode> -tn <task_name>"
---

Set up and check governed markdown document structure with templates.

## Steps

1. Check that you are in a trestle workspace.

2. Read $ARGUMENTS for:
   - `mode` (positional): one of `setup`, `create-sample`, `template-validate`, `validate`
   - `-tn` / `--task-name` (required): name of the governance task
   - `-gh` / `--governed-heading` (optional): heading that must exist in the document structure
   - `-hv` / `--header-validate` (optional): check YAML header structure
   - `-hov` / `--header-only-validate` (optional): check only the YAML header, not the body
   - `-tv` / `--template-version` (optional): template version to use
   - `-ig` / `--ignore` (optional): regex pattern for files or folders to ignore
   - `-r` / `--recurse` (optional): go into subdirectories
   - `-rv` / `--readme-validate` (optional): include README.md in the check
   - `-vtt` / `--validate-template-type` (optional): check with the `x-trestle-template-type` field

3. Run the matching mode:

   **setup**: Make the template directory and `template.md`:
   ```
   trestle author docs setup -tn <task_name>
   ```
   This makes `.trestle/author/<task_name>/template.md` with a sample structure.

   **create-sample**: Make a new document from the template:
   ```
   trestle author docs create-sample -tn <task_name>
   ```
   This copies the template to `<task_name>/<task_name>_NNN.md` with an incremental number.

   **template-validate**: Check the template file:
   ```
   trestle author docs template-validate -tn <task_name>
   ```

   **validate**: Check all documents against the template:
   ```
   trestle author docs validate -tn <task_name> [-hv] [-gh "Heading Name"]
   ```
   This checks document structure, headings, and optional YAML headers.

4. Tell the user these governance rules:
   - Templates live in `.trestle/author/<task_name>/`.
   - Documents live in `<task_name>/` at the workspace root.
   - Template versioning uses `x-trestle-template-version` in YAML headers.
   - Governed headings require specific sections in documents.
   - This supports CI/CD checks of compliance documentation.
