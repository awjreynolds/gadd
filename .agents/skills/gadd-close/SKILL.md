---
name: gadd-close
description: Run /gadd:close to wrap up a verified GADD Work Item or apply parent roll-up closure once every child is verified and closeable. Use when the user says /gadd:close, asks to mark a Work Item complete or done, asks to apply human-approved workflow closure after /gadd:verify passed, asks to close the parent after all children are verified, or says things like "this is verified, close it", "roll up the parent", or "we're done with this Work Item". Closure is the Engineering Review gate after /gadd:verify; it does not archive local files (use /gadd:archive) and mutates external trackers only after explicit human confirmation.
---

# /gadd:close

Apply closure for one verified Work Item, or apply parent roll-up closure when every child Work Item is verified and closeable. Closure records workflow completion and optional External Issue closure; it does not archive local Work Item files.

Close one verified Work Item, or close a parent Work Item only when every child Work Item is verified and closeable.

This command is a standalone, agent-agnostic GADD command. It does not decide whether implementation is correct; `/gadd:verify` owns that gate.

## Inputs

```text
/gadd:close <work-item-id>
/gadd:close <parent-work-item-id>
```

If no Work Item ID is provided, stop and ask for one.

## Reads

- Work Item `ledger.yml`
- Work Item `verification.md`
- parent Work Item `ledger.yml` when the Work Item is a child or a parent roll-up is requested
- `gadd/config.yml`
- external drift metadata when configured

## Writes

- Work Item ledger `closure.status`
- Work Item ledger `closure.closed_at` and optional `closure.external_closed_at`
- parent ledger child status and `execution_context` when the closed Work Item is a child
- parent ledger closure status when closing a parent
- external tracker close/sync only after explicit human confirmation

## Input Quality Gate

Required input standard before closure:

- requested Work Item has `artifacts.verification.status: passed`, `closure.status: verified`, and readable `verification.md`; or requested parent has every child Work Item closed or verified and closeable
- external tracker drift is resolved before any external mutation
- explicit human confirmation exists for external close or sync

If inputs fail this standard, do not close anything. The earliest GADD command that can repair missing closure evidence is `/gadd:verify`; ambiguous workflow state routes to `/gadd:next`; unresolved external drift routes to human reconciliation.

## Rules

- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- External mutations require human confirmation.
- Close Work Items directly. Close a parent Work Item only when the requested ID is the parent ID and every child Work Item is verified and closeable.
- Require `artifacts.verification.status: passed` and `closure.status: verified` before closing a Work Item.
- Parent roll-up closure requires every child to be closeable: each child is already closed, externally closed, or archived; or has `artifacts.verification.status: passed`, `closure.status: verified`, and a readable `verification.md`.
- Require a readable `verification.md` report before closing.
- Refuse closure when verification is missing, pending, failed, or `override_required`.
- Refuse closure when external tracker drift is unresolved.
- Do not archive or move local Work Item directories from this command. Use `/gadd:archive <work-item-id>` for optional local cleanup after closure.
- In GitHub tracker mode, GitHub issue closure is the expected external close projection and requires explicit human confirmation after drift checks. Linear and Jira closure is follow-on optional scope.
- Preserve the Work Item ledger, Work Item body, verification report, and implementation evidence.
- Update `/gadd:next` state by pointing the parent ledger to the next close, verify, implement, decompose, done, or optional archive gate.

## Direct Work Item Workflow

1. Resolve the Work Item directory and read its `ledger.yml`.
2. Confirm verification passed:
   - `artifacts.verification.status: passed`
   - `closure.status: verified`
   - `verification.md` exists
3. Check external drift metadata. If drift is unresolved, stop.
4. If an external tracker is configured, confirm the requested close action authorizes closing the matching external issue. If not clear, ask for explicit confirmation before mutating it.
5. Update the Work Item ledger:
   - set `closure.status: closed` for local-only closure
   - set `closure.status: externally_closed` when the matching external issue was actually closed
   - set `closed_at`
   - set `external_closed_at` only if an external close actually occurred
   - add a `work_item_closed` event
6. Keep the Work Item directory in place.
7. If the Work Item has a parent ledger, update the parent ledger child Work Item entry to `closed` or `externally_closed` and keep `path` unchanged.
8. If a parent ledger was updated, recompute parent `execution_context`:
   - verified but unclosed child Work Item: `/gadd:close <work-item-id>`
   - implemented but unverified child Work Item: `/gadd:verify <work-item-id>`
   - ready child Work Item: `/gadd:implement <work-item-id>`
   - approved plan with no children: `/gadd:decompose`
   - all children closed: report parent ready for final close or done
9. Report the closure result and next command.

## Parent Roll-up Workflow

Use this workflow only when the requested Work Item ID is a parent Product Requirement.

1. Read the parent ledger and all child ledger paths listed in `children`.
2. Stop if the parent has no children; parent closure without decomposition is outside the MVP unless explicitly requested by the human.
3. For each child, classify it:
   - closed: `closure.status: closed | externally_closed | archived`
   - closeable: `artifacts.verification.status: passed`, `closure.status: verified`, and `verification.md` exists
   - blocked: anything else
4. If any child is blocked, stop and report the blocking child IDs with the next command for each child.
5. If every child is closed or closeable, close any remaining closeable child using the direct Work Item workflow.
6. After all child entries are closed, update the parent ledger:
   - set `closure.status: closed` for local-only parent closure
   - set `closure.status: externally_closed` when the matching external parent issue was actually closed
   - set `closed_at`
   - add a `parent_closed` event
   - keep all child references and paths intact
7. Keep the parent directory in place.
8. If an external parent tracker is configured, confirm the requested close action authorizes closing the matching external parent issue. If not clear, ask for explicit confirmation before mutating it.
9. Report that the parent is closed and that `/gadd:next` has no remaining required work for that parent. Mention `/gadd:archive <parent-work-item-id>` only as optional local cleanup.

## Ledger Update Contract

After local-only closure, Work Item ledger state should be equivalent to:

```yaml
closure:
  status: closed
  verified_at: <iso8601-timestamp>
  closed_at: <iso8601-timestamp>
  archived_at: null
  external_closed_at: null
  override_reason: null
events:
  - at: <iso8601-timestamp>
    type: work_item_closed
    actor: agent
```

Parent ledger child Work Item entry should be equivalent to:

```yaml
children:
  - id: GADD-0001-001
    status: closed
    path: gadd/work-items/GADD-0001/children/GADD-0001-001-slug/ledger.yml
```

Preserve existing unrelated ledger fields and events.

After parent roll-up closure, parent ledger state should be equivalent to:

```yaml
closure:
  status: closed
  closed_at: <iso8601-timestamp>
  archived_at: null
events:
  - at: <iso8601-timestamp>
    type: parent_closed
    actor: agent
```

## External Tracker Rule

If the child has an external tracker projection, `/gadd:close` may close or sync it only after explicit human confirmation in the current turn. If confirmation is missing, close locally only when safe and report the pending external action, or stop if the requested operation requires external consistency.

In GitHub tracker mode:

- Close the matching GitHub issue only after confirmation and drift checks.
- Do not close implementation PRs from this command; PR merge is implementation evidence, not Work Item closure.
- Do not rely on GitHub auto-close keywords from PR bodies. GADD keeps verification and closure as separate gates.
- Record the GitHub issue closed state in `external_closed_at` and use `closure.status: externally_closed` only after the external close succeeds.

If external drift exists, stop and ask the human to reconcile before closing.

## Stop Conditions

- missing Work Item
- missing parent ledger when the requested Work Item is a child or parent roll-up
- missing `verification.md`
- `artifacts.verification.status` is not `passed`
- requested Work Item `closure.status` is not `verified`
- parent close requested while any child Work Item is not verified and closeable
- unresolved external drift
- external close requested without explicit human confirmation
- requested archive or file movement; use `/gadd:archive <work-item-id>` instead
