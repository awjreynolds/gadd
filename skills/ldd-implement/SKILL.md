---
name: ldd-implement
description: Run /ldd:implement for an LDD child vertical-slice ticket. Use when the user says /ldd:implement or wants to execute an approved child ticket with code and tests.
---

# /ldd:implement

Execute one ready child vertical-slice ticket.

## Reads

- child ticket ledger
- parent Product Requirement ledger
- approved PRD
- approved SDD
- approved `plan.md`

## Rules

- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- External mutations require human confirmation.
- Use TDD: one behavior/test at a time, minimal implementation, refactor only after green.
- Follow the approved child ticket and parent plan. Do not silently update `plan.md` from implementation.
- Do not auto-decompose. If no ready child tickets exist, report that there are no tickets to implement. If the plan is approved but no child tickets exist, report that `/ldd:decompose` is required.
- If the plan is wrong, stop and return to the earliest affected `/ldd:design` or `/ldd:plan` step.
- The implementation PR contains product code and tests only. Do not write `progress.md`.
- Run configured checks before PR.
- Use the implementation PR body template to summarize plan adherence, tests/checks, and any approved deviations.
- After human approval, update the child ticket and parent ledger according to `.ldd/config.yml`.
- Implementation PR reviewer prompt: "Does this implementation follow the approved plan?"

## Stop Conditions

- child ticket missing
- no ready child tickets exist
- plan is approved but `/ldd:decompose` has not created child tickets
- plan is wrong
- tests/checks fail
- implementation requires a product-scope change
