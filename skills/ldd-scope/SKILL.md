---
name: ldd-scope
description: Run /ldd:scope for an LDD ticket. Use when the user says /ldd:scope or wants to create or update PRD scope boundaries for a draft Product Requirement.
---

# /ldd:scope

Create or update `prd.md` in the active draft or promoted ticket directory.

## Owns

- Goals
- Non-goals
- Initial dependencies or constraints

## Rules

- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- External mutations require human confirmation.
- PM-hat command: preserve product intent and do not read the codebase as a design input.
- Use the PRD template as a quality contract. Fill only the sections owned by this command; leave later-stage sections blank or marked as not yet addressed.
- Do not fill implementation detail, acceptance criteria, success metrics, or user stories.
- If code facts appear during discussion, capture them only as constraints, dependencies, or open questions.
- Make a local commit after writing scope. Ask before pushing the branch.

## Stop Conditions

- ticket ledger not found
- product ambiguity blocks useful scope
- requested work belongs to `/ldd:elaborate`, `/ldd:refine`, or a technical design step
