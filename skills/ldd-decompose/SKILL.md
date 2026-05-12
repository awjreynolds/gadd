---
name: ldd-decompose
description: Run /ldd:decompose after an approved LDD plan. Use when the user says /ldd:decompose or needs plan slices turned into child vertical-slice tickets for implementation.
---

# /ldd:decompose

Turn an approved `plan.md` into child vertical-slice tickets.

## Reads

- parent `ledger.yml`
- approved PRD
- approved SDD
- approved `plan.md`

## Produces

- child ticket entries in the parent ledger
- child ticket ledgers under the parent ticket directory
- external child tickets only when a tracker is configured and the human approves

## Preview Before Creation

Before creating or updating any child ticket, present the proposed ticket set and stop for human approval.

Use this review shape:

```text
Proposed child tickets:

1. <title>
   Type: AFK | HITL
   Blocked by: None | <ticket title/id>
   User stories covered: <PRD story numbers>
   Summary: <one or two sentences>

Ask:
- Does the granularity feel right?
- Are dependency relationships correct?
- Are HITL/AFK classifications correct?
- Should any tickets be merged or split?
```

Only after approval may the command create child ledgers or external child tickets.

## Rules

- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- External mutations require human confirmation.
- Decompose only from an approved plan. Do not invent scope or architecture.
- Child tickets are vertical slices derived from plan slices, not layer tasks.
- Each child ticket must be independently grabbable: an implementation agent can read the ticket, follow links as needed, and understand what end-to-end behavior to build, what acceptance criteria must pass, what it is blocked by, and which user stories or PRD criteria it covers.
- Each child ticket must reference the parent Product Requirement and approved plan slice.
- External child ticket bodies should stay close to the Pocock `to-issues` shape: Parent, What to build, Acceptance criteria, Blocked by, plus minimal LDD Traceability.
- Before updating an existing external child ticket, re-read it. If its body changed since the last recorded sync hash or timestamp, stop and ask the human to reconcile the external contribution.
- Keep the MVP lightweight: do not create a separate decomposition artifact unless the user explicitly asks.

## Stop Conditions

- parent ledger missing
- plan is missing or not approved
- plan slices are too vague to turn into independently grabbable vertical slices
- external tracker is configured but cannot be reached
- human rejects the proposed child ticket set
