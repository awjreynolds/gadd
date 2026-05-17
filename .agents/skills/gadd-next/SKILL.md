---
name: gadd-next
description: Run /gadd:next for a GADD Work Item. Use when the user says /gadd:next, asks for the next GADD command, or wants to diagnose workflow state from repo-local ledgers.
---

# /gadd:next

Read repo-local ledger state and report the next explicit GADD command and next human action.

This command is a standalone, agent-agnostic GADD command. Follow this file directly; do not require any other installed skill.

## Input

`/gadd:next [work-item-id]`

## Reads

- active `gadd/work-items/**/ledger.yml`
- `execution_context` when present
- draft directories under `gadd/work-items/_drafts/`
- parent Work Item artifacts
- child vertical-slice Work Item state
- child implementation, verification, and closure state
- external tracker sync state and body drift when configured
- implementation PR state when a ledger records an implementation PR URL or number

## Input Quality Gate

Required input standard before reporting workflow navigation:

- readable active ledger state, or enough artifact state to derive equivalent phase state
- no ambiguous multiple active drafts unless the user selected one
- child ledger paths are readable when parent state depends on children
- external tracker drift metadata is either clean or reported as a blocker
- implementation PR state is checked from the external tracker when needed to distinguish review/merge waiting from verification-ready work

If inputs fail this standard, do not mutate anything and report the ambiguity or missing state. The earliest GADD command that can repair missing setup is `/gadd:setup`; missing decomposition routes to `/gadd:decompose`; ambiguous or drifted state requires human reconciliation before another command runs.

## Rules

- Read-only. It never mutates GitHub or local files.
- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- External mutations require human confirmation, and this command does not perform mutations.
- Treat PR review, approval, merge, close, and branch deletion as external actions. Do not infer them from the conversation, branch names, local commits, or the user's statement. If a ledger records an implementation PR, read the external PR state before deciding the next command.
- If the external PR is merged but the repo-local ledger has not recorded the merge commit and merge time, route to `/gadd:verify <work-item-id>` so verification can record observed merge evidence and finish the Work Item closure-readiness check.
- Report external tracker drift only when the external PR state conflicts with recorded ledger state, cannot be read, or is closed without merge.
- If the external PR is still open, report that review/merge remains the next human action and do not route to `/gadd:verify`.
- Ignore `gadd/work-items/_archive/` unless the user explicitly asks to inspect archived Work Items.
- Use `gadd/config.yml` when present.
- Prefer `execution_context` when present, but verify it against ledger artifact state before reporting the next command.
- Treat closed, archived, or verified ledger statuses as inconsistent when completed implementation evidence, passed verification evidence, or a required verification report is missing. Report `next_command: blocked` and `next_human_action: reconcile rogue Work Item state before continuing` instead of accepting a direct status edit as proof that GADD gates ran.
- Report both `execution_context.next_command` and `execution_context.next_human_action` when present. If `next_human_action` is missing, derive it from the active gate.
- If `execution_context` is absent, derive equivalent state from Work Item status, artifact statuses, child ledgers, `closure.status`, sync metadata, and archived-child location.
- Preserve approved PRD, SDD, and plan boundaries. If the next step would change those boundaries, report the earliest affected `/gadd:scope`, `/gadd:design`, or `/gadd:plan` gate instead of routing implementation or verification.
- Prioritize parent roll-up closure when all children are verified and closeable.
- Prioritize verified but unclosed child work before verification and implementation.
- Prioritize child work with completed implementation evidence and unverified closure before starting additional child implementation.
- Treat `/gadd:archive` as optional cleanup only. Do not route to archive as required workflow work after closure.
- When continuation is safe and commandable, name the exact command the user can run next.
- When continuation requires human review, approval, drift reconciliation, external mutation confirmation, or a blocked choice, name the human decision instead of offering unsafe automation.
- PRD, SDD, and plan approval gates must route to `/gadd:approve <work-item-id>`.

## Work Item Routing

Evaluate downstream phase state before initial triage route state. `work_item.state` records the route selected by `/gadd:triage`, but later commands advance the workflow through `execution_context` and artifact statuses. Do not let stale triage states such as `needs_prd` or `needs_sdd` override a PRD, SDD, or plan gate that has already been written.

When `execution_context.next_command` is present and its gate still matches artifact state, prefer that command over the initial triage route. For example, a `needs_sdd` Work Item with `artifacts.sdd.status: draft` and `execution_context.current_gate: design_review` routes to `/gadd:approve <work-item-id>`, not back to `/gadd:design`.

Use `work_item.state` routing only when no later phase state is present or when the recorded later phase state is inconsistent and must be reported as a blocker.

For route states that leave triage (`ready_for_implementation`, `needs_sdd`, or `needs_prd`), first require all approved outcome fields:

- `triage.approved_outcome.status: approved`
- `triage.approved_outcome.approved_hash`
- a concrete `triage.approved_outcome.boundary_source`

If any approved outcome field is missing, report:

```text
next_command: /gadd:triage <work-item-id>
next_human_action: approve or repair the triage outcome boundary
```

If `work_item.state: needs_info`, report:

```text
next_command: /gadd:triage <work-item-id>
```

If `work_item.state: ready_for_implementation`, report:

```text
next_command: /gadd:implement <work-item-id>
```

If `work_item.state: needs_sdd`, report:

```text
next_command: /gadd:design <work-item-id>
```

If `work_item.state: needs_prd`, route to `/gadd:research <work-item-id>` when research is absent or blocked; otherwise route to `/gadd:scope <work-item-id>`.

If `work_item.state: blocked_on_human_decision`, report no downstream command, set `next_command: blocked`, and name the recorded human decision required before `/gadd:triage <work-item-id>` can continue.

If `work_item.state` is `duplicate`, `out_of_scope`, or `not_gadd_work`, report `next_command: blocked`, show the recorded terminal reason, and do not invent a downstream `/gadd:*` command.

## Report Contract

Always report:

- Work Item ID and current phase/gate
- `next_command`, if available or derivable
- `next_human_action`, if available or derivable
- a copyable command block containing only the next command when continuation is commandable
- reason
- blocking decision, if blocked

Use this shape:

```text
Next command: /gadd:plan GADD-0003
Next human action: none
Reason: SDD is approved and ready for implementation planning.
Copy:
```

```text
/gadd:plan GADD-0003
```

For approval gates:

```text
Next command: /gadd:approve GADD-0003
Next human action: /gadd:approve GADD-0003
Reason: The PRD, SDD, or plan is waiting for explicit approval.
Copy:
```

```text
/gadd:approve GADD-0003
```

For blocked gates:

```text
Next command: blocked
Next human action: reconcile external tracker drift
Reason: The external body changed since the last recorded sync hash.
Copy: not available
```

## Decision Tree

The per-gate rules in `skills/gadd-next/references/gate-detection.md` are authoritative; this tree is a navigation summary. Load that reference before deriving approval, verification, closure, archive cleanup, or implementation PR state from ledger fields.

```text
If no ledger exists:
  next: /gadd:setup
Else if draft PRD exists:
  route to the owning phase by execution_context.phase: scope -> /gadd:scope, elaborate -> /gadd:elaborate, refine -> /gadd:refine. Do not route a scope or elaborate draft to /gadd:approve; see Approval Gate Detection for the exact PRD-approval condition
Else if parent Work Item is archived or done:
  done
Else if parent Work Item is closed or externally closed:
  done
  optional_cleanup_command: /gadd:archive <parent-work-item-id> only when the Work Item is still in the active tree and the human wants local cleanup
Else if parent has children and every child is verified and closeable or already closed:
  next: /gadd:close <parent-work-item-id>
Else if any active child is verified but not closed or archived:
  next: /gadd:close <work-item-id>
Else if implementation PR exists and external PR state is open:
  next: blocked
  next_human_action: review and merge implementation PR
Else if any active child has completed implementation evidence and unverified closure:
  next: /gadd:verify <work-item-id>
Else if ready child vertical slices exist:
  next: /gadd:implement <work-item-id>
Else if plan is approved and no child Work Items exist:
  next: /gadd:decompose
Else if plan exists but is not approved:
  next: /gadd:approve <work-item-id>
  next_human_action: /gadd:approve <work-item-id>
Else if SDD is approved:
  if work_item.type is engineering_change and the SDD records implementation_route: single:
    next: /gadd:implement <work-item-id>
  else:
    next: /gadd:plan
Else if SDD exists but is not approved:
  next: /gadd:approve <work-item-id>
  next_human_action: /gadd:approve <work-item-id>
Else if PRD is approved:
  next: /gadd:design
Else if refined PRD is waiting for approval:
  next: /gadd:approve <work-item-id>
  next_human_action: /gadd:approve <work-item-id>
Else:
  next: /gadd:scope
```

## Gate Detection Reference

Detailed field-level detection rules live in `skills/gadd-next/references/gate-detection.md`:

- Approval Gate Detection
- Verification Gate Detection
- Closure Gate Detection
- Archive Cleanup Detection
- Implementation PR State Detection

## Stop Conditions

- requested Work Item ID not found
- ledger cannot be parsed
- multiple active drafts and no Work Item ID was supplied
- external tracker drift is detected
- external issue body changed since the last recorded sync hash or timestamp
- implementation PR state cannot be checked when it is required to choose the next gate
