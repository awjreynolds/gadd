---
name: gadd-decompose
description: Run /gadd:decompose after an approved GADD plan to split it into reviewable child Work Items. Use when the user says /gadd:decompose, asks to split a plan into slices, wants vertical slices created as child Work Items, asks to turn a plan into reviewable slices, or says things like "decompose this plan", "create the child Work Items", "slice the plan for implementation", or "make sub-issues from the plan". This is the post-approval Technical Design step that hands off to /gadd:implement <work-item-id> or /gadd:implement ALL; it does not implement code and does not approve the plan itself.
---

# /gadd:decompose

Turn an approved `plan.md` into child vertical-slice Work Items.

This command is a standalone, agent-agnostic GADD command. Follow this file directly; do not require any other installed skill.

## Input

```text
/gadd:decompose <work-item-id>
```

If no Work Item ID is provided, stop and ask for the target parent Work Item ID.

## Reads

- parent `ledger.yml`
- approved PRD or approved triage outcome
- approved SDD
- approved `plan.md`

## Produces

- child Work Item entries in the parent ledger
- child Work Item ledgers under the parent Work Item directory
- external child work items only when a tracker is configured and the human approves

## Input Quality Gate

Required input standard before previewing or creating child Work Items:

- approved PRD, approved SDD, and approved plan in the parent ledger for `product_requirement`
- approved triage outcome, approved SDD, and approved plan in the parent ledger for `engineering_change`
- plan slices are traceable to acceptance criteria and dependency-safe
- in GitHub tracker mode, the SDD issue is approved or bound and has a known issue number
- enough slice detail for independently grabbable child Work Items
- each proposed slice has a review-load estimate that is reasonable for one human review

If inputs fail this standard, write nothing and name the blocking gap. The earliest GADD command that can repair missing slices is `/gadd:plan`; missing approval routes to `/gadd:approve <work-item-id>`; missing SDD issue linkage routes to `/gadd:approve <work-item-id>` for SDD approval or tracker reconciliation.

## Preview Before Creation

Before creating or updating any child Work Item, present the proposed Work Item set and stop for human approval. This approval is not handled by `/gadd:approve`; it is a decomposition review decision.

Use this review shape:

```text
Proposed child Work Items:

1. SDD #<sdd-issue-number> Slice <slice-number>: <short outcome title>
   Type: Autonomous | Human-review
   Blocked by: None | <Work Item title/id>
   User stories covered: <PRD story numbers>
   Documentation impact: Updated | Not needed: <reason> | Blocked: <question>
   Review load: Low | Medium | High, with expected file groups and risk
   Summary: <one or two sentences>

Ask:
- Does the granularity feel right?
- Are dependency relationships correct?
- Are Autonomous/Human-review classifications correct?
- Is the review load small enough for a focused PR?
- Is documentation impact explicit for every child Work Item?
- Should any Work Items be merged or split?
```

Only after approval may the command create child ledgers or external child Work Items. When stopping before approval, set `execution_context.next_human_action` to "approve proposed child Work Item set" so `/gadd:next` can surface the same blocking decision.

After the proposed child Work Item set is approved and all child ledgers (and any external child issues) are created, update the parent ledger `execution_context`:

- set `execution_context.next_command: /gadd:implement <work-item-id>` for the first ready child Work Item, or `/gadd:implement ALL` when the team prefers batched implementation across every ready child
- set `execution_context.next_human_action: null` because the next step is an agent action

If creation cannot complete (for example external sub-issue attachment fails or the human rejects part of the set), leave `next_command` pointing at the unfinished step and set `next_human_action` to the named reconciliation.

## Rules

- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- External mutations require human confirmation.
- Decompose only from an approved plan. Do not invent scope or architecture.
- Child Work Items are vertical slices derived from plan slices, not layer tasks.
- For `engineering_change`, `/gadd:decompose` creates child Work Items under the SDD/design Work Item projection rather than under a PRD issue.
- Decompose for human reviewability, not just execution convenience. A reviewer should be able to understand one child Work Item and its likely PR without loading the entire project into working memory.
- Apply a cognitive-load budget before creating children. Estimate expected file groups, likely files touched, test surface, risk, and dependency coupling for each slice.
- Do not knowingly create a child Work Item or aggregate implementation path that would produce a huge PR, especially anything expected to approach or exceed 200 changed files. Split by user-visible outcome, workflow path, command surface, or risk boundary before Work Item creation.
- Prefer several coherent vertical slices over one overloaded slice when the same reviewer would otherwise need to review unrelated command surfaces, templates, docs, and tracker behavior in one PR.
- If a slice cannot be made reviewable without breaking atomic behavior, mark it `Human-review`, call out the overload risk in the preview, and require explicit human approval before creating the child Work Item.
- In GitHub tracker mode, each child issue title must start with `SDD #<sdd_issue_number> Slice <slice-number>:` followed by a concise outcome title. This keeps issue lists readable and makes each implementation slice visibly traceable to its SDD parent without opening the issue body.
- In local-only tracker mode, use the equivalent approved SDD identifier in the child title, for example `SDD <work-item-id> Slice <slice-number>: <short outcome title>`.
- Each child Work Item must be independently grabbable: an implementation agent can read the Work Item, follow links as needed, and understand what end-to-end behavior to build, what acceptance criteria must pass, what it is blocked by, and which user stories, PRD criteria, or approved triage outcome criteria it covers.
- Each child Work Item must reference the parent Product Requirement or engineering_change design Work Item and approved plan slice.
- Each child Work Item must include documentation impact: documentation to update, not needed with reason, or a blocked documentation question.
- In GitHub tracker mode, each child work item must be created as a native GitHub sub-issue of the approved SDD issue. Body traceability to the SDD issue is required, but body links alone are not enough when GitHub sub-issues are available.
- To create the GitHub relationship, create the child issue first, capture its numeric REST `id`, then call GitHub's sub-issues endpoint on the SDD issue: `POST /repos/{owner}/{repo}/issues/{sdd_issue_number}/sub_issues` with `sub_issue_id`. Verify the relationship with the parent/sub-issues REST endpoints before recording the child as externally synced. This is the current GitHub REST sub-issues endpoint as of 2026 and may change; verify the path and request shape against the latest GitHub REST API documentation before relying on it.
- In GitHub tracker mode, native sub-issues make implementation child Work Items children of the SDD issue. They are grandchildren of a PRD issue only for `product_requirement` work.
- External child Work Item bodies use GADD's standalone child issue shape: Parent, What to build, Acceptance criteria, Blocked by, User stories covered, plus minimal GADD Traceability.
- In GitHub tracker mode, child Work Items may be projected as GitHub issues after explicit human confirmation. Each projected child issue must record its parent boundary source, SDD issue reference, plan slice, native parent/sub-issue relationship status, and local ledger path. For `product_requirement`, the parent boundary source includes the PRD issue reference; for `engineering_change`, it includes the approved triage outcome projection. The child ledger remains canonical.
- If GitHub sub-issue attachment fails because the feature, permissions, repository settings, or API are unavailable, stop and report the failure. Do not silently fall back to body-only linked issues. A body-only linked issue fallback requires a separate explicit human confirmation after the failure is reported.
- Linear and Jira child Work Item projections are follow-on optional collaboration surfaces, but the portable GADD contract is the same: create tracker-native child/sub-items where the tracker supports them, and record body traceability as backup.
- Before updating an existing external child Work Item, re-read it. If its body changed since the last recorded sync hash or timestamp, stop and ask the human to reconcile the external contribution.
- Keep the MVP lightweight: do not create a separate decomposition artifact unless the user explicitly asks.

## Stop Conditions

- parent ledger missing
- plan is missing or not approved
- plan slices are too vague to turn into independently grabbable vertical slices
- proposed slices are too large for focused human review and need to be split
- external tracker is configured but cannot be reached
- human rejects the proposed child Work Item set
