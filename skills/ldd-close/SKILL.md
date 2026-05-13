---
name: ldd-close
description: Run /ldd:close for verified LDD child tickets or parent roll-up closure. Use when the user says /ldd:close or wants to apply human-approved closure after /ldd:verify passed.
---

# /ldd:close

Apply closure for one verified child work item, or apply parent roll-up closure when every child is verified and closeable.

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
- parent ledger child status and `execution_context`
- parent ledger closure status and archive location when closing a parent
- archive location under configured `archive_directory`
- external tracker close/sync only after explicit human confirmation

## Rules

- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- External mutations require human confirmation.
- Close child work items directly. Close a parent Product Requirement only when the requested ID is the parent ID and every child is verified and closeable.
- Require `artifacts.verification.status: passed` and `closure.status: verified` before closing a child.
- Parent roll-up closure requires every child to be closeable: each child is already archived/externally closed, or has `artifacts.verification.status: passed`, `closure.status: verified`, and a readable `verification.md`.
- Require a readable `verification.md` report before closing.
- Refuse closure when verification is missing, pending, failed, or `override_required`.
- Refuse closure when external tracker drift is unresolved.
- Archive locally; do not delete evidence. This command may archive child tickets only after local ledger updates are ready.
- In GitHub tracker mode, GitHub issue or PR closure is an external mutation and requires explicit human confirmation after drift checks. Linear and Jira closure is follow-on optional scope.
- Preserve the child ledger, ticket body, verification report, and implementation evidence.
- Update `/ldd:next` state by pointing the parent ledger to the next close, verify, implement, decompose, or done gate.

## Child Workflow

1. Resolve the child ticket directory and read its `ledger.yml`.
2. Read the parent ledger and configured archive directory.
3. Confirm verification passed:
   - `artifacts.verification.status: passed`
   - `closure.status: verified`
   - `verification.md` exists
4. Check external drift metadata. If drift is unresolved, stop.
5. If an external tracker is configured, ask for explicit confirmation before mutating it.
6. Update the child ledger:
   - set `closure.status: archived` for local-only closure
   - set `archived_at`
   - add a `child_archived` event
   - set `external_closed_at` only if an external close actually occurred
7. Move the child directory to `docs/tickets/_archive/<child-id>-<slug>/` or the configured archive directory.
8. Update the parent ledger child entry to `archived` and point `path` to the archive location.
9. Recompute parent `execution_context`:
   - verified but unarchived child: `/ldd:close <child-id>`
   - implemented but unverified child: `/ldd:verify <child-id>`
   - ready child: `/ldd:implement <child-id>`
   - approved plan with no children: `/ldd:decompose`
   - all children archived: report parent ready for final review or done
10. Report the closure result and next command.

## Parent Roll-up Workflow

Use this workflow only when the requested ticket ID is a parent Product Requirement.

1. Read the parent ledger and all child ledger paths listed in `children`.
2. Stop if the parent has no children; parent closure without decomposition is outside the MVP unless explicitly requested by the human.
3. For each child, classify it:
   - closed: `closure.status: archived | externally_closed`
   - closeable: `artifacts.verification.status: passed`, `closure.status: verified`, and `verification.md` exists
   - blocked: anything else
4. If any child is blocked, stop and report the blocking child IDs with the next command for each child.
5. If every child is closed or closeable, close any remaining closeable child using the child workflow.
6. After all child entries are archived or externally closed, update the parent ledger:
   - set `closure.status: archived` for local-only parent closure
   - set `closed_at`
   - add a `parent_closed` event
   - keep all child references and archive paths intact
7. Move the parent directory to `docs/tickets/_archive/<parent-id>-<slug>/` or the configured archive directory.
8. If an external parent tracker is configured, ask for explicit human confirmation before closing or syncing it.
9. Report that the parent is closed and that `/ldd:next` has no remaining work for that parent.

## Ledger Update Contract

After local-only closure, child ledger state should be equivalent to:

```yaml
closure:
  status: archived
  verified_at: 2026-05-13T00:00:00Z
  archived_at: 2026-05-13T00:00:00Z
  external_closed_at: null
  override_reason: null
events:
  - at: 2026-05-13T00:00:00Z
    type: child_archived
    actor: agent
```

Parent ledger child entry should be equivalent to:

```yaml
children:
  - id: LDD-0001-001
    status: archived
    path: docs/tickets/_archive/LDD-0001-001-slug/ledger.yml
```

Preserve existing unrelated ledger fields and events.

After parent roll-up closure, parent ledger state should be equivalent to:

```yaml
closure:
  status: archived
  closed_at: 2026-05-13T00:00:00Z
events:
  - at: 2026-05-13T00:00:00Z
    type: parent_closed
    actor: agent
```

## External Tracker Rule

If the child has an external tracker projection, `/ldd:close` may close or sync it only after explicit human confirmation in the current turn. If confirmation is missing, close locally only when safe and report the pending external action, or stop if the requested operation requires external consistency.

If external drift exists, stop and ask the human to reconcile before closing.

## Stop Conditions

- missing child ticket
- missing parent ledger
- missing `verification.md`
- `artifacts.verification.status` is not `passed`
- `closure.status` is not `verified`
- parent close requested while any child is not verified and closeable
- unresolved external drift
- external close requested without explicit human confirmation
- archive move would overwrite an existing archive directory
