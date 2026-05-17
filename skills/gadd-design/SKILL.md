---
name: gadd-design
description: Run /gadd:design for a GADD Work Item to create or update the repo-scoped Software Design Document (SDD) from an approved PRD or approved engineering triage outcome. Use when the user says /gadd:design, asks for an SDD, wants to "create or update the SDD", needs an ADR threshold check, asks about architecture for a Work Item, requests the `## Structure` header-file summary, or otherwise needs to translate an approved product or engineering boundary into a repo-scoped technical design.
---

# /gadd:design

Create or update `sdd.md` in the promoted Work Item directory.

This command is a standalone, agent-agnostic GADD command. Follow this file directly; do not require any other installed skill.

## Input

```text
/gadd:design <work-item-id>
```

If no Work Item ID is provided, stop and ask for the target Work Item ID. Raw external references must route through `/gadd:triage <external-ref>` first; do not infer a Work Item from unrelated modified files.

## Reads

- approved PRD or approved triage outcome
- relevant code
- existing ADRs under configured ADR directory
- GitNexus code-intelligence context when available and relevant

## Produces

- Software Design Document
- ADR creates/updates only when the strict ADR threshold is met
- required SDD `## Structure` header-file summary synchronized with the detailed design

## Input Quality Gate

Required boundary before writing design:

- `product_requirement`: approved PRD in the Work Item ledger.
- `engineering_change`: approved triage outcome in the Work Item ledger.

Raw external issues are never design inputs. If the user passes an external reference and it is not already bound to a `needs_sdd` Work Item, stop and route to `/gadd:triage <external-ref>`. Raw external issues must route through /gadd:triage.

Required input standard before writing design:

- readable code, docs, and ADR context needed to ground engineering design
- no contradiction between code reality and the approved PRD or approved triage outcome
- no unresolved product question that would change goals, non-goals, or acceptance criteria

If inputs fail this standard, write nothing and name the blocking gap. The earliest GADD command that can repair a product gap is `/gadd:refine`, `/gadd:scope`, or `/gadd:research` depending on the missing input; code/design uncertainty remains in `/gadd:design` until it requires an ADR or PRD change.

## Exit Gate

After writing the SDD, stop at explicit SDD approval:

- Set `artifacts.sdd.status: draft`.
- For `engineering_change`, set `artifacts.sdd.implementation_route: single` only when the SDD explicitly says the approved design can be implemented as one direct Work Item without plan/decompose; otherwise set `artifacts.sdd.implementation_route: plan_required`.
- Set `execution_context.current_gate: design_review`.
- Set `execution_context.next_command: /gadd:approve <work-item-id>`.
- Set `execution_context.next_human_action: /gadd:approve <work-item-id>`.
- Use this reviewer prompt: "Is this design ready for implementation planning? If yes, run `/gadd:approve <work-item-id>`."

## Rules

- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- External mutations require human confirmation.
- SE-hat command: existing code and ADRs may shape implementation design.
- GitNexus is strongly recommended before deciding affected repos, systems, SDD boundaries, cross-repo sequencing, or contract risks. If GitNexus is unavailable, stale, unindexed, or outside the configured related repositories, continue with normal code inspection and record the limitation in the SDD.
- Use GitNexus findings as design evidence, not canonical workflow state. Record indexed repositories considered, freshness or staleness notes, affected repos/systems, and any limitations that materially affect design confidence.
- Use the SDD template's quality bar before committing design output.
- Always write or update `## Structure` as the first content section of the SDD. Treat it as the SDD's header-file summary: concise enough to skim, concrete enough to reveal the design shape.
- Always keep it synchronized with `Decision Summary`, `Proposed Design`, `Data Flow / Control Flow`, and `Interfaces / Contracts`. If the design changes components, boundaries, interfaces, flow, or explicit non-changes, update `## Structure` in the same edit.
- Do not use `## Structure` as a second PRD, implementation plan, or separate design authority. It summarizes the detailed SDD; it does not replace it.
- The approved PRD or approved triage outcome owns the Work Item boundary. If code reality contradicts that boundary, stop and return to the earliest affected Product Manager or triage step.
- ADR threshold: hard to reverse, surprising without context, and the result of a real trade-off.
- Mandatory ADR support does not mean mandatory ADR creation.
- Commit locally after design. Do not push/update PRs unless explicitly approved.
- SDD approval must be recorded through `/gadd:approve <work-item-id>`, not conversational shorthand.
- Small `engineering_change` Work Items may skip `/gadd:plan` and `/gadd:decompose` only when the SDD records `artifacts.sdd.implementation_route: single`.
- In GitHub tracker mode, prepare SDD/plan review PR content only as a managed projection and ask for explicit human confirmation before any PR create or update.
- GitHub PRs are the first external review surface for SDD/plan review; Linear and Jira review surfaces are follow-on and optional.

## Stop Conditions

- required approved PRD or approved triage outcome is missing
- code reality contradicts the approved boundary
- ADR-worthy decision cannot be resolved
- external drift detected on a managed SDD projection
- team policy requires GitNexus evidence but GitNexus is unavailable, stale, or outside the configured related repositories
- SDD template is missing from the configured templates directory
