# Define /ldd:verify workflow and report contract

## Parent

LDD-0001 - Add LDD execution context and verification gate

## What to build

Define the standalone `/ldd:verify` command workflow and verification report contract. The command must check evidence, check drift, write `verification.md`, update child ledger verification state, and block closure when evidence is insufficient.

Expected touch points:

- `skills/ldd-verify/SKILL.md`
- `skills/ldd-setup/assets/templates/verification.md`
- `.ldd/templates/verification.md`
- `scripts/validate-ldd-mvp.sh`

## Acceptance criteria

- `/ldd:verify` is explicitly scoped to child-ticket closure, not repository health.
- The command reads child ledger, parent ledger, approved PRD, approved SDD, approved plan, child ticket, implementation evidence, check evidence, and external drift metadata.
- The command writes a human-readable `verification.md` report.
- The command updates child ledger verification status to `passed`, `failed`, or `override_required`.
- The command blocks closure when evidence is missing, checks fail, scope/design/plan drift is detected, or external ticket drift is unresolved.
- The command never mutates external trackers without human confirmation.
- `./scripts/validate-ldd-mvp.sh` and `git diff --check` pass.

## Blocked by

- LDD-0001-001
- LDD-0001-002

## User stories covered

2, 4, 5

## LDD Traceability

- Parent PRD: `docs/tickets/_archive/LDD-0001-verify-context-header/prd.md`
- Parent SDD: `docs/tickets/_archive/LDD-0001-verify-context-header/sdd.md`
- Plan: `docs/tickets/_archive/LDD-0001-verify-context-header/plan.md`
- Plan slice: `4. Define /ldd:verify workflow and report contract`
- Ledger: `docs/tickets/_archive/LDD-0001-004-verify-workflow-contract/ledger.yml`
