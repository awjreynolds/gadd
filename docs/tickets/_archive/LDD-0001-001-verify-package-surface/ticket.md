# Add /ldd:verify package surface

## Parent

LDD-0001 - Add LDD execution context and verification gate

## What to build

Add the installable `/ldd:verify` command surface across the agent-skill package without changing existing command behavior yet. The command must be discoverable and installable through the same package paths as the other `/ldd:*` commands.

Expected touch points:

- `agent-skills.json`
- `README.md`
- `GEMINI.md`
- `.claude-plugin/plugin.json`
- `.claude-plugin/marketplace.json`
- `gemini-extension.json`
- `commands/ldd/verify.md`
- `commands/ldd/verify.toml`
- `skills/ldd-verify/SKILL.md`
- `skills/ldd-verify/agents/openai.yaml`
- `scripts/validate-ldd-mvp.sh`

## Acceptance criteria

- `/ldd:verify` is listed wherever the package lists supported LDD commands.
- Codex/OpenAI, Claude Code, and Gemini adapter files exist and point to the canonical `skills/ldd-verify/SKILL.md`.
- The new verify skill states that repo-local ledger state is canonical and external mutations require human confirmation.
- The validation script requires the new verify package files and still rejects external skill dependencies.
- `./scripts/validate-ldd-mvp.sh` and `git diff --check` pass.

## Blocked by

None.

## User stories covered

1, 2, 3, 5

## LDD Traceability

- Parent PRD: `docs/tickets/_archive/LDD-0001-verify-context-header/prd.md`
- Parent SDD: `docs/tickets/_archive/LDD-0001-verify-context-header/sdd.md`
- Plan: `docs/tickets/_archive/LDD-0001-verify-context-header/plan.md`
- Plan slice: `1. Add /ldd:verify package surface`
- Ledger: `docs/tickets/_archive/LDD-0001-001-verify-package-surface/ledger.yml`
