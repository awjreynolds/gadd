---
name: ldd-close
description: Run /ldd:close for verified LDD child tickets or parent roll-up closure. Use when the user says /ldd:close or wants to apply human-approved workflow closure after /ldd:verify passed.
---

# /ldd:close

Apply closure for one verified child work item, or apply parent roll-up closure when every child is verified and closeable. Closure records workflow completion and optional external issue closure; it does not archive local ticket files.

This command is a standalone, agent-agnostic LDD command. It does not decide whether implementation is correct; `/ldd:verify` owns that gate.

## Inputs

```text
/ldd:close <child-ticket-id>
/ldd:close <parent-ticket-id>
```

If no ticket ID is provided, stop and ask for one.

## Reads

- child ticket `ledger.yml`
- child `verification.md`
- parent ticket `ledger.yml`
- `.ldd/config.yml`
- external drift metadata when configured

## Writes

- child ledger `closure.status`
- child ledger `closure.closed_at` and optional `closure.external_closed_at`
- parent ledger child status and `execution_context`
- parent ledger closure status when closing a parent
- external tracker close/sync only after explicit human confirmation

## Input Quality Gate

Required input standard before closure:

- requested child has `artifacts.verification.status: passed`, `closure.status: verified`, and readable `verification.md`; or requested parent has every child closed or verified and closeable
- external tracker drift is resolved before any external mutation
- explicit human confirmation exists for external close or sync

If inputs fail this standard, do not close anything. The earliest LDD command that can repair missing closure evidence is `/ldd:verify`; ambiguous workflow state routes to `/ldd:next`; unresolved external drift routes to human reconciliation.

## Rules

- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- External mutations require human confirmation.
- Close child work items directly. Close a parent Product Requirement only when the requested ID is the parent ID and every child is verified and closeable.
- Require `artifacts.verification.status: passed` and `closure.status: verified` before closing a child.
- Parent roll-up closure requires every child to be closeable: each child is already closed, externally closed, or archived; or has `artifacts.verification.status: passed`, `closure.status: verified`, and a readable `verification.md`.
- Require a readable `verification.md` report before closing.
- Refuse closure when verification is missing, pending, failed, or `override_required`.
- Refuse closure when external tracker drift is unresolved.
- Do not archive or move local ticket directories from this command. Use `/ldd:archive <ticket-id>` for optional local cleanup after closure.
- In GitHub tracker mode, GitHub issue closure is the expected external close projection and requires explicit human confirmation after drift checks. Linear and Jira closure is follow-on optional scope.
- Preserve the child ledger, ticket body, verification report, and implementation evidence.
- Update `/ldd:next` state by pointing the parent ledger to the next close, verify, implement, decompose, done, or optional archive gate.

## Child Workflow

1. Resolve the child ticket directory and read its `ledger.yml`.
2. Read the parent ledger.
3. Confirm verification passed:
   - `artifacts.verification.status: passed`
   - `closure.status: verified`
   - `verification.md` exists
4. Check external drift metadata. If drift is unresolved, stop.
5. If an external tracker is configured, confirm the requested close action authorizes closing the matching external issue. If not clear, ask for explicit confirmation before mutating it.
6. Update the child ledger:
   - set `closure.status: closed` for local-only closure
   - set `closure.status: externally_closed` when the matching external issue was actually closed
   - set `closed_at`
   - set `external_closed_at` only if an external close actually occurred
   - add a `child_closed` event
7. Keep the child directory in place.
8. Update the parent ledger child entry to `closed` or `externally_closed` and keep `path` unchanged.
9. Recompute parent `execution_context`:
   - verified but unclosed child: `/ldd:close <child-id>`
   - implemented but unverified child: `/ldd:verify <child-id>`
   - ready child: `/ldd:implement <child-id>`
   - approved plan with no children: `/ldd:decompose`
   - all children closed: report parent ready for final close or done
10. Report the closure result and next command.

## Parent Roll-up Workflow

Use this workflow only when the requested ticket ID is a parent Product Requirement.

1. Read the parent ledger and all child ledger paths listed in `children`.
2. Stop if the parent has no children; parent closure without decomposition is outside the MVP unless explicitly requested by the human.
3. For each child, classify it:
   - closed: `closure.status: closed | externally_closed | archived`
   - closeable: `artifacts.verification.status: passed`, `closure.status: verified`, and `verification.md` exists
   - blocked: anything else
4. If any child is blocked, stop and report the blocking child IDs with the next command for each child.
5. If every child is closed or closeable, close any remaining closeable child using the child workflow.
6. After all child entries are closed, update the parent ledger:
   - set `closure.status: closed` for local-only parent closure
   - set `closure.status: externally_closed` when the matching external parent issue was actually closed
   - set `closed_at`
   - add a `parent_closed` event
   - keep all child references and paths intact
7. Keep the parent directory in place.
8. If an external parent tracker is configured, confirm the requested close action authorizes closing the matching external parent issue. If not clear, ask for explicit confirmation before mutating it.
9. Report that the parent is closed and that `/ldd:next` has no remaining required work for that parent. Mention `/ldd:archive <parent-ticket-id>` only as optional local cleanup.

## Ledger Update Contract

After local-only closure, child ledger state should be equivalent to:

```yaml
closure:
  status: closed
  verified_at: 2026-05-13T00:00:00Z
  closed_at: 2026-05-13T00:00:00Z
  archived_at: null
  external_closed_at: null
  override_reason: null
events:
  - at: 2026-05-13T00:00:00Z
    type: child_closed
    actor: agent
```

Parent ledger child entry should be equivalent to:

```yaml
children:
  - id: LDD-0001-001
    status: closed
    path: docs/tickets/LDD-0001/children/LDD-0001-001-slug/ledger.yml
```

Preserve existing unrelated ledger fields and events.

After parent roll-up closure, parent ledger state should be equivalent to:

```yaml
closure:
  status: closed
  closed_at: 2026-05-13T00:00:00Z
  archived_at: null
events:
  - at: 2026-05-13T00:00:00Z
    type: parent_closed
    actor: agent
```

## External Tracker Rule

If the child has an external tracker projection, `/ldd:close` may close or sync it only after explicit human confirmation in the current turn. If confirmation is missing, close locally only when safe and report the pending external action, or stop if the requested operation requires external consistency.

In GitHub tracker mode:

- Close the matching GitHub issue only after confirmation and drift checks.
- Do not close implementation PRs from this command; PR merge is implementation evidence, not ticket closure.
- Do not rely on GitHub auto-close keywords from PR bodies. LDD keeps verification and closure as separate gates.
- Record the GitHub issue closed state in `external_closed_at` and use `closure.status: externally_closed` only after the external close succeeds.

If external drift exists, stop and ask the human to reconcile before closing.

## Stop Conditions

- missing child ticket
- missing parent ledger
- missing `verification.md`
- `artifacts.verification.status` is not `passed`
- requested child `closure.status` is not `verified`
- parent close requested while any child is not verified and closeable
- unresolved external drift
- external close requested without explicit human confirmation
- requested archive or file movement; use `/ldd:archive <ticket-id>` instead
