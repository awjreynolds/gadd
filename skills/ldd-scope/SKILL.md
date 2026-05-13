---
name: ldd-scope
description: Run /ldd:scope for an LDD ticket. Use when the user says /ldd:scope or wants to create or update PRD scope boundaries for a draft Product Requirement.
---

# /ldd:scope

Create or update `prd.md` scope boundaries for a draft Product Requirement. If no draft is selected, create a new draft ticket directory.

## Input

`/ldd:scope [new|draft-id|ticket-id] [short title or context]`

## Owns

- Goals
- Non-goals
- Initial dependencies or constraints

## Facilitation Protocol

Start by stating the boundary: `/ldd:scope` defines product scope only. It does not fill problem detail, users, stories, acceptance criteria, metrics, software design, implementation plans, or verification behavior.

Support three entry modes when the user's intent is not already obvious:

- **Guided**: ask one scope question at a time.
- **Context dump**: use the supplied context, skip resolved questions, and ask only for missing scope decisions.
- **Best guess**: draft scope from available context, label assumptions, and keep uncertain points in dependencies or open questions.

Core scope questions:

1. What product change or outcome is being considered?
2. What goals are in scope?
3. What tempting work is explicitly out of scope?
4. What known constraints or dependencies affect scope?

## Bounded Shared Understanding Gate

Before writing scope or declaring scope ready, reach shared understanding of the product boundary.

State the boundary in this form:

> My understanding is that this PRD is about [in-scope outcomes], explicitly not [non-goals], with [constraints/dependencies]. Anything else belongs to a later LDD phase, a separate PRD, or out of scope. Is that boundary right?

Walk unresolved boundary branches one at a time. For each branch:

- Ask one direct question.
- Provide a recommended answer that preserves the narrowest useful product boundary.
- Classify the branch as in scope, out of scope, later phase, or separate PRD.
- Do not absorb user stories, acceptance criteria, metrics, design, implementation, or verification detail into `/ldd:scope`.

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
- recommended next command, usually `/ldd:elaborate`,
- required human decision, if any.

Use this decision language: "Scope ready. Continue to `/ldd:elaborate`, revise scope, or stop?"

## Rules

- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- External mutations require human confirmation.
- Product Manager command: preserve product intent and do not read the codebase as a design input.
- Existing promoted Product Requirement tickets do not block new scoping work. LDD may have multiple active promoted tickets at different phases.
- Keep at most one active local draft in `docs/tickets/_drafts/`.
- If no target is provided and exactly one active draft exists, update that draft.
- If no target is provided and no active draft exists, create a new draft under `docs/tickets/_drafts/YYYY-MM-DD-short-slug/` using `.ldd/templates/ledger.yml` and `.ldd/templates/prd.md` when present.
- If the user asks to start new scope and no active draft exists, create a draft under the configured draft directory even when other promoted tickets are incomplete.
- If the user asks to start new scope while an active draft already exists, stop and ask whether to continue, rename, promote, or discard the existing draft first.
- If multiple active drafts exist, stop and ask the human to reconcile them back to one active draft before continuing.
- Do not update a promoted ticket unless the user explicitly identifies that ticket. Promoted tickets are stable workflow records; new product ideas should normally start as new drafts.
- Use the PRD template as a quality contract. Fill only the sections owned by this command; leave later-stage sections blank or marked as not yet addressed.
- Do not fill implementation detail, acceptance criteria, success metrics, or user stories.
- If code facts appear during discussion, capture them only as constraints, dependencies, or open questions.
- Make a local commit after writing scope. Ask before pushing the branch.

## Stop Conditions

- product ambiguity blocks useful scope
- a new draft is requested while an active draft already exists
- multiple active drafts exist
- requested promoted ticket does not exist
- requested work belongs to `/ldd:elaborate`, `/ldd:refine`, or a technical design step
