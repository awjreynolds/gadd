---
name: ldd-implement
description: Run /ldd:implement for a GitHub issue. Use when the user says /ldd:implement or wants to execute an approved LDD plan with code and tests.
---

# /ldd:implement

Execute the merged plan on `ldd/impl/<issue>`.

## Reads

- merged PRD
- merged SDD
- merged ADR changes
- merged `plan.md`
- merged `plan.html`

## Rules

- GitHub is the ledger. Do not create LDD labels, GitHub Actions, progress logs, or audit event files.
- GitHub mutations require human confirmation.
- Use TDD: one behavior/test at a time, minimal implementation, refactor only after green.
- Follow the approved plan. Do not silently update `plan.md` from implementation.
- If the plan is wrong, stop and return to the earliest affected `/ldd:design` or `/ldd:plan` step.
- The implementation PR contains product code and tests only. Do not write `progress.md`.
- Run configured checks before PR.
- After human approval, push/open/update the Implementation PR with `Closes #<issue>`.
- Implementation PR reviewer prompt: "Does this implementation follow the approved plan?"

## Stop Conditions

- PRD or SDD/Plan PR not merged
- plan is wrong
- tests/checks fail
- implementation requires a product-scope change
