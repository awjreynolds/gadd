---
name: ldd-scope
description: Run /ldd:scope for a GitHub issue. Use when the user says /ldd:scope or wants to create or update PRD scope boundaries for an LDD ticket.
---

# /ldd:scope

Create or update `docs/tickets/<issue>/prd.md` on `ldd/prd/<issue>`.

## Owns

- Goals
- Non-goals
- Initial dependencies or constraints

## Rules

- GitHub is the ledger. Do not create LDD labels, GitHub Actions, progress logs, or audit event files.
- GitHub mutations require human confirmation.
- PM-hat command: preserve product intent and do not read the codebase as a design input.
- Do not fill implementation detail, acceptance criteria, success metrics, or user stories.
- If code facts appear during discussion, capture them only as constraints, dependencies, or open questions.
- Make a local commit after writing scope. Ask before pushing the branch.

## Stop Conditions

- issue not found
- product ambiguity blocks useful scope
- requested work belongs to `/ldd:elaborate`, `/ldd:refine`, or a technical design step
