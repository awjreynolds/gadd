# GADD Skill Catalog

This is the human-readable catalog for the `/gadd:*` skills. The canonical executable contract for each command remains its `skills/gadd-*/SKILL.md` file.

Use this document to understand where a skill sits in the workflow, what it consumes, what it produces, and what handoff usually follows.

## Documentation Standard

Each GADD skill is documented in the Agent Skills layout:

```text
skills/gadd-<command>/
  SKILL.md
  agents/openai.yaml
  assets/
  references/
  scripts/
```

- `SKILL.md` is required and canonical. It contains frontmatter, trigger description, workflow rules, input quality gates, writes, outputs, and validation behavior.
- `agents/openai.yaml` is recommended UI metadata for agent skill lists and chips.
- `assets/`, `references/`, and `scripts/` are optional. Use them only when the skill needs templates, deeper reference material, or deterministic helper scripts.
- Do not add per-skill `README.md` files. Human summaries belong here; executable command contracts belong in `SKILL.md`.

## Workflow Skills

| Skill | Lane | Purpose | Primary inputs | Primary outputs | Usual next handoff |
| --- | --- | --- | --- | --- | --- |
| `/gadd:triage` | Intake | Normalize unclassified intake and route a Work Item. | Free-form prompt, external issue, bug report, task, support signal, ambiguous request, optional GitNexus context | Work Item ledger, approved triage outcome, optional external comment/body/labels after approval | `/gadd:implement`, `/gadd:design`, `/gadd:research`, `/gadd:scope`, or terminal state |
| `/gadd:research` | Product Requirement Lane | Gather sanitized product and repo evidence before scoping when inputs are weak, sensitive, or need investigation. | Product trigger, repository files/docs, existing GADD artifacts, Work Item routed from triage with `needs_prd`, optional GitNexus context | `research.md`, readiness decision, explicit uncertainties | `/gadd:scope` |
| `/gadd:scope` | Product Requirement Lane | Define Product Requirement scope boundaries without moving into design or implementation. | Product change, goals, non-goals, constraints, draft context, Work Item routed from triage with `needs_prd` | draft `prd.md` scope sections, dependencies, open questions | `/gadd:elaborate` |
| `/gadd:elaborate` | Product Requirement Lane | Fill product detail inside approved Product Requirement scope. | scoped draft PRD, user/persona context, workflow detail, acceptance signals | richer `prd.md` with users, stories, draft acceptance criteria, draft metrics | `/gadd:refine` |
| `/gadd:refine` | Product Requirement Lane | Sharpen the PRD for engineering handoff and route it to approval. | draft PRD, resolved product decisions, repo-informed constraints | review-ready `prd.md`, ledger gate for PRD approval | `/gadd:approve <work-item-id>` |
| `/gadd:approve` | Product Requirement Lane / Technical Design | Approve exactly one PRD, SDD, or plan gate from repo-local ledger state. | target ledger, candidate PRD/SDD/plan, external drift metadata when configured | approved artifact state, next command, approval evidence | `/gadd:design`, `/gadd:plan`, or `/gadd:decompose` depending on the approved gate |
| `/gadd:design` | Technical Design | Create or update the repo-scoped Software Design Document (SDD), including the required `## Structure` header-file summary. | approved PRD or approved triage outcome, code/docs, Architecture Decision Records, related repo context, optional GitNexus context | draft `sdd.md`, synchronized structure summary, ADR updates only when the ADR threshold is met | `/gadd:approve <work-item-id>` |
| `/gadd:plan` | Technical Design | Create an implementation plan from approved Product Requirement or engineering-change design inputs. | approved PRD or approved triage outcome, approved SDD, relevant ADRs, code-intelligence context | draft `plan.md`, generated `plan.html`, planned vertical slices | `/gadd:approve <work-item-id>` |
| `/gadd:decompose` | Technical Design | Turn an approved plan into independently grabbable Work Item slices. | approved Work Item boundary, approved SDD, approved plan, tracker state when configured | child Work Item ledgers, child Work Items, parent ledger child entries | `/gadd:implement <work-item-id>` or `/gadd:implement ALL` |
| `/gadd:implement` | Software Engineering | Execute one ready Work Item or all ready Work Items within the approved boundary. | ready Work Item, approved triage outcome or approved PRD/SDD/plan, codebase, tests, docs obligation | code diff or Pull Request, tests, implementation evidence, documentation impact evidence | `/gadd:verify <work-item-id>` |
| `/gadd:verify` | Engineering Review | Verify one implemented Work Item is ready for human-approved closure. | Work Item ledger, approved artifacts or triage outcome, implementation evidence, checks, docs impact, PR state | `verification.md`, closure readiness, verifier evidence | `/gadd:close <work-item-id>` |
| `/gadd:close` | Engineering Review | Apply human-approved workflow closure to a verified Work Item or parent roll-up. | verification evidence, Work Item ledgers, external drift metadata when configured | closed ledger state, optional external issue closure after confirmation | `/gadd:archive <work-item-id>` when local cleanup is wanted |
| `/gadd:archive` | Engineering Review | Move already-closed local Work Item packages into the configured archive directory. | closed Work Item ledger, parent ledger when needed, archive config | archived local Work Item package, updated archive state | none |

Product Requirement lane commands reject non-product Work Item types. `/gadd:research`, `/gadd:scope`, `/gadd:elaborate`, and `/gadd:refine` accept direct PM-led discovery or a Work Item routed from triage with `needs_prd`; they route `bug_fix`, `task`, and `engineering_change` Work Items back to `/gadd:next` or `/gadd:triage`.

## Utility Skills

| Skill | Used by | Purpose | Writes |
| --- | --- | --- | --- |
| `/gadd:setup` | Repository owners and project starters | Bootstrap a target repository with `gadd/config.yml`, templates, Work Item directories, and optional projection settings. | Local GADD config, templates, `gadd/work-items/` structure |
| `/gadd:next` | Everyone | Read repo-local ledger state and report the next command, next human action, reason, and blocker. | Nothing. It is read-only. |

## Ownership Boundaries

- Intake owns unclassified free-form prompts, external issues, bug reports, tasks, support signals, and ambiguous requests until they route to implementation, SDD, Product Requirement discovery, or terminal handling.
- Product Requirement Lane owns requirements analysis and the approved PRD. It can inspect repo context, but it does not decide architecture or implementation.
- Technical Design owns the repo-scoped SDD, plan, and decomposition. Senior Engineers, Tech Leads, and Architects are expected participants.
- Software Engineering owns implementation quality inside the approved boundary: Test-Driven Development, code, refactoring, local design choices, documentation impact, and implementation evidence.
- Engineering Review owns verification and closure readiness. Quality Assurance contributes here where the team uses a QA role.
- Engineering Managers, Technical Program Managers, Product Managers, and delivery stakeholders use GADD state for sequencing, capacity, dependency, roadmap, review-load, and status visibility. They do not own a separate GADD command gate.

## Maintaining This Catalog

When a `skills/gadd-*/SKILL.md` contract changes, update this catalog only if the public purpose, lane, input, output, or handoff changed. Do not mirror every rule from the skill file.
