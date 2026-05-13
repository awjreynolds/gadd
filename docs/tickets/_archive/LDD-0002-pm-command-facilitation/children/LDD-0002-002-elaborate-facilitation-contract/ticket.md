# Add elaborate facilitation contract

## Parent

LDD-0002 - Strengthen LDD PM command facilitation

## What to build

Update `/ldd:elaborate` so it guides product detail inside existing scope. It must preserve scoped goals/non-goals, offer interaction modes, reject scope expansion, and keep draft acceptance criteria product-facing.

Expected touch point:

- `skills/ldd-elaborate/SKILL.md`

## Acceptance criteria

- `/ldd:elaborate` includes Guided, Context dump, and Best guess modes.
- `/ldd:elaborate` includes a product-detail quality bar that rejects scope expansion and implementation-specific criteria.
- `/ldd:elaborate` defines core product-detail questions for problem, users, stories, draft criteria, draft metrics, and open questions.
- `/ldd:elaborate` ends with an explicit exit gate that routes to `/ldd:refine` or back to `/ldd:scope`.
- `git diff --check` passes for the changed file.

## Blocked by

LDD-0002-001.

## User stories covered

2, 3, 4, 5

## LDD Traceability

- Parent PRD: `docs/tickets/LDD-0002-pm-command-facilitation/prd.md`
- Parent SDD: `docs/tickets/LDD-0002-pm-command-facilitation/sdd.md`
- Plan: `docs/tickets/LDD-0002-pm-command-facilitation/plan.md`
- Plan slice: `2. Elaborate facilitation and product-detail contract`
- Ledger: `docs/tickets/LDD-0002-pm-command-facilitation/children/LDD-0002-002-elaborate-facilitation-contract/ledger.yml`
