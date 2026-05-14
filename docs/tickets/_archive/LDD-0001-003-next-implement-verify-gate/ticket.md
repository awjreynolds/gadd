# Teach /ldd:next and /ldd:implement the verification gate

## Parent

LDD-0001 - Add LDD execution context and verification gate

## What to build

Update workflow navigation and implementation command rules so LDD routes implemented-but-unverified child work to `/ldd:verify`, and implementation completion never archives or externally closes child work directly.

Expected touch points:

- `skills/ldd-next/SKILL.md`
- `skills/ldd-implement/SKILL.md`
- Adapter files only if their thin-router text needs command list updates

## Acceptance criteria

- `/ldd:next` prioritizes child work with completed implementation evidence and unverified closure by reporting `/ldd:verify <child-ticket-id>`.
- `/ldd:next` can use `execution_context` when present and derive equivalent state when it is absent.
- `/ldd:implement` records implementation completion and verification-required closure state, but does not archive or externally close the child work item.
- Rules explicitly preserve the approved PRD, SDD, and plan boundaries.
- `./scripts/validate-ldd-mvp.sh` and `git diff --check` pass.

## Blocked by

- LDD-0001-001
- LDD-0001-002

## User stories covered

1, 2, 3, 5

## LDD Traceability

- Parent PRD: `docs/tickets/_archive/LDD-0001-verify-context-header/prd.md`
- Parent SDD: `docs/tickets/_archive/LDD-0001-verify-context-header/sdd.md`
- Plan: `docs/tickets/_archive/LDD-0001-verify-context-header/plan.md`
- Plan slice: `3. Teach /ldd:next and /ldd:implement the verification gate`
- Ledger: `docs/tickets/_archive/LDD-0001-003-next-implement-verify-gate/ledger.yml`
