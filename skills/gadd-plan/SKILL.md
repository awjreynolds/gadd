---
name: gadd-plan
description: Run /gadd:plan for a GADD Work Item. Use when the user says /gadd:plan or wants an implementation plan and generated plan.html from an approved GADD SDD.
---

# /gadd:plan

Create or update `plan.md` and generated `plan.html` in the promoted Work Item directory.

## Reads

- approved PRD or approved triage outcome
- SDD
- relevant ADRs
- GitNexus code-intelligence context when available and relevant

## Plan Must Include

- PRD summary or triage outcome summary
- SDD summary
- ADR summary and links
- implementation slices
- acceptance criteria traceability
- files / modules expected to change
- documentation impact by slice
- test strategy
- review checklist
- planned vertical slices for later `/gadd:decompose`

## Input Quality Gate

Required input standard before writing a plan:

- approved PRD and approved SDD in the ledger for `product_requirement`
- approved triage outcome and approved SDD in the ledger for `engineering_change`
- SDD decisions trace to PRD acceptance criteria or the approved triage outcome
- no new architecture decision discovered during planning
- enough design detail to create traceable vertical slices

If inputs fail this standard, write nothing and name the blocking gap. The earliest GADD command that can repair missing or wrong design input is `/gadd:design`; missing product approval routes to `/gadd:approve <work-item-id>` or the owning Product Manager command.

## Rules

- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- External mutations require human confirmation.
- Use the plan template's traceability and review checklist as mandatory completion criteria.
- GitNexus is strongly recommended for expected files/modules, slice boundaries, dependency order, and review-load estimates when code reality matters. If GitNexus is unavailable, stale, unindexed, or outside the configured related repositories, continue with normal inspection and record the limitation when it affects the plan.
- The plan may define vertical slices, but child Work Items are created by `/gadd:decompose`.
- For `engineering_change`, `/gadd:plan` may run after SDD approval when the SDD says multiple reviewable slices or review-load management are needed. A PRD is not required for this path.
- Do not introduce new architectural decisions. If planning discovers one, stop and return to `/gadd:design`.
- `plan.md` is the durable source; `plan.html` is generated from it.
- Commit locally after planning.
- Stop at explicit plan approval through `/gadd:approve <work-item-id>`.
- After writing the plan, set `execution_context.current_gate: plan_review`, `execution_context.next_command: /gadd:approve <work-item-id>`, and `execution_context.next_human_action: /gadd:approve <work-item-id>`.
- `/gadd:decompose` must not be the next command until `/gadd:approve <work-item-id>` has approved the plan.
- In GitHub tracker mode, use `gadd/templates/pr-body-sdd-plan.md` as a managed PR projection for review; ask before creating or updating it and stop on external drift.
- SDD/Plan PR reviewer prompt: "Does this design and plan correctly implement the approved Work Item boundary? If yes, run `/gadd:approve <work-item-id>`."

## Stop Conditions

- missing SDD
- planning discovers a new architecture decision
- slices cannot trace to acceptance criteria or approved triage outcome
