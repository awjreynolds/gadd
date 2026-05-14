---
name: ldd-approve
description: Run /ldd:approve for an LDD ticket. Use when the user says /ldd:approve or wants to approve a PRD, SDD, or plan from repo-local ledger state.
---

# /ldd:approve

Approve exactly one PRD, SDD, or plan gate for an LDD ticket.

This command is a standalone, agent-agnostic LDD command. Follow this file directly; do not require any other installed skill.

Scope this command to PRD, SDD, and plan approval only. It does not approve decomposition, closure, PR merges, external mutations, or broad workflow automation.

## Input

```text
/ldd:approve <ticket-id>
```

If no ticket ID is provided, stop and ask for the target ticket ID. Do not infer approval from unrelated modified files or conversational shorthand.

## Reads

- target ticket `ledger.yml`
- target PRD frontmatter and body
- target SDD frontmatter and body when present
- target plan frontmatter and body when present
- `.ldd/config.yml` when present
- external tracker sync metadata when configured

Read the ledger first. Use the ledger to locate the PRD, SDD, and plan paths, artifact statuses, current gate, approved artifact boundaries, and next action.

## Writes

- PRD frontmatter/status when approving the PRD
- SDD frontmatter/status when approving the SDD
- plan frontmatter/status when approving the plan
- target ticket `ledger.yml`
- compact ledger events
- GitHub Product Requirement issue when approving a PRD in GitHub tracker mode
- GitHub SDD issue when approving an SDD in GitHub tracker mode

Do not write child tickets, verification reports, archive locations, or unrelated repository files from this command.

## Rules

- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- External mutations require human confirmation.
- Approve only when exactly one approval gate is active.
- PRD approval is allowed only for a draft PRD gate.
- SDD approval is allowed only when the PRD is already approved and a draft SDD gate is active.
- Plan approval is allowed only when the PRD and SDD are already approved and a draft plan gate is active.
- `/ldd:approve` does not approve decomposition review, closure, verification overrides, external close, PR creation, PR update, or PR merge.
- Preserve approved boundaries. If approval would change product scope, design, or plan content, stop and route to `/ldd:scope`, `/ldd:elaborate`, `/ldd:refine`, `/ldd:design`, or `/ldd:plan`.
- In local tracker mode, approval mutates only repo-local artifacts and ledger state.
- In GitHub tracker mode, PRD approval creates or binds the GitHub Product Requirement issue before local promotion. The explicit `/ldd:approve <draft-id>` invocation is the human confirmation to create or bind that Product Requirement issue. Other GitHub mutations still require their owning command and explicit confirmation.
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
- Plan candidate:
  - `execution_context.current_gate: plan_review`, or
  - `artifacts.plan.status: draft` and `artifacts.sdd.status: approved`.

Then filter candidates:

- Remove the PRD candidate if the PRD path is missing.
- Remove the PRD candidate if the ledger is still in `scope` or `elaborate`.
- Remove the SDD candidate if the SDD path is missing.
- Remove the Plan candidate if the plan path is missing.
- Remove any candidate whose artifact frontmatter already has `status: approved` and ledger artifact status is already `approved`.

Proceed only when exactly one candidate remains.

Stop when:

- no candidate remains
- more than one candidate remains
- the candidate artifact is missing
- the PRD is not approved before SDD approval
- the SDD is not approved before plan approval
- the current gate is decomposition review, implementation, verification, closure, or external mutation confirmation

When blocked, report the gate candidates and the next command that owns the state.

## PRD Approval Workflow

1. Confirm the PRD exists and passes the Product Manager handoff checklist.
2. If tracker mode is GitHub and the ticket is still in a draft directory:
   - Create or bind the GitHub Product Requirement issue before changing the local PRD.
   - Build the issue from the current draft `prd.md` content and `.ldd/templates/issue-body-prd.md`.
   - Use the returned GitHub issue number as the stable ticket ID.
   - Move the draft directory to `docs/tickets/<issue-number>-<short-slug>/`.
   - Set `ticket.id` and `tracker.external_id` to the issue number, and `tracker.external_url` to the issue URL.
   - Do not invent or preserve an `LDD-0004` style ID in GitHub tracker mode.
3. If tracker mode is local and the ticket is still in a draft directory, assign the next local ID according to the configured local ledger convention.
4. Mark PRD frontmatter `ticket` to the stable ticket ID, set `status: approved`, and update `updated`.
5. Update ledger:
   - `ticket.status: approved`
   - `artifacts.prd.status: approved`
   - `execution_context.phase: design`
   - `execution_context.current_gate: design`
   - `execution_context.next_command: /ldd:design <ticket-id>`
   - `execution_context.next_human_action: null`
   - `execution_context.next_reason: PRD is approved and ready for engineering design.`
   - `execution_context.approved_artifacts.prd` to the PRD path
   - `execution_context.boundaries.product` to the PRD path
6. Append a `prd_approved` event with `actor: human`.
7. Report the next command: `/ldd:design <ticket-id>`.

## SDD Approval Workflow

1. Confirm the PRD is approved in the ledger.
2. Confirm the SDD exists and passes the SDD review checklist.
3. In GitHub tracker mode, create or bind the GitHub SDD issue before marking the SDD approved:
   - Build the issue from the current SDD content and `.ldd/templates/issue-body-sdd.md`.
   - Reference the approved parent PRD issue number and URL in the SDD issue body.
   - Record the SDD issue number and URL under `artifacts.sdd.external_id` and `artifacts.sdd.external_url`.
   - Treat this SDD issue as the GitHub child ticket of the PRD issue.
4. Mark SDD frontmatter `status: approved` and update `updated`.
5. Update ledger:
   - `ticket.status: approved`
   - `artifacts.sdd.status: approved`
   - `execution_context.phase: plan`
   - `execution_context.current_gate: plan`
   - `execution_context.next_command: /ldd:plan <ticket-id>`
   - `execution_context.next_human_action: null`
   - `execution_context.next_reason: Software Design Document is approved and ready for implementation planning.`
   - `execution_context.approved_artifacts.sdd` to the SDD path
   - `execution_context.boundaries.design` to the SDD path
6. Append an `sdd_approved` event with `actor: human`.
7. Report the next command: `/ldd:plan <ticket-id>`.

## Plan Approval Workflow

1. Confirm the PRD and SDD are approved in the ledger.
2. Confirm the plan exists and passes the plan review checklist.
3. Mark plan frontmatter `status: approved` and update `updated`.
4. Update ledger:
   - `artifacts.plan.status: approved`
   - `execution_context.phase: decompose`
   - `execution_context.current_gate: decompose`
   - `execution_context.next_command: /ldd:decompose <ticket-id>`
   - `execution_context.next_human_action: null`
   - `execution_context.next_reason: Implementation plan is approved and ready for decomposition preview.`
   - `execution_context.approved_artifacts.plan` to the plan path
   - `execution_context.boundaries.plan` to the plan path
5. Append a `plan_approved` event with `actor: human`.
6. Report the next command: `/ldd:decompose <ticket-id>`.

## GitHub Projection Rule

GitHub is the first external tracker dogfooding path, but it is still a projection:

- GitHub issues represent PRD and child work visibility.
- GitHub issues represent SDD review visibility as a child ticket of the PRD issue.
- GitHub PRs represent implementation review.
- The local ledger remains canonical for phase state, approvals, and closure.
- PRD approval in GitHub tracker mode creates or binds the Product Requirement issue and uses the GitHub issue number as the promoted ticket ID.
- SDD approval in GitHub tracker mode creates or binds an SDD issue that references the PRD issue; decomposition-created implementation issues reference the SDD issue, so the PRD issue has grandchildren.
- Plan approval is repo-local gate approval. It does not create GitHub child issues; `/ldd:decompose` owns child issue preview and creation after its own explicit human confirmation.
- Every GitHub update, comment, label, close, or PR mutation after issue creation needs explicit human confirmation from the owning command.
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
  next_command: /ldd:design 123
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
  next_command: /ldd:plan 123
  next_human_action: null
events:
  - at: 2026-05-13T00:00:00Z
    type: sdd_approved
    actor: human
```

For plan approval, use existing ledger fields:

```yaml
artifacts:
  plan:
    status: approved
execution_context:
  phase: decompose
  current_gate: decompose
  next_command: /ldd:decompose 123
  next_human_action: null
events:
  - at: 2026-05-13T00:00:00Z
    type: plan_approved
    actor: human
```

Preserve existing unrelated ledger fields and events.

## Stop Conditions

- missing ticket ID
- missing or unreadable ledger
- missing PRD for PRD approval
- missing SDD for SDD approval
- missing plan for plan approval
- PRD is not approved before SDD approval
- SDD is not approved before plan approval
- no active PRD, SDD, or plan approval gate
- multiple active approval gates
- requested approval is for decomposition, verification, closure, or a non-approval external mutation
- external drift is detected
- GitHub tracker mode is configured but the Product Requirement issue cannot be created or bound
- GitHub tracker mode is configured for SDD approval but the SDD issue cannot be created or bound
