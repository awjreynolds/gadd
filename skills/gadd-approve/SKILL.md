---
name: gadd-approve
description: Run /gadd:approve for a GADD Work Item. Use when the user says /gadd:approve or wants to approve a PRD, SDD, or plan from repo-local ledger state.
---

# /gadd:approve

Approve exactly one PRD, SDD, or plan gate for a GADD Work Item.

This command is a standalone, agent-agnostic GADD command. Follow this file directly; do not require any other installed skill.

Scope this command to PRD, SDD, and plan approval only. It does not approve decomposition, closure, PR merges, external mutations, or broad workflow automation.

## Input

```text
/gadd:approve <work-item-id>
```

If no Work Item ID is provided, stop and ask for the target Work Item ID. Do not infer approval from unrelated modified files or conversational shorthand.

## Reads

- target Work Item `ledger.yml`
- target PRD frontmatter and body
- target SDD frontmatter and body when present
- target plan frontmatter and body when present
- `gadd/config.yml` when present
- external tracker sync metadata when configured

Read the ledger first. Use the ledger to locate the PRD, SDD, and plan paths, artifact statuses, current gate, approved artifact boundaries, and next action.

## Writes

- PRD frontmatter/status when approving the PRD
- SDD frontmatter/status when approving the SDD
- plan frontmatter/status when approving the plan
- target Work Item `ledger.yml`
- compact ledger events
- GitHub Product Requirement issue when approving a PRD in GitHub tracker mode
- GitHub SDD issue when approving an SDD in GitHub tracker mode

Do not write child Work Items, verification reports, archive locations, or unrelated repository files from this command.

## Input Quality Gate

Required input standard before approval:

- exactly one active PRD, SDD, or plan approval gate
- the artifact for that gate exists and passes its checklist
- all prerequisite artifacts for that gate are approved
- external tracker state is reachable and not drifted when GitHub projection is configured
- for SDD approval, the SDD includes a non-placeholder structure summary in `## Structure` that matches the detailed design

If inputs fail this standard, do not approve and do not mutate local or external state. Name the blocking gate or artifact gap. The earliest GADD command that can repair the gap is the owning phase command: `/gadd:refine` for PRD approval, `/gadd:design` for SDD approval, `/gadd:plan` for plan approval, or human external-drift reconciliation when tracker state changed.

## Rules

- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- External mutations require human confirmation.
- Approve only when exactly one approval gate is active.
- PRD approval is allowed only for a draft PRD gate.
- SDD approval is allowed when either the Work Item type is `product_requirement` and the PRD is approved, or the Work Item type is `engineering_change` and `triage.approved_outcome.status: approved` plus `triage.approved_outcome.approved_hash` are recorded in the ledger.
- Do not require an approved PRD for `engineering_change` SDD approval; allow this path without requiring an approved PRD. Do require the SDD `## Structure` quality gate in both paths.
- Plan approval is allowed when the Work Item type is `product_requirement` and the PRD and SDD are already approved, or when the Work Item type is `engineering_change` and the approved SDD is already approved.
- `/gadd:approve` does not approve decomposition review, closure, verification overrides, external close, PR creation, PR update, or PR merge.
- Preserve approved boundaries. If approval would change product scope, design, or plan content, stop and route to `/gadd:scope`, `/gadd:elaborate`, `/gadd:refine`, `/gadd:design`, or `/gadd:plan`.
- In local tracker mode, approval mutates only repo-local artifacts and ledger state.
- In GitHub tracker mode, PRD approval creates or binds the GitHub Product Requirement issue before local promotion. The explicit `/gadd:approve <draft-id>` invocation is the human confirmation to create or bind that Product Requirement issue. Other GitHub mutations still require their owning command and explicit confirmation.
- If external drift is detected, stop before mutation and ask the human to reconcile the external contribution.
- Commit locally after approval when you changed files.

## Gate Detection

Determine candidate gates from ledger state:

- PRD candidate:
  - `execution_context.phase` is `refine` and `execution_context.current_gate: prd_approval`, or
  - `execution_context.current_gate: prd_approval` and `execution_context.next_command` is `/gadd:approve <work-item-id>`.
- SDD candidate:
  - `execution_context.current_gate: design_review`, or
  - `artifacts.sdd.status: draft` and `artifacts.prd.status: approved`, or
  - `work_item.type: engineering_change`, `artifacts.sdd.status: draft`, and `triage.approved_outcome.status: approved` plus `triage.approved_outcome.approved_hash` are recorded.
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
- the PRD is not approved before SDD approval for a `product_requirement`
- `triage.approved_outcome.status: approved`, `triage.approved_outcome.approved_hash`, or a concrete `triage.approved_outcome.boundary_source` is missing before SDD approval for an `engineering_change`
- the SDD is not approved before plan approval
- the current gate is decomposition review, implementation, verification, closure, or external mutation confirmation

When blocked, report the gate candidates and the next command that owns the state.

## PRD Approval Workflow

1. Confirm the PRD exists and passes the Product Manager handoff checklist.
2. If tracker mode is GitHub and the Work Item is still in a draft directory:
   - Create or bind the GitHub Product Requirement issue before changing the local PRD.
   - Build the issue from the current draft `prd.md` content and `gadd/templates/issue-body-prd.md`.
   - Use the returned GitHub issue number as the stable Work Item ID.
   - Move the draft directory to `gadd/work-items/<issue-number>-<short-slug>/`.
   - Set `work_item.id` and `tracker.external_id` to the issue number, and `tracker.external_url` to the issue URL.
   - Do not invent or preserve an `GADD-0004` style ID in GitHub tracker mode.
3. If tracker mode is local and the Work Item is still in a draft directory, assign the next local ID according to the configured local ledger convention.
4. Mark PRD frontmatter `work_item` to the stable Work Item ID, set `status: approved`, and update `updated`.
5. Update ledger:
   - `work_item.state: approved`
   - `artifacts.prd.status: approved`
   - `execution_context.phase: design`
   - `execution_context.current_gate: design`
   - `execution_context.next_command: /gadd:design <work-item-id>`
   - `execution_context.next_human_action: null`
   - `execution_context.next_reason: PRD is approved and ready for engineering design.`
   - `execution_context.approved_artifacts.prd` to the PRD path
   - `execution_context.boundaries.product` to the PRD path
6. Append a `prd_approved` event with `actor: human`.
7. Report the next command: `/gadd:design <work-item-id>`.

## SDD Approval Workflow

1. Confirm the SDD approval boundary in the ledger:
   - for `product_requirement`, the PRD is approved.
   - for `engineering_change`, `triage.approved_outcome.status: approved`, `triage.approved_outcome.approved_hash`, and a concrete `triage.approved_outcome.boundary_source` are recorded.
2. Confirm the SDD exists and passes the SDD review checklist.
3. Confirm `## Structure` is present, non-placeholder, and synchronized with the detailed design. Treat missing or stale `## Structure` as approval-blocking for SDD approval. Block approval when the structure summary contradicts the detailed design, omits a material component, boundary, interface, or explicit non-change described later in the SDD, or only restates product scope.
4. In GitHub tracker mode, create or bind the GitHub SDD issue before marking the SDD approved:
   - Build the issue from the current SDD content and `gadd/templates/issue-body-sdd.md`.
   - For `product_requirement`, title the SDD issue `PRD #<prd_issue_number> SDD: <short title>` and reference the approved parent PRD issue number and URL in the SDD issue body.
   - For `engineering_change`, title the SDD issue `Engineering Change SDD: <short title>` and reference the approved triage outcome projection instead of a parent PRD issue.
   - Record the SDD issue number and URL under `artifacts.sdd.external_id` and `artifacts.sdd.external_url`.
   - Treat this SDD issue as the GitHub SDD Work Item projection.
5. Mark SDD frontmatter `status: approved` and update `updated`.
6. Update ledger:
   - `work_item.state: designed`
   - `artifacts.sdd.status: approved`
   - For `product_requirement`, or for `engineering_change` with `artifacts.sdd.implementation_route: plan_required`, set `execution_context.phase: plan`, `execution_context.current_gate: plan`, and `execution_context.next_command: /gadd:plan <work-item-id>`.
   - For `engineering_change` with `artifacts.sdd.implementation_route: single`, set `execution_context.phase: implement`, `execution_context.current_gate: implementation`, and `execution_context.next_command: /gadd:implement <work-item-id>`.
   - `execution_context.next_human_action: null`
   - `execution_context.next_reason: Software Design Document is approved and ready for implementation planning.` when routing to `/gadd:plan`.
   - `execution_context.next_reason: Software Design Document is approved for single-route implementation.` when routing directly to `/gadd:implement`.
   - `execution_context.approved_artifacts.sdd` to the SDD path
   - `execution_context.boundaries.design` to the SDD path
7. Append an `sdd_approved` event with `actor: human`.
8. Report the next command: `/gadd:plan <work-item-id>` or `/gadd:implement <work-item-id>` according to the approved SDD implementation route.

## Plan Approval Workflow

1. Confirm the required plan boundary is approved in the ledger: PRD and SDD for `product_requirement`, or approved triage outcome and SDD for `engineering_change`.
2. Confirm the plan exists and passes the plan review checklist.
3. Mark plan frontmatter `status: approved` and update `updated`.
4. Update ledger:
   - `artifacts.plan.status: approved`
   - `execution_context.phase: decompose`
   - `execution_context.current_gate: decompose`
   - `execution_context.next_command: /gadd:decompose <work-item-id>`
   - `execution_context.next_human_action: null`
   - `execution_context.next_reason: Implementation plan is approved and ready for decomposition preview.`
   - `execution_context.approved_artifacts.plan` to the plan path
   - `execution_context.boundaries.plan` to the plan path
5. Append a `plan_approved` event with `actor: human`.
6. Report the next command: `/gadd:decompose <work-item-id>`.

## GitHub Projection Rule

GitHub is the first external tracker dogfooding path, but it is still a projection:

- GitHub issues represent PRD and child Work Item visibility.
- GitHub issues represent SDD review visibility as an SDD Work Item projection.
- GitHub PRs represent implementation review.
- The local ledger remains canonical for phase state, approvals, and closure.
- PRD approval in GitHub tracker mode creates or binds the Product Requirement issue and uses the GitHub issue number as the promoted Work Item ID.
- SDD approval in GitHub tracker mode creates or binds an SDD issue. For `product_requirement`, it references the PRD issue in both the issue title and body and the title must start with `PRD #<prd_issue_number> SDD:`. For `engineering_change`, it references the approved triage outcome projection and must not require a parent PRD issue. Decomposition-created implementation issues must be attached as native sub-issues of the SDD issue when supported, so the PRD issue has grandchildren only for PRD-backed work.
- Plan approval is repo-local gate approval. It does not create GitHub child issues; `/gadd:decompose` owns child issue preview and creation after its own explicit human confirmation.
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
  next_command: /gadd:design 123
  next_human_action: null
events:
  - at: <iso8601-timestamp>
    type: prd_approved
    actor: human
```

For SDD approval that routes to implementation planning, use existing ledger fields:

```yaml
artifacts:
  sdd:
    status: approved
execution_context:
  phase: plan
  current_gate: plan
  next_command: /gadd:plan 123
  next_human_action: null
events:
  - at: <iso8601-timestamp>
    type: sdd_approved
    actor: human
```

For small `engineering_change` SDD approval that explicitly chooses a single implementation route, use:

```yaml
work_item:
  type: engineering_change
  state: designed
triage:
  approved_outcome:
    status: approved
    boundary_source: external_projection
    approved_hash: abc123
artifacts:
  sdd:
    status: approved
    implementation_route: single
execution_context:
  phase: implement
  current_gate: implementation
  next_command: /gadd:implement 123
  next_human_action: null
events:
  - at: <iso8601-timestamp>
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
  next_command: /gadd:decompose 123
  next_human_action: null
events:
  - at: <iso8601-timestamp>
    type: plan_approved
    actor: human
```

Preserve existing unrelated ledger fields and events.

## Stop Conditions

- missing Work Item ID
- missing or unreadable ledger
- missing PRD for PRD approval
- missing SDD for SDD approval
- missing plan for plan approval
- PRD is not approved before SDD approval for a `product_requirement`
- `triage.approved_outcome` approval state, approved hash, or boundary source is missing before SDD approval for an `engineering_change`
- SDD is not approved before plan approval
- no active PRD, SDD, or plan approval gate
- multiple active approval gates
- requested approval is for decomposition, verification, closure, or a non-approval external mutation
- external drift is detected
- GitHub tracker mode is configured but the Product Requirement issue cannot be created or bound
- GitHub tracker mode is configured for SDD approval but the SDD issue cannot be created or bound
