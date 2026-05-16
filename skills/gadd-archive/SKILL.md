---
name: gadd-archive
description: Run /gadd:archive to move already-closed GADD Work Item packages into the local archive directory after /gadd:close. Use when the user says /gadd:archive, asks for cleanup after close, asks to move closed Work Items out of the active tree, asks to tidy gadd/work-items, or says things like "archive this closed Work Item", "clean up after close", or "shrink the active Work Item list". Archive is optional storage hygiene; it never decides closure readiness and never mutates external trackers.
---

# /gadd:archive

Move already-closed local Work Item packages into the configured archive directory. This command is storage hygiene only; it does not decide closure readiness and does not mutate external trackers.

This command is a standalone, agent-agnostic GADD command. Follow this file directly; do not require any other installed skill.

## Inputs

```text
/gadd:archive <work-item-id>
/gadd:archive <parent-work-item-id>
```

If no Work Item ID is provided, stop and ask for one.

## Reads

- target Work Item `ledger.yml`
- parent Work Item `ledger.yml` when archiving a child
- child Work Item ledgers when archiving a parent
- `gadd/config.yml`
- configured `archive_directory`

## Writes

- target Work Item ledger archive state
- parent ledger child paths when archiving children
- local filesystem moves under configured `archive_directory`

No external tracker writes are allowed.

## Input Quality Gate

Required input standard before archiving:

- requested Work Item exists and has a readable ledger
- requested Work Item is already closed with `closure.status: closed | externally_closed | archived`
- parent archive requested only when every child is already closed, externally closed, or archived
- configured archive directory is known
- archive move will not overwrite an existing directory
- no unresolved local path ambiguity

If inputs fail this standard, do not move anything. The earliest GADD command that can repair missing closure state is `/gadd:close`; ambiguous workflow state routes to `/gadd:next`.

## Rules

- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- External mutations require human confirmation, but this command never performs external mutations.
- Archive only after closure. Do not archive verified-but-unclosed Work Items.
- Preserve the ledger, Work Item body, PRD, SDD, plan, verification reports, and implementation evidence.
- Move files only under configured Work Item archive directory; default is `gadd/work-items/_archive`.
- Do not archive drafts from this command.
- Keep references readable by rewriting moved paths in the moved ledgers and the parent ledger.
- Archiving is optional cleanup. It must not be required for `/gadd:next` to report done after closure.

## Direct Work Item Workflow

1. Resolve the Work Item directory and read its `ledger.yml`.
2. Confirm `closure.status: closed | externally_closed | archived`.
3. Read the parent ledger only when the Work Item records one.
4. Resolve the archive target under `archive_directory`.
5. Stop if the archive target already exists.
6. Update the Work Item ledger:
   - set `closure.status: archived`
   - preserve `closed_at`, `verified_at`, and `external_closed_at`
   - set `archived_at`
   - add a `work_item_archived` event
   - update artifact paths to the archive target
7. Move the Work Item directory to the archive target.
8. If a parent ledger exists, update the parent ledger child entry:
   - set child `status: archived`
   - update child `path` to the archive ledger path
9. If a parent ledger was updated, recompute parent `execution_context` without creating new workflow work.

## Parent Roll-up Workflow

1. Read the parent ledger and every child ledger path listed in `children`.
2. Stop if any child is verified but not closed, or otherwise not closed, externally closed, or archived.
3. Archive any remaining closed child using the direct Work Item workflow.
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

After archiving a Work Item, Work Item ledger state should be equivalent to:

```yaml
closure:
  status: archived
  verified_at: <iso8601-timestamp>
  closed_at: <iso8601-timestamp>
  archived_at: <iso8601-timestamp>
  external_closed_at: null
  override_reason: null
events:
  - at: <iso8601-timestamp>
    type: work_item_archived
    actor: agent
```

After archiving a parent, parent ledger state should be equivalent to:

```yaml
closure:
  status: archived
  closed_at: <iso8601-timestamp>
  archived_at: <iso8601-timestamp>
events:
  - at: <iso8601-timestamp>
    type: parent_archived
    actor: agent
```

## Stop Conditions

- requested Work Item is missing
- ledger cannot be parsed
- Work Item is not closed yet
- child verification exists but closure has not been applied
- parent archive requested while any child is not closed or archived
- archive directory is missing and cannot be created safely
- archive target already exists
- external mutation is requested
