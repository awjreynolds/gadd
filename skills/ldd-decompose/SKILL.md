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

## Rules

- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- External mutations require human confirmation.
- Decompose only from an approved plan. Do not invent scope or architecture.
- Child tickets are vertical slices derived from plan slices, not layer tasks.
- Each child ticket must reference the parent Product Requirement and approved plan slice.
- Keep the MVP lightweight: do not create a separate decomposition artifact unless the user explicitly asks.

## Stop Conditions

- parent ledger missing
- plan is missing or not approved
- plan slices are too vague to turn into independently grabbable vertical slices
- external tracker is configured but cannot be reached
- human rejects the proposed child ticket set
