---
name: ldd-design
description: Run /ldd:design for a GitHub issue. Use when the user says /ldd:design or wants an SDD and ADR check from a merged LDD PRD.
---

# /ldd:design

Create or update `docs/tickets/<issue>/sdd.md` on `ldd/sdd-plan/<issue>`.

## Reads

- merged PRD
- relevant code
- existing ADRs under configured ADR directory

## Produces

- Software Design Document
- ADR creates/updates only when the strict ADR threshold is met

## Rules

- GitHub is the ledger. Do not create LDD labels, GitHub Actions, progress logs, or audit event files.
- GitHub mutations require human confirmation.
- SE-hat command: existing code and ADRs may shape implementation design.
- The PRD still owns product scope. If code reality contradicts the PRD, stop and return to the earliest affected PM step.
- ADR threshold: hard to reverse, surprising without context, and the result of a real trade-off.
- Mandatory ADR support does not mean mandatory ADR creation.
- Commit locally after design. Do not push/update PRs unless explicitly approved.

## Stop Conditions

- PRD PR not merged
- code reality contradicts PRD
- ADR-worthy decision cannot be resolved
