---
name: ldd-approve
description: Run /ldd:approve for an LDD ticket. Use when the user says /ldd:approve or wants to approve a PRD or SDD from repo-local ledger state.
---

# /ldd:approve

Approve exactly one PRD or SDD gate for an LDD ticket.

This command is a standalone, agent-agnostic LDD command. Follow this file directly; do not require any other installed skill.

Scope this command to PRD and SDD approval only. It does not approve implementation plans, decomposition, closure, external tracker mutation, PR merges, or broad workflow automation.

## Input

```text
/ldd:approve <ticket-id>
```

If no ticket ID is provided, stop and ask for the target ticket ID. Do not infer approval from unrelated modified files or conversational shorthand.

## Reads

- target ticket `ledger.yml`
- target PRD frontmatter and body
- target SDD frontmatter and body when present
- `.ldd/config.yml` when present
- external tracker sync metadata when configured

Read the ledger first. Use the ledger to locate the PRD and SDD paths, artifact statuses, current gate, approved artifact boundaries, and next action.

## Writes

- PRD frontmatter/status when approving the PRD
- SDD frontmatter/status when approving the SDD
- target ticket `ledger.yml`
- compact ledger events

Do not write implementation plans, child tickets, verification reports, archive locations, external trackers, or unrelated repository files from this command.

## Rules

- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- External mutations require human confirmation.
- Approve only when exactly one approval gate is active.
- PRD approval is allowed only for a draft PRD gate.
- SDD approval is allowed only when the PRD is already approved and a draft SDD gate is active.
- `/ldd:approve` does not approve plan review, decomposition review, closure, verification overrides, external issue creation, external issue updates, external close, PR creation, PR update, or PR merge.
- Preserve approved boundaries. If approval would change product scope or design, stop and route to `/ldd:scope`, `/ldd:elaborate`, `/ldd:refine`, or `/ldd:design`.
- In local tracker mode, approval mutates only repo-local artifacts and ledger state.
- In GitHub tracker mode, approval may prepare a managed projection using the configured templates, but it must ask for explicit human confirmation before creating or updating an external issue or PR.
- If external drift is detected, stop before mutation and ask the human to reconcile the external contribution.
- Commit locally after approval when you changed files.

## Gate Detection

Determine candidate gates from ledger state:

- PRD candidate:
  - `execution_context.phase` is `refine` and `execution_context.current_gate: prd_approval`, or
  - `execution_context.current_gate: prd_approval` and `execution_context.next_command` is `/ldd:approve <ticket-id>`.
- SDD candidate:
  - `execution_context.current_gate: design_review`, or
  - `artifacts.sdd.status: draft` and `artifacts.prd.status: approved`.

Then filter candidates:

- Remove the PRD candidate if the PRD path is missing.
- Remove the PRD candidate if the ledger is still in `scope` or `elaborate`.
- Remove the SDD candidate if the SDD path is missing.
- Remove any candidate whose artifact frontmatter already has `status: approved` and ledger artifact status is already `approved`.

Proceed only when exactly one candidate remains.

Stop when:

- no candidate remains
- more than one candidate remains
- the candidate artifact is missing
- the PRD is not approved before SDD approval
- the current gate is plan review, decomposition review, implementation, verification, closure, or external mutation confirmation

When blocked, report the gate candidates and the next command that owns the state.

## PRD Approval Workflow

1. Confirm the PRD exists and passes the Product Manager handoff checklist.
2. If the ticket is still in a draft directory and approval is promoting it, assign or preserve the stable ticket ID according to the existing local ledger convention.
3. Mark PRD frontmatter `status: approved` and update `updated`.
4. Update ledger:
   - `ticket.status: approved`
   - `artifacts.prd.status: approved`
   - `execution_context.phase: design`
   - `execution_context.current_gate: design`
   - `execution_context.next_command: /ldd:design <ticket-id>`
   - `execution_context.next_human_action: null`
   - `execution_context.next_reason: PRD is approved and ready for engineering design.`
   - `execution_context.approved_artifacts.prd` to the PRD path
   - `execution_context.boundaries.product` to the PRD path
5. Append a `prd_approved` event with `actor: human`.
6. In external tracker mode, prepare the Product Requirement projection from `.ldd/templates/issue-body-prd.md`, ask for explicit human confirmation before creating/updating it, then record the external ID/URL/hash only after success.
7. Report the next command: `/ldd:design <ticket-id>`.

## SDD Approval Workflow

1. Confirm the PRD is approved in the ledger.
2. Confirm the SDD exists and passes the SDD review checklist.
3. Mark SDD frontmatter `status: approved` and update `updated`.
4. Update ledger:
   - `ticket.status: approved`
   - `artifacts.sdd.status: approved`
   - `execution_context.phase: plan`
   - `execution_context.current_gate: plan`
   - `execution_context.next_command: /ldd:plan <ticket-id>`
   - `execution_context.next_human_action: null`
   - `execution_context.next_reason: Software Design Document is approved and ready for implementation planning.`
   - `execution_context.approved_artifacts.sdd` to the SDD path
   - `execution_context.boundaries.design` to the SDD path
5. Append an `sdd_approved` event with `actor: human`.
6. In GitHub tracker mode, prepare or update the SDD/plan review PR projection only after explicit human confirmation and drift checks.
7. Report the next command: `/ldd:plan <ticket-id>`.

## GitHub Projection Rule

GitHub is the first external tracker dogfooding path, but it is still a projection:

- GitHub issues represent PRD and child work visibility.
- GitHub PRs represent SDD/plan review and implementation review.
- The local ledger remains canonical for phase state, approvals, and closure.
- Every GitHub create, update, comment, label, close, or PR mutation needs explicit human confirmation.
- Before updating a managed GitHub body, re-read the external body and compare recorded hash/timestamp. If it changed, stop and ask the human to reconcile.

Linear and Jira are follow-on optional collaboration surfaces. Do not invent Linear or Jira behavior while implementing this command.

## Ledger Update Contract

For PRD approval, use existing ledger fields:

```yaml
artifacts:
  prd:
    status: approved
execution_context:
  phase: design
  current_gate: design
  next_command: /ldd:design LDD-0003
  next_human_action: null
events:
  - at: 2026-05-13T00:00:00Z
    type: prd_approved
    actor: human
```

For SDD approval, use existing ledger fields:

```yaml
artifacts:
  sdd:
    status: approved
execution_context:
  phase: plan
  current_gate: plan
  next_command: /ldd:plan LDD-0003
  next_human_action: null
events:
  - at: 2026-05-13T00:00:00Z
    type: sdd_approved
    actor: human
```

Preserve existing unrelated ledger fields and events.

## Stop Conditions

- missing ticket ID
- missing or unreadable ledger
- missing PRD for PRD approval
- missing SDD for SDD approval
- PRD is not approved before SDD approval
- no active PRD or SDD approval gate
- multiple active approval gates
- requested approval is for plan, decomposition, verification, closure, or external mutation
- external drift is detected
- external mutation is needed but human confirmation is not explicit
