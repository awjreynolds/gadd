---
name: gadd-refine
description: Run /gadd:refine for a GADD Product Requirement Work Item. Use when the user says /gadd:refine or wants to sharpen a GADD PRD for engineering handoff and review.
---

# /gadd:refine

Polish `prd.md` in the active draft or promoted Work Item directory for the Product-to-engineering handoff, then use human approval as the gate that turns the draft into a real Product Requirement Work Item.

This command is a standalone, agent-agnostic GADD command. Follow this file directly; do not require any other installed skill.

This is a Product Requirement lane command. It accepts direct PM-led product discovery or Work Items routed from triage with `state: needs_prd`. Reject `bug_fix`, `task`, and `engineering_change` Work Items with a clear route back to `/gadd:next <work-item-id>` or `/gadd:triage <work-item-id>`.

## Input

```text
/gadd:refine <work-item-id>
```

If no Work Item ID is provided, target the single active draft Work Item directory. If neither a Work Item ID nor an active draft exists, stop and route to `/gadd:scope` or `/gadd:elaborate`. Do not infer a target from unrelated modified files.

## Owns

- Testable acceptance criteria
- Measurable success metrics
- Resolved or explicitly owned open questions
- Clear dependencies
- Removal of vague or solution-smuggling language

## Facilitation Protocol

Start by stating the boundary: `/gadd:refine` sharpens the Product-to-engineering handoff. It does not add product scope or technical design.

Support three entry modes when the user's intent is not already obvious:

- **Guided**: ask one handoff-quality question at a time.
- **Context dump**: use supplied context, skip resolved questions, and ask only for missing handoff decisions.
- **Best effort from supplied context**: refine from available context, label explicit uncertainties, and keep uncertain points owned or explicitly non-blocking.

Core refinement questions:

1. Does every goal have acceptance coverage?
2. Does every user story have observable acceptance criteria?
3. Are success metrics measurable enough to judge release success?
4. Are dependencies clear and owned?
5. Are open questions resolved, owned, or explicitly non-blocking?
6. Does any language prescribe design or implementation mechanics?

## Input Quality Gate

Required input standard before writing refinement:

- an elaborated PRD with goals, non-goals, users/personas, user stories, acceptance criteria, metrics, dependencies, and open questions
- observable acceptance coverage for every user story or an explicit blocker
- open questions that are resolved, owned, or explicitly non-blocking
- no changed product boundary that belongs back in scope

If inputs fail this standard, write nothing or only record the blocking reason when already editing the PRD. The earliest GADD command that can repair missing handoff detail is `/gadd:elaborate`; changed scope routes to `/gadd:scope`; missing source context routes to `/gadd:research`.

## Bounded Shared Understanding Gate

Before committing refinement or asking for PRD approval, prove shared understanding of the handoff.

This is a bounded shared understanding gate, not a broad challenge session. Use it to confirm that goals, non-goals, acceptance criteria, metrics, and dependencies line up; route new product scope back to `/gadd:scope` instead of folding it into refinement.

State the handoff understanding in this form:

> My understanding is that engineering design should solve [approved product outcomes], must not solve [non-goals], and will judge success by [acceptance/metrics]. The remaining questions are [resolved/owned/non-blocking]. Is this ready for engineering design?

Build an explicit coverage check before approval:

- For each goal, identify the covering user story, acceptance criteria, metric, and dependency or owner.
- For each acceptance criterion, confirm it is observable without prescribing design, implementation sequence, schemas, file placement, algorithms, or tests.
- If a goal is a discovery outcome, the acceptance criteria must name the concrete deliverable a maintainer will receive, not merely say the gap will be identified later.
- If coverage depends on human product knowledge, ask one direct question with a recommended answer.
- If refinement reveals missing product detail, route back to `/gadd:elaborate`.
- If refinement reveals changed goals or non-goals, route back to `/gadd:scope`.

Do not approve a PRD whose goals are covered only by circular statements, such as "identify the gaps" paired only with "a maintainer can identify the gaps." Require the artifact to specify the kind of gap inventory, decision, or observable output the user will receive.

When refinement is blocked, ask one decisive handoff question and include a recommended product-facing answer. If interrupted, answer the interruption, restate refinement status, and resume the current question.

## Product Quality Bar

- Every goal has acceptance coverage or an explicit reason it does not.
- Every user story is covered by acceptance criteria.
- Acceptance criteria are observable without prescribing design, implementation sequence, schemas, file placement, algorithms, or tests.
- Success metrics include a target, direction, threshold, or measurement owner.
- Dependencies name owner or status where possible.
- Open questions are resolved, owned, or explicitly non-blocking.
- The PRD has passed the bounded shared-understanding gate for engineering handoff.
- Anti-patterns to reject: vague acceptance criteria, unmeasurable metrics, ownerless open questions, solution-smuggling, and new product scope.

## Exit Gate

End with:

- artifact updated,
- expected ledger transition or event,
- remaining non-blocking questions,
- approval prompt using `/gadd:approve <work-item-id>`,
- recommended next command after approval, usually `/gadd:design`.

Use this reviewer prompt exactly: "Is this ready for engineering design? If yes, run `/gadd:approve <work-item-id>`."

## Rules

- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- External mutations require human confirmation.
- Product Manager command: do not read the codebase as a design input.
- If refinement changes the product meaning of an approved PRD, keep the stable Work Item ID but mark the PRD artifact as draft, clear `approved_artifacts.prd`, keep or route `execution_context` to the PRD approval gate, record an approval-invalidated event, and require fresh human approval before `/gadd:design`.
- Use the PRD template's quality bar and handoff checklist before proposing a PRD PR.
- Do not expand scope or add technical design.
- Preserve the Product Manager boundary: acceptance criteria describe required product/workflow outcomes, not the engineering solution that will satisfy them.
- Commit locally after refinement.
- End refinement with an explicit approval prompt: `Run /gadd:approve <work-item-id> to approve this PRD. In GitHub tracker mode, approval creates or binds the Product Requirement issue and uses the GitHub issue number as the promoted Work Item ID.`
- If the human has already approved the refined PRD in the current turn, do not stop at a refined draft. Promote it immediately.
- Promotion assigns the stable Work Item ID, moves the draft directory out of `_drafts`, updates `ledger.yml` and PRD frontmatter links/IDs, marks the PRD approved, and commits the promotion.
- In `local` tracker mode, the promoted repo-local ledger directory is the real Product Requirement Work Item.
- In GitHub tracker mode, promotion creates or binds the GitHub Product Requirement issue before approving the local PRD. The GitHub issue number is the stable Work Item ID and the promoted directory name uses that number, not a local `GADD-0004` style ID.
- Linear and Jira are follow-on optional collaboration surfaces; do not invent Linear or Jira mutation behavior in this command.
- External Product Requirement issues must be readable without opening the repo. Use `gadd/templates/issue-body-prd.md` and include the PRD problem, goals, non-goals, users, user stories, acceptance criteria, success metrics, dependencies, open questions, and GADD links.
- Before updating an existing External Issue, re-read it. If its body changed since the last recorded sync hash or timestamp, stop and ask the human to reconcile the external contribution.
- Before approval, set `execution_context.current_gate: prd_approval`, `execution_context.next_command: /gadd:approve <work-item-id>`, and `execution_context.next_human_action: /gadd:approve <work-item-id>` when those fields are available.
- GitHub PR body reviewer prompt for the PRD PR: "Does this PRD describe the right product outcome for engineering design? If yes, run `/gadd:approve <work-item-id>`."

## Stop Conditions

- missing elaborated PRD
- acceptance criteria cannot be made testable
- open questions lack owner or resolution
- refinement reveals a scope problem, which returns to `/gadd:scope`
