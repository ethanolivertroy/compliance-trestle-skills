---
description: Render Jinja2 templates against OSCAL data to make documents
allowed-tools: Bash, Read, Glob, Grep
user-invocable: true
argument-hint: "<template> <output> [--ssp <name>] [--profile <name>]"
---

Render a Jinja2 template against OSCAL data to make compliance documents.
The data can be an SSP, a profile, or a catalog.

## Steps

1. Check that you are in a trestle workspace.

2. Read $ARGUMENTS for:
   - `template` (`-i` / `--input`): path to the Jinja2 template file (relative to the trestle root)
   - `output` (`-o` / `--output`): output file path (relative to the trestle root)
   - `--ssp` (optional): SSP name to pass as context
   - `--profile` / `-p` (optional): profile name to pass as context
   - `--look-up-table` / `-lut` (optional): YAML key-value lookup table path
   - `--bracket-format` / `-bf` (optional): bracket format for values, such as `[.]` or `((.))`
   - `--number-captions` / `-nc` (optional): add numbering to table and image captions
   - `--docs-profile` / `-dp` (optional): profile for per-control markdown output
   - `--value-assigned-prefix` / `-vap` (optional): prefix when a value is assigned
   - `--value-not-assigned-prefix` / `-vnap` (optional): prefix when a value is not assigned

3. Run the Jinja render command:
   ```
   trestle author jinja -i <template> -o <output> [--ssp <ssp_name>] [-p <profile_name>] [-lut <yaml_path>]
   ```

4. Show the generated output file.

5. Tell the user the available template context objects:
   - When `--ssp` is provided: `ssp`, `catalog`, `catalog_interface`, `control_interface`, `ssp_md_writer`, `control_writer`
   - When `--profile` and `--docs-profile` are provided: `profile`, `control`, `group_title`
   - When `--look-up-table` is provided: key-value pairs available as variables

6. Tell the user the available custom Jinja tags:
   - `{% mdsection_include "file.md" "Section Title" heading_level=2 %}`: include a markdown section
   - `{% md_clean_include "file.md" heading_level=2 %}`: include a full markdown file and remove frontmatter
   - `{% md_datestamp format="%Y-%m-%d" newline=True %}`: insert a formatted date

7. Tell the user the available custom Jinja filters:
   - `as_list`: convert to a list
   - `get_default`: get the default value
   - `first_or_none`: get the first element or None
   - `get_party`: get a party by UUID from the SSP
   - `parties_for_role`: get parties for a role ID
   - `diagram_href`: get a diagram link href
