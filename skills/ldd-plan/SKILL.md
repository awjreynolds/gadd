---
name: ldd-plan
description: Run /ldd:plan for a GitHub issue. Use when the user says /ldd:plan or wants an implementation plan and generated plan.html from an approved LDD SDD.
---

# /ldd:plan

Create or update `docs/tickets/<issue>/plan.md` and generated `plan.html` on `ldd/sdd-plan/<issue>`.

## Reads

- merged PRD
- SDD
- relevant ADRs

## Plan Must Include

- PRD summary
- SDD summary
- ADR summary and links
- implementation slices
- acceptance criteria traceability
- files / modules expected to change
- test strategy
- review checklist

## Rules

- GitHub is the ledger. Do not create LDD labels, GitHub Actions, progress logs, or audit event files.
- GitHub mutations require human confirmation.
- Do not introduce new architectural decisions. If planning discovers one, stop and return to `/ldd:design`.
- `plan.md` is the durable source; `plan.html` is generated from it.
- Commit locally after planning.
- After human approval, push/open/update the SDD/Plan PR with `references #<issue>`.
- SDD/Plan PR reviewer prompt: "Does this design and plan correctly implement the PRD?"

## Stop Conditions

- missing SDD
- planning discovers a new architecture decision
- slices cannot trace to acceptance criteria
