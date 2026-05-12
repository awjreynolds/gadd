---
name: ldd-design
description: Run /ldd:design for an LDD ticket. Use when the user says /ldd:design or wants an SDD and ADR check from an approved LDD PRD.
---

# /ldd:design

Create or update `sdd.md` in the promoted ticket directory.

## Reads

- merged PRD
- relevant code
- existing ADRs under configured ADR directory

## Produces

- Software Design Document
- ADR creates/updates only when the strict ADR threshold is met

## Rules

- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- External mutations require human confirmation.
- SE-hat command: existing code and ADRs may shape implementation design.
- Use the SDD template's quality bar before committing design output.
- The PRD still owns product scope. If code reality contradicts the PRD, stop and return to the earliest affected PM step.
- ADR threshold: hard to reverse, surprising without context, and the result of a real trade-off.
- Mandatory ADR support does not mean mandatory ADR creation.
- Commit locally after design. Do not push/update PRs unless explicitly approved.

## Stop Conditions

- PRD not approved
- code reality contradicts PRD
- ADR-worthy decision cannot be resolved
