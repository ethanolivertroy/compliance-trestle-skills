---
description: Guided workflow to set up governance with workspace templates, config, and trestle author
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
user-invocable: true
disable-model-invocation: true
argument-hint: "[--template catalog|profile|ssp|component-definition] [--author <task_name> --type docs|headers|folders]"
---

Run a guided governance setup workflow.
This covers workspace-level governance: template directories, config.ini, and starter templates.
This also covers document-level governance: trestle author docs, headers, and folders, plus validation and CI/CD.

## Steps

### Part 1: Workspace-level governance

1. Check that you are in a trestle workspace. Look for a `.trestle/` directory.
   If not, offer to start one:
   ```
   trestle init
   ```

2. Read $ARGUMENTS for an optional `--template` flag that selects a governance template.
   If it is missing, show a menu:
   - Catalog governance (review or edit catalog controls)
   - Profile governance (customize baselines)
   - SSP governance (author implementation responses)
   - Component-definition governance (define reusable compliance content)
   - Full governance (set up all of the above)

3. **Template directory setup**: make the governance template directories as needed:
   ```
   mkdir -p .trestle/author/catalog/
   mkdir -p .trestle/author/profile/
   mkdir -p .trestle/author/ssp/
   mkdir -p .trestle/author/component-definition/
   ```
   Show the user which directories were created.

4. **Config.ini setup**: help the user set up `.trestle/config.ini` for their project:
   - Read the existing config.ini if it is present.
   - For each selected governance type, add task config sections:
     ```ini
     [task.catalog-generate]
     output = catalog-markdown

     [task.catalog-assemble]
     markdown = catalog-markdown
     set-parameters = true

     [task.profile-generate]
     output = profile-markdown

     [task.profile-assemble]
     markdown = profile-markdown
     set-parameters = true

     [task.ssp-generate]
     output = ssp-markdown

     [task.ssp-assemble]
     markdown = ssp-markdown
     compdefs = *
     ```
   - Ask the user if they want to change any values.

5. **Template files**: for each governance type, make starter template files:
   - SSP: make a `setup.md` template with sections for system description
   - Profile: make notes on how to customize profile selections
   - Component: make notes on defining components and rules

### Part 2: Document-level governance (trestle author)

6. If `--author <task_name>` was passed, or if the user wants document-level checks, set up `trestle author` governance:
   - Ask the user what they want to check (if `--type` is not specified):
     - YAML headers only to `headers`
     - Document structure (headings plus headers) to `docs`
     - Entire folder structure to `folders`

   Run setup:
   ```
   trestle author <type> setup -tn <task_name>
   ```
   Show the created template files in `.trestle/author/<task_name>/`.

7. **Customize templates**:
   - Read the generated template file or files.
   - Help the user change:
     - YAML header fields (required metadata such as title, status, author, date)
     - Governed headings (required sections in the document)
     - Template version (`x-trestle-template-version`)
   - Write the customized template back.

   Validate the template:
   ```
   trestle author <type> template-validate -tn <task_name>
   ```
   Fix any template issues before you continue.

8. **Create and validate sample documents**:
   ```
   trestle author <type> create-sample -tn <task_name>
   ```
   Show the generated sample, then confirm it passes validation:
   ```
   trestle author <type> validate -tn <task_name> [-hv] [-gh "Section Name"]
   ```

9. **CI/CD suggestions**: offer to help set up automated validation:
   - GitHub Actions workflow step
   - Pre-commit hook setup
   - Makefile target
   - Show the exact command that should run in CI

### Summary

10. **Workspace summary**: show the final workspace structure:
    - List all created directories
    - Show config.ini contents
    - Show any template files created

11. **Next steps**: recommend what to do next:
    - Import source data: "Use `/compliance-trestle:data-import` to import catalogs or profiles"
    - Start authoring: "Use the roundtrip workflows to begin editing"
    - Review workspace: "Use the workspace-explorer agent to verify the setup"
