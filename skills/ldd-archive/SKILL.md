---
name: ldd-archive
description: Run /ldd:archive for closed LDD tickets. Use when the user says /ldd:archive or wants optional local cleanup after /ldd:close has completed.
---

# /ldd:archive

Move already-closed local LDD ticket packages into the configured archive directory. This command is storage hygiene only; it does not decide closure readiness and does not mutate external trackers.

## Inputs

```text
/ldd:archive <child-ticket-id>
/ldd:archive <parent-ticket-id>
```

If no ticket ID is provided, stop and ask for one.

## Reads

- target ticket `ledger.yml`
- parent ticket `ledger.yml` when archiving a child
- child ticket ledgers when archiving a parent
- `.ldd/config.yml`
- configured `archive_directory`

## Writes

- target ticket ledger archive state
- parent ledger child paths when archiving children
- local filesystem moves under configured `archive_directory`

No external tracker writes are allowed.

## Input Quality Gate

Required input standard before archiving:

- requested ticket exists and has a readable ledger
- requested ticket is already closed with `closure.status: closed | externally_closed | archived`
- parent archive requested only when every child is already closed, externally closed, or archived
- configured archive directory is known
- archive move will not overwrite an existing directory
- no unresolved local path ambiguity

If inputs fail this standard, do not move anything. The earliest LDD command that can repair missing closure state is `/ldd:close`; ambiguous workflow state routes to `/ldd:next`.

## Rules

- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- External mutations require human confirmation, but this command never performs external mutations.
- Archive only after closure. Do not archive verified-but-unclosed tickets.
- Preserve the ledger, ticket body, PRD, SDD, plan, verification reports, and implementation evidence.
- Move files only under configured `archive_directory`; default is `docs/tickets/_archive`.
- Do not archive drafts from this command.
- Keep references readable by rewriting moved paths in the moved ledgers and the parent ledger.
- Archiving is optional cleanup. It must not be required for `/ldd:next` to report done after closure.

## Child Workflow

1. Resolve the child ticket directory and read its `ledger.yml`.
2. Confirm `closure.status: closed | externally_closed | archived`.
3. Read the parent ledger referenced by the child.
4. Resolve the archive target under `archive_directory`.
5. Stop if the archive target already exists.
6. Update the child ledger:
   - set `closure.status: archived`
   - preserve `closed_at`, `verified_at`, and `external_closed_at`
   - set `archived_at`
   - add a `child_archived` event
   - update artifact paths to the archive target
7. Move the child directory to the archive target.
8. Update the parent ledger child entry:
   - set child `status: archived`
   - update child `path` to the archive ledger path
9. Recompute parent `execution_context` without creating new workflow work.

## Parent Roll-up Workflow

1. Read the parent ledger and every child ledger path listed in `children`.
2. Stop if any child is verified but not closed, or otherwise not closed, externally closed, or archived.
3. Archive any remaining closed child using the child workflow.
4. Update the parent ledger:
   - set `closure.status: archived`
   - preserve `closed_at` and `external_closed_at`
   - set `archived_at`
   - add a `parent_archived` event
   - rewrite artifact paths to the parent archive target
   - keep child references pointing to archived child ledgers
5. Move the parent directory to the archive target.
6. Report that archival cleanup is complete.

## Ledger Update Contract

After archiving a child, child ledger state should be equivalent to:

```yaml
closure:
  status: archived
  verified_at: 2026-05-13T00:00:00Z
  closed_at: 2026-05-13T00:00:00Z
  archived_at: 2026-05-13T00:00:00Z
  external_closed_at: null
  override_reason: null
events:
  - at: 2026-05-13T00:00:00Z
    type: child_archived
    actor: agent
```

After archiving a parent, parent ledger state should be equivalent to:

```yaml
closure:
  status: archived
  closed_at: 2026-05-13T00:00:00Z
  archived_at: 2026-05-13T00:00:00Z
events:
  - at: 2026-05-13T00:00:00Z
    type: parent_archived
    actor: agent
```

## Stop Conditions

- requested ticket is missing
- ledger cannot be parsed
- ticket is not closed yet
- child verification exists but closure has not been applied
- parent archive requested while any child is not closed or archived
- archive directory is missing and cannot be created safely
- archive target already exists
- external mutation is requested
