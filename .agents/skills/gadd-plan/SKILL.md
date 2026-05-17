---
name: gadd-plan
description: Run /gadd:plan to create or update the implementation plan for a GADD Work Item with an approved SDD. Use when the user says /gadd:plan, asks for an implementation plan, wants plan.md or plan.html generated, needs slices traced to acceptance criteria, or says things like "plan the work", "draft a plan", "turn the SDD into a plan", or "produce reviewable slices for this design". This is the Technical Design lane gate after /gadd:design; it does not split slices into child Work Items (that is /gadd:decompose) and it must route to /gadd:approve <work-item-id> for plan approval before any decomposition.
---

# /gadd:plan

Create or update `plan.md` and generated `plan.html` in the promoted Work Item directory.

This command is a standalone, agent-agnostic GADD command. Follow this file directly; do not require any other installed skill.

## Input

```text
/gadd:plan <work-item-id>
```

If no Work Item ID is provided, stop and ask for the target Work Item ID.

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

Each implementation slice in `plan.md` must surface the fields that `/gadd:decompose` will turn into child Work Items. The canonical schema is the slice table in `skills/gadd-setup/assets/templates/plan.md`: `Slice`, `Outcome`, `Type`, `Blocked by`, `Stories/criteria`, `Files/modules`, `Documentation impact`, `Tests/checks`, `Dependencies`, `Review load`, and `Summary`. If a field is genuinely not applicable, mark it explicitly rather than omitting it.

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
- external drift detected on a managed SDD/Plan PR or related external projection
- planning discovers a missing ADR or design rule that should live in the SDD/ADR record before slicing
- a proposed slice cannot fit the cognitive-load budget for a single focused human review
