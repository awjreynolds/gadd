---
name: ldd-plan
description: Run /ldd:plan for an LDD ticket. Use when the user says /ldd:plan or wants an implementation plan and generated plan.html from an approved LDD SDD.
---

# /ldd:plan

Create or update `plan.md` and generated `plan.html` in the promoted ticket directory.

## Reads

- merged PRD
- SDD
- relevant ADRs

## Plan Must Include

- PRD summary
- SDD summary
- ADR summary and links
- implementation slices
- acceptance criteria traceability
- files / modules expected to change
- test strategy
- review checklist
- planned vertical slices for later `/ldd:decompose`

## Rules

- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- External mutations require human confirmation.
- Use the plan template's traceability and review checklist as mandatory completion criteria.
- The plan may define vertical slices, but child tickets are created by `/ldd:decompose`.
- Do not introduce new architectural decisions. If planning discovers one, stop and return to `/ldd:design`.
- `plan.md` is the durable source; `plan.html` is generated from it.
- Commit locally after planning.
- After human approval of the plan, promote/sync review state according to `.ldd/config.yml`. `/ldd:approve` does not approve plans.
- When stopping for plan approval, set `execution_context.next_human_action` to the required plan review decision rather than `/ldd:approve`.
- In GitHub tracker mode, use `.ldd/templates/pr-body-sdd-plan.md` as a managed PR projection for review; ask before creating or updating it and stop on external drift.
- SDD/Plan PR reviewer prompt: "Does this design and plan correctly implement the PRD?"

## Stop Conditions

- missing SDD
- planning discovers a new architecture decision
- slices cannot trace to acceptance criteria
