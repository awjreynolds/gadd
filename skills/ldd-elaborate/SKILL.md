---
name: ldd-elaborate
description: Run /ldd:elaborate for a GitHub issue. Use when the user says /ldd:elaborate or wants to fill product detail inside existing LDD PRD scope.
---

# /ldd:elaborate

Update `docs/tickets/<issue>/prd.md` on `ldd/prd/<issue>` with product detail inside existing scope.

## Owns

- Problem
- Users / Personas
- User Stories
- Draft Acceptance Criteria
- Draft Success Metrics
- Open Questions

## Rules

- GitHub is the ledger. Do not create LDD labels, GitHub Actions, progress logs, or audit event files.
- GitHub mutations require human confirmation.
- PM-hat command: do not read the codebase as a design input.
- Do not expand scope. If elaboration exposes a scope problem, stop and recommend `/ldd:scope`.
- Keep acceptance criteria product-facing and draft-quality; testability is finalized by `/ldd:refine`.
- Make a local commit after writing. Do not mutate GitHub unless explicitly approved for branch push/update.

## Stop Conditions

- missing scoped PRD
- elaboration would change goals or non-goals
- unresolved product question blocks useful detail
