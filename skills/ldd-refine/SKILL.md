---
name: ldd-refine
description: Run /ldd:refine for an LDD ticket. Use when the user says /ldd:refine or wants to sharpen an LDD PRD for engineering handoff and review.
---

# /ldd:refine

Polish `prd.md` in the active draft or promoted ticket directory for the PM-to-SE handoff.

## Owns

- Testable acceptance criteria
- Measurable success metrics
- Resolved or explicitly owned open questions
- Clear dependencies
- Removal of vague or solution-smuggling language

## Rules

- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- External mutations require human confirmation.
- PM-hat command: do not read the codebase as a design input.
- Use the PRD template's quality bar and handoff checklist before proposing a PRD PR.
- Do not expand scope or add technical design.
- Commit locally after refinement.
- After human approval, promote the draft to a stable ticket ID and sync a rich Product Requirement ticket to the configured external tracker when present.
- External Product Requirement tickets must be readable without opening the repo. Use `.ldd/templates/issue-body-prd.md` and include the PRD problem, goals, non-goals, users, user stories, acceptance criteria, success metrics, dependencies, open questions, and LDD links.
- Before updating an existing external ticket, re-read it. If its body changed since the last recorded sync hash or timestamp, stop and ask the human to reconcile the external contribution.
- PRD PR reviewer prompt: "Is this ready for engineering design?"

## Stop Conditions

- missing elaborated PRD
- acceptance criteria cannot be made testable
- open questions lack owner or resolution
- refinement reveals a scope problem, which returns to `/ldd:scope`
