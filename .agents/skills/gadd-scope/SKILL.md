---
name: gadd-scope
description: Run /gadd:scope for a GADD Product Requirement Work Item. Use when the user says /gadd:scope or wants to create or update PRD scope boundaries for a draft Product Requirement.
---

# /gadd:scope

Create or update `prd.md` scope boundaries for a draft Product Requirement. If no draft is selected, create a new draft Work Item directory.

This command is a standalone, agent-agnostic GADD command. Follow this file directly; do not require any other installed skill.

## Input

`/gadd:scope [new|draft-id|work-item-id] [short title or context]`

This is a Product Requirement lane command. It accepts direct PM-led product discovery or Work Items routed from triage with `state: needs_prd`. Reject `bug_fix`, `task`, and `engineering_change` Work Items with a clear route back to `/gadd:next <work-item-id>` or `/gadd:triage <work-item-id>`.

## Owns

- Goals
- Non-goals
- Initial dependencies or constraints

## Facilitation Protocol

Start by stating the boundary: `/gadd:scope` defines product scope only. It does not fill problem detail, users, stories, acceptance criteria, metrics, software design, implementation plans, or verification behavior.

Support three entry modes when the user's intent is not already obvious:

- **Guided**: ask one scope question at a time.
- **Context dump**: use the supplied context, skip resolved questions, and ask only for missing scope decisions.
- **Best effort from supplied context**: draft scope from available context, label explicit uncertainties, and keep uncertain points in dependencies or open questions.

Core scope questions:

1. What product change or outcome is being considered?
2. What goals are in scope?
3. What tempting work is explicitly out of scope?
4. What known constraints or dependencies affect scope?

## Input Quality Gate

Required input standard before writing or updating scope:

- a clear product problem or desired product outcome
- a target user, persona, stakeholder, or workflow affected by the problem
- enough evidence, current-workflow context, constraints, or research readiness to avoid inventing the boundary
- candidate non-goals or enough context to identify likely scope creep

If `artifacts.research.status` is present, proceed only when it is `ready_for_scope`. If research is `blocked_on_more_input`, `split_recommended`, or `not_a_product_requirement`, reject scope and report that readiness decision. If no research exists but the supplied context meets this standard, scope may proceed and record explicit uncertainties. If the standard is not met, write nothing and route to `/gadd:research` or ask one decisive missing-context question. The earliest GADD command that can repair weak source inputs is `/gadd:research`.

## Bounded Shared Understanding Gate

Before writing scope or declaring scope ready, reach shared understanding of the product boundary.

This is a bounded shared understanding gate, not an invitation to expand the feature. Use focused questioning to reach the same product boundary as the human, then stop. New ideas that do not preserve that boundary belong to a later GADD phase, a separate PRD, or out of scope.

State the boundary in this form:

> My understanding is that this PRD is about [in-scope outcomes], explicitly not [non-goals], with [constraints/dependencies]. Anything else belongs to a later GADD phase, a separate PRD, or out of scope. Is that boundary right?

Walk unresolved boundary branches one at a time. For each branch:

- Ask one direct question.
- Provide a recommended answer that preserves the narrowest useful product boundary.
- Classify the branch as in scope, out of scope, later phase, or separate PRD.
- Do not absorb user stories, acceptance criteria, metrics, design, implementation, or verification detail into `/gadd:scope`.

If the human gives enough context to answer a branch, answer it and record the decision. If the branch cannot be resolved from supplied context and affects goals, non-goals, or constraints, stop and ask.

When scope is blocked, ask one decisive question and include a recommended answer that preserves the narrower product boundary. If interrupted, answer the interruption, restate scope status, and resume the current question.

## Product Quality Bar

- Goals describe product outcomes, not implementation tasks.
- Non-goals block likely scope creep.
- Dependencies and constraints are product-relevant and do not become design decisions.
- Codebase facts, when supplied by the user, are captured only as constraints, dependencies, or open questions.
- Scope is not ready until the agent and human share the same boundary understanding, or unresolved boundary questions are explicitly recorded as blocking.
- Anti-patterns to reject: user stories, acceptance criteria, success metrics, architecture, schemas, file paths, command algorithms, test strategy, and broad "make it better" scope.

## Exit Gate

End with:

- artifact updated,
- expected ledger transition or event,
- blocking and non-blocking scope questions,
- recommended next command, usually `/gadd:elaborate`,
- required human decision, if any.

Use this decision language: "Scope ready. Continue to `/gadd:elaborate`, revise scope, or stop?"

After writing scope, set `execution_context.phase: scope`, `execution_context.current_gate: scope`, `execution_context.next_command: /gadd:elaborate`, and `execution_context.next_human_action: null` when those fields are available. Do not set `current_gate: prd_approval`; PRD approval is owned by `/gadd:refine`.

## Rules

- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- External mutations require human confirmation.
- Product Manager command: preserve product intent and do not read the codebase as a design input.
- If scope changes the product meaning of an approved PRD, keep the stable Work Item ID but mark the PRD artifact as draft, clear `approved_artifacts.prd`, route `execution_context` back to the owning PM command, record an approval-invalidated event, and require `/gadd:refine` plus human approval before `/gadd:design`.
- Existing promoted Product Requirement Work Items do not block new scoping work. GADD may have multiple active promoted Work Items at different phases.
- Keep at most one active local draft in `gadd/work-items/_drafts/`.
- If no target is provided and exactly one active draft exists, update that draft.
- If no target is provided and no active draft exists, create a new draft under `gadd/work-items/_drafts/YYYY-MM-DD-short-slug/` using `gadd/templates/work-item-ledger.yml` and `gadd/templates/prd.md` when present.
- If the user asks to start new scope and no active draft exists, create a draft under the configured draft directory even when other promoted Work Items are incomplete.
- If the user asks to start new scope while an active draft already exists, stop and ask whether to continue, rename, promote, or discard the existing draft first.
- If multiple active drafts exist, stop and ask the human to reconcile them back to one active draft before continuing.
- Do not update a promoted Work Item unless the user explicitly identifies that Work Item. Promoted Work Items are stable workflow records; new product ideas should normally start as new drafts.
- Promotion is owned by `/gadd:refine` and `/gadd:approve`; do not promote here.
- Use the PRD template as a quality contract. Fill only the sections owned by this command; leave later-stage sections blank or marked as not yet addressed.
- Do not fill implementation detail, acceptance criteria, success metrics, or user stories.
- If code facts appear during discussion, capture them only as constraints, dependencies, or open questions.
- Make a local commit after writing scope. Ask before pushing the branch.

## Stop Conditions

- product ambiguity blocks useful scope
- a new draft is requested while an active draft already exists
- multiple active drafts exist
- requested promoted Work Item does not exist
- requested work belongs to `/gadd:elaborate`, `/gadd:refine`, or a technical design step
