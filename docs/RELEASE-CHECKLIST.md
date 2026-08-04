# Release checklist

## Validation

- [ ] `npm run test:agent-skills`
- [ ] `npm run test:agent-adapters`
- [ ] `npm run test:cursor-support`
- [ ] `npm run test:oscal-document-workbench`
- [ ] `npm run test:draft-ssp`
- [ ] `npm run test:trestle-integration`
- [ ] `npm run test:oscal-review-workflow`
- [ ] `git diff --check`

## OSCAL and GRC safety

- [ ] No real SSPs, customer evidence, credentials, or secrets are committed.
- [ ] Legacy-document examples are synthetic.
- [ ] Source traceability is required by skills, commands, and docs.
- [ ] Uncertain mappings are marked `needs_review`.
- [ ] Docs state schema-valid OSCAL does not prove compliance effectiveness.

## Agent packaging

- [ ] Claude plugin marketplace manifest parses.
- [ ] Portable `agent-skills/manifest.json` parses.
- [ ] Generic agent package manifest parses.
- [ ] README links current compatibility and workbench docs.

## Documentation language

- [ ] Changed user docs use ASD-STE100 Simplified Technical English.
- [ ] Sentences stay short.
- [ ] Technical names stay consistent.
