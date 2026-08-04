---
description: Assemble edited catalog markdown back into OSCAL JSON
allowed-tools: Bash, Read, Glob
user-invocable: true
argument-hint: "<markdown_dir> <output_catalog>"
---

Assemble edited catalog markdown files into an OSCAL JSON catalog.

## Steps

1. Check that you are in a trestle workspace.

2. Read $ARGUMENTS for:
   - `markdown_dir` (`--markdown`): directory that contains edited markdown
   - `output_catalog` (`--output`): name for the assembled catalog
   - Optional: `--name`: source catalog for metadata (used on first assembly)
   - Optional: `--set-parameters`: apply parameter changes from YAML headers
   - Optional: `--version`: set the version string
   - Optional: `--regenerate`: generate new UUIDs

3. Run:
   ```
   trestle author catalog-assemble --markdown <markdown_dir> --output <output_catalog> [--set-parameters] [--version <ver>]
   ```

4. On first assembly, use `--name <original_catalog>` to inherit metadata from the source.

5. Note: the assembled file is not written when content is unchanged.
   This stops false CI/CD triggers.

6. Show the output location. Suggest next steps.
