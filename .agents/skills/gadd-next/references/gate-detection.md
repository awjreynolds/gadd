# GADD next: Gate Detection

Detailed gate-detection field rules referenced from `skills/gadd-next/SKILL.md`. The skill body keeps the command contract and Decision Tree; this reference holds the deeper per-gate field rules.

## Approval Gate Detection

Treat a PRD as waiting for approval when either:

- `execution_context.phase` is `refine` and `execution_context.current_gate: prd_approval`
- `execution_context.current_gate: prd_approval` and `execution_context.next_command` is `/gadd:approve <work-item-id>`

Do not treat every draft PRD as approval-ready. Drafts in `scope` or `elaborate` must route to `/gadd:elaborate` or `/gadd:refine`, even when `approved_artifacts.prd` is empty.

Report:

```text
next_command: /gadd:approve <work-item-id>
next_human_action: /gadd:approve <work-item-id>
```

Treat an SDD as waiting for approval when either:

- `execution_context.current_gate: design_review`
- `artifacts.sdd.status: draft` and `artifacts.prd.status: approved`
- `work_item.type: engineering_change`, `artifacts.sdd.status: draft`, and `triage.approved_outcome.status: approved` plus `triage.approved_outcome.approved_hash` are recorded

Report:

```text
next_command: /gadd:approve <work-item-id>
next_human_action: /gadd:approve <work-item-id>
```

Treat a plan as waiting for approval when either:

- `execution_context.current_gate: plan_review`
- `artifacts.plan.status: draft` and `artifacts.sdd.status: approved`

Report:

```text
next_command: /gadd:approve <work-item-id>
next_human_action: /gadd:approve <work-item-id>
```

If more than one PRD, SDD, or plan approval gate appears active, report the ambiguity and route to human reconciliation. Do not choose one silently.

## Verification Gate Detection

Treat an active child as needing verification when either of these is true:

- `execution_context.current_gate: verification` or `execution_context.next_command` is `/gadd:verify <work-item-id>`.
- Derived state shows implementation completed while closure is not verified.

Derived state means implementation evidence exists, for example `artifacts.implementation.status: completed`, `artifacts.implementation.evidence`, a recorded implementation completion event, or equivalent local changed-file/check evidence in the child ledger; and closure is unverified, for example missing `closure`, `closure.status: open`, `closure.status: verification_required`, missing `artifacts.verification`, or `artifacts.verification.status: missing | pending | failed`.

Do not route archived, closed, or externally closed children, or children with `closure.status: verified | closed | archived | externally_closed`, to `/gadd:verify`.

## Closure Gate Detection

Treat an active child as ready to close when either of these is true:

- `execution_context.current_gate: closure` or `execution_context.next_command` is `/gadd:close <work-item-id>`.
- Derived state shows verification passed while closure has not been applied.

Derived state means `artifacts.verification.status: passed`, `closure.status: verified`, a readable `verification.md`, and the child directory is still in the active Work Item tree rather than `_archive/`.

If `closure.status: verified | closed | externally_closed | archived` appears without completed implementation evidence, passed verification evidence, and the required verification report for a closeable state, report `next_command: blocked` and `next_human_action: reconcile rogue Work Item state before continuing`. Do not treat a direct ledger status edit as proof that GADD gates ran.

Do not route children with `closure.status: closed | archived | externally_closed` to `/gadd:close`.

Treat a parent as ready for roll-up closure when it has at least one child and every child is either:

- already closed with `closure.status: closed | archived | externally_closed`
- closeable with `artifacts.verification.status: passed`, `closure.status: verified`, and a readable `verification.md`

If any child is implemented but unverified, route to `/gadd:verify <work-item-id>`. If any child is ready but not implemented, route to `/gadd:implement <work-item-id>`.

## Archive Cleanup Detection

Treat a Work Item as optionally ready to archive when it has `closure.status: closed | externally_closed`, lives in the active Work Item tree, and the configured `archive_directory` exists or can be created safely. Report this as optional cleanup, not as `next_command`, unless the user explicitly asks for `/gadd:archive`.

## Implementation PR State Detection

When a parent or child ledger records implementation PR evidence, for example `artifacts.implementation.pr`, `artifacts.implementation.evidence.implementation_pr`, or equivalent PR URL/number:

- Read the external PR state from the configured tracker before reporting `/gadd:verify` or `/gadd:close`.
- For GitHub, inspect the PR number or URL and check at least `state`, `mergedAt`, and merge commit.
- If the PR is open, report `next_command: blocked` and `next_human_action: review and merge implementation PR`.
- If the PR is merged, route to `/gadd:verify <work-item-id>`. Verification owns recording observed merge evidence and deciding whether the child can pass.
- If the PR is closed without merge, report `next_command: blocked` and route back to `/gadd:implement <work-item-id>` or human reconciliation depending on the child state.

Never treat a conversational claim such as "merged" as merge evidence. The claim may explain why the command should check the external tracker, but it is not workflow state.
