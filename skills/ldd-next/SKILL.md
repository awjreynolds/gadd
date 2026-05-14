---
name: ldd-next
description: Run /ldd:next for an LDD ticket. Use when the user says /ldd:next, asks for the next LDD command, or wants to diagnose workflow state from repo-local ledgers.
---

# /ldd:next

Read repo-local ledger state and report the next explicit LDD command and next human action.

## Input

`/ldd:next [ticket-id]`

## Reads

- active `docs/tickets/**/ledger.yml`
- `execution_context` when present
- draft directories under `docs/tickets/_drafts/`
- parent ticket artifacts
- child vertical-slice ticket state
- child implementation, verification, and closure state
- external tracker sync state and body drift when configured

## Rules

- Read-only. It never mutates GitHub or local files.
- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- External mutations require human confirmation, and this command does not perform mutations.
- Ignore `docs/tickets/_archive/` unless the user explicitly asks to inspect archived tickets.
- Use `.ldd/config.yml` when present.
- Prefer `execution_context` when present, but verify it against ledger artifact state before reporting the next command.
- Report both `execution_context.next_command` and `execution_context.next_human_action` when present. If `next_human_action` is missing, derive it from the active gate.
- If `execution_context` is absent, derive equivalent state from ticket status, artifact statuses, child ledgers, `closure.status`, sync metadata, and archived-child location.
- Preserve approved PRD, SDD, and plan boundaries. If the next step would change those boundaries, report the earliest affected `/ldd:scope`, `/ldd:design`, or `/ldd:plan` gate instead of routing implementation or verification.
- Prioritize parent roll-up closure when all children are verified and closeable.
- Prioritize verified but unclosed child work before verification and implementation.
- Prioritize child work with completed implementation evidence and unverified closure before starting additional child implementation.
- When continuation is safe and commandable, name the exact command the user can run next.
- When continuation requires human review, approval, drift reconciliation, external mutation confirmation, or a blocked choice, name the human decision instead of offering unsafe automation.
- PRD and SDD approval gates must route to `/ldd:approve <ticket-id>`.

## Report Contract

Always report:

- ticket ID and current phase/gate
- `next_command`, if available or derivable
- `next_human_action`, if available or derivable
- a copyable command block containing only the next command when continuation is commandable
- reason
- blocking decision, if blocked

Use this shape:

```text
Next command: /ldd:plan LDD-0003
Next human action: none
Reason: SDD is approved and ready for implementation planning.
Copy:
```

```text
/ldd:plan LDD-0003
```

For approval gates:

```text
Next command: /ldd:approve LDD-0003
Next human action: /ldd:approve LDD-0003
Reason: The PRD or SDD is waiting for explicit approval.
Copy:
```

```text
/ldd:approve LDD-0003
```

For blocked gates:

```text
Next command: blocked
Next human action: reconcile external tracker drift
Reason: The external body changed since the last recorded sync hash.
Copy: not available
```

## Decision Tree

```text
If no ledger exists:
  next: /ldd:setup
Else if draft PRD exists:
  inspect PRD completeness and recommend /ldd:scope, /ldd:elaborate, /ldd:refine, or /ldd:approve <ticket-id> for PRD approval
Else if parent ticket is done:
  done
Else if parent has children and every child is verified and closeable or already closed:
  next: /ldd:close <parent-ticket-id>
Else if any active child is verified but not closed or archived:
  next: /ldd:close <child-ticket-id>
Else if any active child has completed implementation evidence and unverified closure:
  next: /ldd:verify <child-ticket-id>
Else if ready child vertical slices exist:
  next: /ldd:implement <child-ticket-id>
Else if plan is approved and no child tickets exist:
  next: /ldd:decompose
Else if plan exists but is not approved:
  inspect plan state
Else if SDD is approved:
  next: /ldd:plan
Else if SDD exists but is not approved:
  next: /ldd:approve <ticket-id>
  next_human_action: /ldd:approve <ticket-id>
Else if PRD is approved:
  next: /ldd:design
Else if refined PRD is waiting for approval:
  next: /ldd:approve <ticket-id>
  next_human_action: /ldd:approve <ticket-id>
Else:
  next: /ldd:scope
```

## Approval Gate Detection

Treat a PRD as waiting for approval when either:

- `execution_context.phase` is `refine` and `execution_context.current_gate: prd_approval`
- `execution_context.current_gate: prd_approval` and `execution_context.next_command` is `/ldd:approve <ticket-id>`

Do not treat every draft PRD as approval-ready. Drafts in `scope` or `elaborate` must route to `/ldd:elaborate` or `/ldd:refine`, even when `approved_artifacts.prd` is empty.

Report:

```text
next_command: /ldd:approve <ticket-id>
next_human_action: /ldd:approve <ticket-id>
```

Treat an SDD as waiting for approval when either:

- `execution_context.current_gate: design_review`
- `artifacts.sdd.status: draft` and `artifacts.prd.status: approved`

Report:

```text
next_command: /ldd:approve <ticket-id>
next_human_action: /ldd:approve <ticket-id>
```

If both PRD and SDD approval appear active, report the ambiguity and route to human reconciliation. Do not choose one silently.

## Verification Gate Detection

Treat an active child as needing verification when either of these is true:

- `execution_context.current_gate: verification` or `execution_context.next_command` is `/ldd:verify <child-ticket-id>`.
- Derived state shows implementation completed while closure is not verified.

Derived state means implementation evidence exists, for example `artifacts.implementation.status: completed`, `artifacts.implementation.evidence`, a recorded implementation completion event, or equivalent local changed-file/check evidence in the child ledger; and closure is unverified, for example missing `closure`, `closure.status: open`, `closure.status: verification_required`, missing `artifacts.verification`, or `artifacts.verification.status: missing | pending | failed`.

Do not route archived children, externally closed children, or children with `closure.status: verified | archived | externally_closed` to `/ldd:verify`.

## Closure Gate Detection

Treat an active child as ready to close when either of these is true:

- `execution_context.current_gate: closure` or `execution_context.next_command` is `/ldd:close <child-ticket-id>`.
- Derived state shows verification passed while closure has not been applied.

Derived state means `artifacts.verification.status: passed`, `closure.status: verified`, and the child directory is still in the active ticket tree rather than `_archive/`.

Do not route children with `closure.status: archived | externally_closed` to `/ldd:close`.

Treat a parent as ready for roll-up closure when it has at least one child and every child is either:

- already closed with `closure.status: archived | externally_closed`
- closeable with `artifacts.verification.status: passed`, `closure.status: verified`, and a readable `verification.md`

If any child is implemented but unverified, route to `/ldd:verify <child-ticket-id>`. If any child is ready but not implemented, route to `/ldd:implement <child-ticket-id>`.

## Stop Conditions

- requested ticket ID not found
- ledger cannot be parsed
- multiple active drafts and no ticket ID was supplied
- external tracker drift is detected
- external ticket body changed since the last recorded sync hash or timestamp
