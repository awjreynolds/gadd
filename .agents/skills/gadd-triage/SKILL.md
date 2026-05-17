---
name: gadd-triage
description: Run /gadd:triage for unclassified GADD intake. Use when the user says /gadd:triage, provides a free-form work prompt or external issue, reports a bug, asks what to do with an issue, or wants to route a task, bug, engineering change, or ambiguous request into GADD.
---

# /gadd:triage

Normalize unclassified intake into a GADD Work Item and route it to implementation, SDD-only design, PRD discovery, or a terminal state.

This command is a standalone, agent-agnostic GADD command. Follow this file directly; do not require brainstorming, grill-me, issue-generation, or external triage skills.

## Inputs

```text
/gadd:triage [new|work-item-id|external-ref] [context]
/gadd:triage <free-form intake prompt>
```

Use `/gadd:triage` for unclassified incoming work: external issues, bug reports, engineer tasks, support reports, ambiguous requests, and "what should we do with this?" items. It also accepts a plain-language prompt as the source intake, for example `/gadd:triage create a new release of this package`. Treat that prompt as incoming work to normalize, not as a subcommand. Do not require triage before deliberate PM-led Product Requirement discovery; `/gadd:research` and `/gadd:scope` remain valid direct entry points.

When both a Work Item ID and a free-form prompt are supplied (`/gadd:triage <work-item-id> <prompt>`), treat the free-form prompt as additional triage context for the existing Work Item. Do not replace the existing triage narrative or approved outcome without explicit human confirmation.

## Reads

- `gadd/config.yml` when present
- active Work Item ledgers under the configured Work Item root
- external issue body, comments, labels, timestamps, and reporter metadata when an external reference is supplied and the tracker is configured
- repository files, docs, tests, ADRs, and existing GADD artifacts
- GitNexus code-intelligence context when code reality matters

## Writes

- a Work Item `ledger.yml`
- local-only `triage.md` only when no external tracker is configured for the Work Item
- compact ledger events for triage route decisions and external projection metadata
- external issue body/comment/labels/close only after human-in-the-loop approval and drift checks

## Work Item Types

- `bug_fix`: broken behavior against a clear expectation.
- `task`: bounded work where the desired outcome is clear and blast radius is low enough for implementation from the approved triage outcome.
- `engineering_change`: product intent is settled, but SDD is needed because architecture, contracts, data model, security/privacy behavior, cross-repo impact, or blast radius is meaningful.
- `product_requirement`: PRD path is required because product outcome, users, acceptance criteria, non-goals, or scope needs product agreement.
- `external_issue_intake`: temporary type while poor-quality external input is being normalized.
- `not_gadd_work`: duplicate, out of scope, unsupported, or not actionable through GADD.

## Triage States

Set exactly one state:

- `needs_info`
- `ready_for_implementation`
- `needs_sdd`
- `needs_prd`
- `blocked_on_human_decision`
- `duplicate`
- `out_of_scope`
- `not_gadd_work`

## Input Quality Gate

Required input standard before routing:

- source intake exists: user request, external issue, bug report, task description, support signal, or comparable context
- enough context exists to identify the affected behavior, desired outcome, or missing information
- external issue state has been freshly read when an external reference is supplied
- external drift has been checked before any external mutation
- GitNexus evidence is available and fresh enough before routing `bug_fix`, `task`, or `engineering_change` to `ready_for_implementation` or `needs_sdd`, unless the human explicitly approves manual fallback
- manual fallback records lower confidence and must not silently claim low blast radius

If the input quality gate fails, write only safe local state when useful and set `state: needs_info` or `blocked_on_human_decision`. Ask one focused question or recommend the earliest GADD command or repairing action.

## Rules

- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- External mutations require human confirmation.
- External issues and tickets are tracker-native collaboration surfaces, not GADD workflow state.
- Do not route code-impacting Work Items without GitNexus evidence or recorded human-approved fallback, because triage routing depends on blast-radius evidence; downstream commands treat GitNexus as advisory.
- Do not treat a poor-quality external issue as implementation-ready until the Triage Quality Loop has repaired the missing problem statement, evidence, done criteria, or route decision.

## Triage Quality Loop

Run a bounded quality loop:

1. Read the incoming request, external issue, comments, labels, and existing GADD state.
2. Create or bind a local Work Item early.
3. For bugs, attempt reproduction or identify the exact missing repro evidence.
4. Use GitNexus where code reality matters.
5. Draft or update the triage narrative and route decision.
6. Identify only gaps that block routing or implementation quality.
7. Ask focused questions one at a time, or propose a cleaned-up external issue rewrite.
8. Stop when the Work Item can route to implementation, SDD, PRD discovery, or a terminal state.

Do not visibly switch the user into brainstorming, grill-me, or another skill. The quality loop belongs to `/gadd:triage`.

## Routing Rules

- `ready_for_implementation` routes to `/gadd:implement <work-item-id>`.
- `needs_sdd` routes to `/gadd:design <work-item-id>`.
- `needs_prd` routes to `/gadd:research <work-item-id>` or `/gadd:scope <work-item-id>`.
- `needs_info` remains in `/gadd:triage <work-item-id>`.
- `duplicate` is terminal: record the duplicated Work Item reference, set no downstream command, and project externally only after human approval and drift checks.
- `out_of_scope` is terminal: record the scope reason, set no downstream command, and project externally only after human approval and drift checks.
- `not_gadd_work` is terminal: record why the request is not GADD-governed, set no downstream command, and project externally only after human approval and drift checks.
- `blocked_on_human_decision` is terminal until the human decides: record the named human decision required, set no downstream command, and project externally only after human approval and drift checks.

On every triage completion, write `execution_context.next_command` and `execution_context.next_human_action` in the ledger per this route table:

| Triage state | `execution_context.next_command` | `execution_context.next_human_action` |
| --- | --- | --- |
| `ready_for_implementation` | `/gadd:implement <work-item-id>` | `null` |
| `needs_sdd` | `/gadd:design <work-item-id>` | `null` |
| `needs_prd` | `/gadd:research <work-item-id>` or `/gadd:scope <work-item-id>` (whichever the route picked) | `null` |
| `needs_info` | `/gadd:triage <work-item-id>` | answer the focused triage question |
| `duplicate` | `blocked` | reference the duplicated Work Item; close terminally after human approval (`next_reason: duplicate`) |
| `out_of_scope` | `blocked` | confirm the recorded scope reason (`next_reason: out_of_scope`) |
| `not_gadd_work` | `blocked` | confirm the request is not GADD-governed (`next_reason: not_gadd_work`) |
| `blocked_on_human_decision` | `blocked` | name the recorded human decision (`next_reason: blocked_on_human_decision`) |

Terminal states must name the terminal reason in `execution_context.next_reason` and must not invent a downstream `/gadd:*` command.

## Approved Triage Outcome

In external-tracker mode, the approved triage outcome is the projected external issue body/comment plus the local ledger route decision.

In local-only mode, the approved triage outcome is `triage.md` plus the local ledger route decision.

The durable GADD workflow state is the Work Item ledger. The human-facing triage narrative should live where the humans work: the external issue body or comments when an external tracker is configured.

Record the approved boundary explicitly in the ledger under `triage.approved_outcome`:

```yaml
triage:
  approved_outcome:
    status: approved
    boundary_source: external_projection | local_triage
    local_path: gadd/work-items/<work-item-id>/triage.md | null
    external_projection_url: <external comment-or-body-url> | null
    approved_at: <timestamp>
    approved_by: human
    approved_hash: <hash of the approved projected or local triage outcome>
    summary: <one-sentence route boundary>
```

Downstream commands must treat `triage.approved_outcome.status: approved` plus `approved_hash` and one concrete boundary source as the machine-readable proof that triage is approved. Do not rely on the external issue text alone, a conversational approval, or `work_item.state` by itself.

## External Projection

Before posting a comment, rewriting a body, applying labels, or closing an issue:

1. Re-read the external issue.
2. Compare `external_updated_at` and `body_hash` with the ledger.
3. Present the exact proposed body/comment/label/close action.
4. Ask for human approval.
5. Record the projected URL, timestamp, hash, and managed labels in the ledger after success.
6. When the projected body/comment is the approved route boundary, also update `triage.approved_outcome` with `status: approved`, `boundary_source: external_projection`, the projection URL, approval timestamp, approver, approved hash, and summary.

External comments should be normal engineering triage:

```markdown
## Triage Summary

What we have established:

- The command fails when the reporter passes an empty title.

What we still need:

- Please provide the exact command invocation and the expected title value.

Current GADD route:

- State: needs_info
- Likely route after clarification: needs_sdd | ready_for_implementation | needs_prd

---

GADD Traceability:
- Work Item: <work-item-id>
- Route: <route>
- Last synchronized: <timestamp>
```

Do not include raw private context, sensitive repo analysis, non-shareable GitNexus detail, or internal reasoning in external comments.

## Exit Gate

End with:

- Work Item ID
- type and state
- route and next command
- GitNexus evidence status or approved fallback status
- external projection status
- one copyable next command

## Stop Conditions

- no source intake exists
- external issue cannot be read when needed
- unresolved external drift would be overwritten
- GitNexus is missing, stale, or unindexed and the human has not approved fallback
- missing information prevents responsible route selection
- requested mutation lacks human approval
