---
name: ldd-next
description: Run /ldd:next for an LDD ticket. Use when the user says /ldd:next, asks for the next LDD command, or wants to diagnose workflow state from repo-local ledgers.
---

# /ldd:next

Read repo-local ledger state and report the next explicit LDD command.

## Input

`/ldd:next [ticket-id]`

## Reads

- active `docs/tickets/**/ledger.yml`
- draft directories under `docs/tickets/_drafts/`
- parent ticket artifacts
- child vertical-slice ticket state
- external tracker sync state and body drift when configured

## Rules

- Read-only. It never mutates GitHub or local files.
- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- External mutations require human confirmation, and this command does not request mutations.
- Ignore `docs/tickets/_archive/` unless the user explicitly asks to inspect archived tickets.
- Use `.ldd/config.yml` when present.

## Decision Tree

```text
If no ledger exists:
  next: /ldd:setup
Else if draft PRD exists:
  inspect PRD completeness and recommend /ldd:scope, /ldd:elaborate, or /ldd:refine
Else if parent ticket is done:
  done
Else if ready child vertical slices exist:
  next: /ldd:implement <child-ticket-id>
Else if plan is approved and no child tickets exist:
  next: /ldd:decompose
Else if plan exists but is not approved:
  inspect plan state
Else if SDD is approved:
  next: /ldd:plan
Else if PRD is approved:
  next: /ldd:design
Else:
  next: /ldd:scope
```

## Stop Conditions

- requested ticket ID not found
- ledger cannot be parsed
- multiple active drafts and no ticket ID was supplied
- external tracker drift is detected
- external ticket body changed since the last recorded sync hash or timestamp
