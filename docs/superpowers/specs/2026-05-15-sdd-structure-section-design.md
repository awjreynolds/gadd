# SDD Structure Section Design

**Date:** 2026-05-15
**Status:** approved direction for implementation planning
**Context:** making AI-generated Software Design Documents easier for humans and downstream agents to review before reading detailed design sections

## Thesis

LDD Software Design Documents (SDDs) must include a required `## Structure` section near the top of the document.

The SDD is intentionally detailed: it grounds a Product Requirements Document (PRD) in current code, Architecture Decision Records (ADRs), interfaces, data flow, migration, observability, security, alternatives, and open design questions. That detail is valuable, but it creates a human cognition problem when the first useful summary is buried inside a long AI-generated artifact.

`## Structure` is the SDD's "header file": a compact, stable summary of the design shape before the detailed implementation rationale. A reviewer should be able to read it first and understand the interface of the design before deciding which detailed sections to inspect.

## Required Placement

The SDD template should place `## Structure` immediately after the SDD title and before `## Context`.

```markdown
# Software Design Document: {title}

## Structure

...

## Context

...
```

This makes the structure summary the first content section a human or agent reads.

## Required Content

The `## Structure` section should be mandatory for every SDD, including small ones. Small designs can keep each bullet short, but they should still expose their shape explicitly.

The section should use this shape:

```markdown
## Structure

Summarize the design shape before the detailed sections.

- Design intent:
- Primary components / modules:
- Responsibility boundaries:
- Key interfaces / contracts:
- Data or control flow:
- Explicit non-changes:
- Detail map:
```

Each item is intentionally short:

- **Design intent:** one or two sentences describing what the design changes.
- **Primary components / modules:** named parts of the codebase or system touched by the design.
- **Responsibility boundaries:** which component owns what after the change.
- **Key interfaces / contracts:** public APIs, commands, file formats, config, data contracts, events, or persistence boundaries that matter.
- **Data or control flow:** the main path in compact form.
- **Explicit non-changes:** tempting changes the design does not make.
- **Detail map:** pointers to detailed SDD sections such as `Proposed Design`, `Interfaces / Contracts`, `Migration / Compatibility`, or `Security / Privacy`.

## Quality Bar

A reviewer should be able to read `## Structure` and answer:

- What is this design doing?
- Which parts of the system are involved?
- What are the boundaries and interfaces?
- What is deliberately not changing?
- Where in the SDD should I read the detailed rationale?

The section must be concise, but it must not be vague. It should summarize the actual detailed design, not repeat generic project goals from the PRD.

## Command Behavior

`/ldd:design` should write or update `## Structure` whenever it writes an SDD.

The design command should:

- write `## Structure` before detailed sections
- keep it synchronized with `Decision Summary`, `Proposed Design`, `Data Flow / Control Flow`, and `Interfaces / Contracts`
- treat it as a summary of the detailed design, not a separate design authority
- avoid turning it into a second PRD, plan, or implementation checklist

If a later design edit changes components, boundaries, interfaces, or non-changes, `/ldd:design` must update `## Structure` in the same edit.

## Approval Behavior

`/ldd:approve` should treat missing or stale `## Structure` as approval-blocking for SDD approval.

An SDD should not be approved if:

- the `## Structure` section is missing
- the section is still placeholder text
- it contradicts the detailed design
- it omits a material component, boundary, interface, or non-change described later in the SDD
- it summarizes product scope without explaining design structure

This gate applies to new or updated SDDs going forward. Historical archived SDDs do not need migration unless they are reopened or edited.

## Documentation Impact

The following surfaces should mention the requirement:

- `skills/ldd-setup/assets/templates/sdd.md`
- `skills/ldd-design/SKILL.md`
- `skills/ldd-approve/SKILL.md`
- `docs/workflow.md`
- `docs/skills.md`
- `scripts/validate-ldd-mvp.sh`

README changes are optional. The README should stay concise unless the workflow pitch needs to explain this as part of LDD's human-review discipline.

## Non-Goals

- Do not create a separate `structure.md` artifact by default.
- Do not make `## Structure` canonical over the detailed SDD sections.
- Do not migrate archived SDDs unless they are reopened or edited.
- Do not duplicate the entire detailed design inside `## Structure`.
- Do not turn `## Structure` into the implementation plan; `/ldd:plan` owns planning.

## Acceptance Criteria

- The SDD template includes `## Structure` immediately after the document title.
- `/ldd:design` requires new and updated SDDs to include a concise, synchronized `## Structure`.
- `/ldd:approve` blocks SDD approval when `## Structure` is missing, placeholder, contradictory, or materially incomplete.
- Human-facing docs explain that `## Structure` is the SDD's TLDR/header-file section.
- Validation checks for the template and command contract wording.
- Existing archived SDDs are not rewritten as part of this change.
