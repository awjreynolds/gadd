---
name: ldd-refine
description: Run /ldd:refine for a GitHub issue. Use when the user says /ldd:refine or wants to sharpen an LDD PRD for engineering handoff and PRD PR review.
---

# /ldd:refine

Polish `docs/tickets/<issue>/prd.md` on `ldd/prd/<issue>` for the PM-to-SE handoff.

## Owns

- Testable acceptance criteria
- Measurable success metrics
- Resolved or explicitly owned open questions
- Clear dependencies
- Removal of vague or solution-smuggling language

## Rules

- GitHub is the ledger. Do not create LDD labels, GitHub Actions, progress logs, or audit event files.
- GitHub mutations require human confirmation.
- PM-hat command: do not read the codebase as a design input.
- Do not expand scope or add technical design.
- Commit locally after refinement.
- After human approval, push/open/update the PRD PR with `references #<issue>`.
- PRD PR reviewer prompt: "Is this ready for engineering design?"

## Stop Conditions

- missing elaborated PRD
- acceptance criteria cannot be made testable
- open questions lack owner or resolution
- refinement reveals a scope problem, which returns to `/ldd:scope`
