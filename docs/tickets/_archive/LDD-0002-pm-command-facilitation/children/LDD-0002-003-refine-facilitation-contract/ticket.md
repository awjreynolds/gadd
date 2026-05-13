# Add refine facilitation contract and evidence checks

## Parent

LDD-0002 - Strengthen LDD PM command facilitation

## What to build

Update `/ldd:refine` so it guides PRD handoff quality, owns acceptance criteria and metrics refinement, resolves or owns open questions, and ends with the PRD approval/promotion gate. Record targeted evidence that all three PM commands include the new facilitation contract.

Expected touch point:

- `skills/ldd-refine/SKILL.md`
- Child ledgers for implementation evidence

## Acceptance criteria

- `/ldd:refine` includes Guided, Context dump, and Best guess modes.
- `/ldd:refine` includes a handoff-quality bar for testable criteria, measurable metrics, owned questions, dependencies, and solution-smuggling cleanup.
- `/ldd:refine` includes explicit systematic checks before approval.
- `/ldd:refine` ends with the PRD approval/promotion gate.
- Targeted checks confirm all three PM skills include the facilitation protocol and exit gate.
- `git diff --check` passes.

## Blocked by

LDD-0002-001, LDD-0002-002.

## User stories covered

2, 3, 4, 5

## LDD Traceability

- Parent PRD: `docs/tickets/LDD-0002-pm-command-facilitation/prd.md`
- Parent SDD: `docs/tickets/LDD-0002-pm-command-facilitation/sdd.md`
- Plan: `docs/tickets/LDD-0002-pm-command-facilitation/plan.md`
- Plan slice: `3. Refine facilitation and handoff contract`
- Ledger: `docs/tickets/LDD-0002-pm-command-facilitation/children/LDD-0002-003-refine-facilitation-contract/ledger.yml`
