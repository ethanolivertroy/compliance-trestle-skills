---
description: Set up and check governed folder structure with templates
allowed-tools: Bash, Read, Glob, Grep
user-invocable: true
argument-hint: "<mode> -tn <task_name>"
---

Set up and check governed folder structures with template directories.

## Steps

1. Check that you are in a trestle workspace.

2. Read $ARGUMENTS for:
   - `mode` (positional): one of `setup`, `create-sample`, `template-validate`, `validate`
   - `-tn` / `--task-name` (required): name of the governance task
   - `-gh` / `--governed-heading` (optional): heading that must exist in markdown files
   - `-hv` / `--header-validate` (optional): check YAML header structure
   - `-hov` / `--header-only-validate` (optional): check only YAML headers
   - `-tv` / `--template-version` (optional): template version to use
   - `-ig` / `--ignore` (optional): regex pattern for files or folders to ignore
   - `-rv` / `--readme-validate` (optional): include README.md in the check
   - `-vtt` / `--validate-template-type` (optional): check with the `x-trestle-template-type` field

3. Run the matching mode:

   **setup**: Make the template directory with sample files:
   ```
   trestle author folders setup -tn <task_name>
   ```
   This makes `.trestle/author/<task_name>/` with template files.
   Examples: `a_template.md`, `another_template.md`, `architecture.drawio`.

   **create-sample**: Make a new folder instance from the templates:
   ```
   trestle author folders create-sample -tn <task_name>
   ```
   This copies the full template directory to `<task_name>/sample_folder_N/`.

   **template-validate**: Check all template files:
   ```
   trestle author folders template-validate -tn <task_name>
   ```

   **validate**: Check folder instances against the template:
   ```
   trestle author folders validate -tn <task_name> [-hv]
   ```
   Check that each folder in `<task_name>/` matches the template structure.
   Each folder must have the same files, the same headings, and the same YAML headers.

4. Tell the user these folder governance rules:
   - The template directory defines the required file structure.
   - Each instance folder must match the template exactly.
   - Markdown (`.md`) and drawio (`.drawio`) files are supported.
   - Use this to keep a consistent structure across system components or assessments.
   - Use CI/CD to stop structural drift.
