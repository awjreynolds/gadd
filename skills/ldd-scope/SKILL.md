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
