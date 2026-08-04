---
description: Set compliance-trestle plugin settings for this project
allowed-tools: Read, Write, Edit, Glob
user-invocable: true
argument-hint: "[--show | --reset]"
---

Set per-project compliance-trestle plugin settings.

## Steps

1. Read $ARGUMENTS:
   - `--show`: show settings and exit
   - `--reset`: delete the settings file and exit
   - No arguments: interactive setup

2. Check for existing settings at `.claude/compliance-trestle.local.md`.

3. **If `--show`**: read and show the settings file.
   If the file does not exist, say "No project settings configured. Run `/workspace-configure` to set up."

4. **If `--reset`**: delete `.claude/compliance-trestle.local.md` if it exists. Confirm deletion.

5. **Interactive setup** (no arguments):

   If settings already exist, read them. Show the values as defaults.

   Ask the user about each setting:

   - **auto_validate** (true/false, default: true): remind the user to validate after assembly and import operations
   - **default_catalog** (string, default: empty): default catalog name for authoring workflows, such as `nist-800-53-rev5`
   - **default_profile** (string, default: empty): default profile name for SSP generation
   - **validation_level** (strict/normal, default: normal): `strict` treats warnings as errors
   - **ssp_format** (markdown/json, default: markdown): preferred SSP editing format

6. Write the settings file to `.claude/compliance-trestle.local.md`:

   ```markdown
   ---
   auto_validate: true
   default_catalog: nist-800-53-rev5
   default_profile: ""
   validation_level: normal
   ssp_format: markdown
   ---

   # Compliance Trestle Project Settings

   These settings control compliance-trestle plugin behavior for this project.
   Edit this file directly, or run `/workspace-configure` to change settings.

   Plugin hooks read these settings at session start and during workflows.
   The plugin `.gitignore` excludes this file from version control.
   ```

7. Confirm the settings were saved. Tell the user they apply at the next session start.

## Notes

- Make the `.claude/` directory if it does not exist. Use `mkdir -p .claude`.
- Settings are gitignored by default. The plugin `.gitignore` excludes `*.local.md`.
- The session-start hook reads settings to provide workspace context.
