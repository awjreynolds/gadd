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

## Exit Gate

After writing the SDD, stop at explicit SDD approval:

- Set `artifacts.sdd.status: draft`.
- Set `execution_context.current_gate: design_review`.
- Set `execution_context.next_command: /ldd:approve <ticket-id>`.
- Set `execution_context.next_human_action: /ldd:approve <ticket-id>`.
- Use this reviewer prompt: "Is this design ready for implementation planning? If yes, run `/ldd:approve <ticket-id>`."

## Rules

- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- External mutations require human confirmation.
- SE-hat command: existing code and ADRs may shape implementation design.
- Use the SDD template's quality bar before committing design output.
- The PRD still owns product scope. If code reality contradicts the PRD, stop and return to the earliest affected Product Manager step.
- ADR threshold: hard to reverse, surprising without context, and the result of a real trade-off.
- Mandatory ADR support does not mean mandatory ADR creation.
- Commit locally after design. Do not push/update PRs unless explicitly approved.
- SDD approval must be recorded through `/ldd:approve <ticket-id>`, not conversational shorthand.
- In GitHub tracker mode, prepare SDD/plan review PR content only as a managed projection and ask for explicit human confirmation before any PR create or update.
- GitHub PRs are the first external review surface for SDD/plan review; Linear and Jira review surfaces are follow-on and optional.

## Stop Conditions

- PRD not approved
- code reality contradicts PRD
- ADR-worthy decision cannot be resolved
