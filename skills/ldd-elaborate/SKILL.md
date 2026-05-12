---
name: ldd-elaborate
description: Run /ldd:elaborate for an LDD ticket. Use when the user says /ldd:elaborate or wants to fill product detail inside existing LDD PRD scope.
---

# /ldd:elaborate

Update `prd.md` in the active draft or promoted ticket directory with product detail inside existing scope.

## Owns

- Problem
- Users / Personas
- User Stories
- Draft Acceptance Criteria
- Draft Success Metrics
- Open Questions

## Rules

- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- External mutations require human confirmation.
- PM-hat command: do not read the codebase as a design input.
- Use the PRD template as a quality contract. Preserve the scoped goals/non-goals and fill only product-detail sections.
- Do not expand scope. If elaboration exposes a scope problem, stop and recommend `/ldd:scope`.
- Keep acceptance criteria product-facing and draft-quality; testability is finalized by `/ldd:refine`.
- Make a local commit after writing. Do not mutate GitHub unless explicitly approved for branch push/update.

## Stop Conditions

- missing scoped PRD
- elaboration would change goals or non-goals
- unresolved product question blocks useful detail
