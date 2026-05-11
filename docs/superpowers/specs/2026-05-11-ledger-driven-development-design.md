# Ledger-Driven Development — Design

**Date:** 2026-05-11
**Status:** Draft, awaiting review
**Author:** awjreynolds (with AI-assisted brainstorming)

## 1. Thesis

Ledger-Driven Development (LDD) is the synthesis of three existing approaches to AI-assisted software engineering:

- **Matt Pocock's skills** — pragmatic AI-skill ergonomics, ledger-aware tooling, per-repo configuration.
- **QRSPI (Lavaee)** — structural alignment discipline, engineer-reviewed plans, ticket-blind research.
- **Agile SDLC** — role-aware artifact hierarchy (Initiative → PRD → Epic → Story → Task → PR), team-coordination semantics, stakeholder visibility.

LDD connects these under a single first principle: **the ledger is the source of truth, and the workflow lives as labelled state transitions on tickets that carry structured, role-owned, human-renderable artifacts.**

LDD is intentionally **agent- and model-agnostic**. The workflow lives in artifacts and labels on disk and in the ledger, not in any particular AI platform. Any modern coding agent capable of reading markdown and dispatching subagents (with fallback to phased prompting) can execute LDD.

## 2. The Gap Analysis

LDD exists because the existing approaches each leave concrete gaps when applied to team-shaped software work.

| # | Gap | Where it exists | LDD's answer |
|---|---|---|---|
| 1 | QRSPI has no ledger and no roles | QRSPI is solo-engineer-shaped | Wrap QRSPI's phase rigour in agile artifacts + role-owned sections |
| 2 | Pocock conflates PRD and plan | `/to-prd` produces one thing | Separate PRD (the *what*) from plan (the *how*); different artifacts, different reviewers |
| 3 | Pocock's grilling is unbounded | One large PRD grill, scope creeps | Bounded grills per section, per role; each enforces a role's surface area only |
| 4 | Agile SDLC has no structural alignment depth | "Acceptance criteria" ≠ technical alignment | Insert QRSPI's research + plan-review gates *before* implement — operationalised as a plan-PR |
| 5 | No approach renders artifacts for humans | All ship raw markdown | Structured-source → HTML view as the cognitive-load lever |
| 6 | PRD-in-issue doesn't scale to JIRA | Walls-of-text in ticket descriptions | Ticket-as-index + repo-committed artifacts decouples ledger UX from artifact depth |
| 7 | None reconcile stakeholder vs engineer views | Engineers want depth; TPMs want summary | Macro × micro phases + label namespaces give both audiences a view of the same ticket |
| 8 | Cognitive overload at code review | Plan and code reviewed together, late | Shift review to plan-PR; code-PR becomes a spot-check |
| 9 | None handle epic → ticket decomposition with carried context | Pocock's `/to-issues` is one-shot, loses parent framing | `/ldd:refine` decomposition preserves parent PRD context as inherited frontmatter |
| 10 | None offer a clean trunk of traceability | Spec ↔ plan ↔ PR ↔ release links are manual | Labels + frontmatter create a graph: ticket ↔ design.md commit ↔ plan-PR ↔ code-PR |

## 3. What LDD is *not*

- **Not a wrapper around Pocock.** Borrows the ergonomic patterns (per-repo setup, ledger backends, label-driven state); ships its own skill set tuned to LDD's model.
- **Not a code-generation tool.** It's an alignment + traceability tool that produces code as a side effect.
- **Not a JIRA plugin.** Ledger-agnostic by design.
- **Not a methodology document.** Executable skills + templates + a small renderer.
- **Not a replacement for craft skills.** Disciplines like TDD and bug-diagnosis live inside LDD's workflow skills (`/ldd:implement`, `/ldd:design`). Users who want pure-discipline tools can install Pocock or others alongside; namespacing prevents conflict.
- **Not Scrum-dependent.** Scrum-compatible — labels can mirror sprint board columns — but the workflow runs on artifact state, not sprint cadence. AI is hollowing out coordination ceremonies; LDD doesn't depend on them existing.

## 4. Architecture

### 4.1 Six moving parts

1. **Ledger** — source of truth for ticket *status*. JIRA, GitHub Issues, Linear, or local files (chosen at setup).
2. **Artifacts** — source of truth for ticket *content*. Committed markdown in `docs/tickets/<KEY>/`, with auto-generated HTML companions.
3. **Labels** — universal state machine. Works identically across ledger backends.
4. **Skills** — bounded, atomic, portable markdown operations.
5. **Health checks + overrides** — gates by default, escape on record.
6. **Subagent dispatch + tier-based model selection** — platform-adaptive orchestration.

### 4.2 Core abstraction

LDD models software work as a directed graph of artifacts anchored to ledger tickets:

```
                     ┌────────────────┐
                     │  Ledger ticket │  ← source of truth (status, labels, links)
                     │  (GH/JIRA/...) │
                     └───────┬────────┘
                             │ links to
                             ▼
  docs/tickets/PROJ-123/
  ├── ticket.md            ← role-owned sections, mirrors ledger content
  ├── design.md → .html    ← architectural decisions, structure outline
  ├── plan.md   → .html    ← ordered execution slices (reviewed via plan-PR)
  ├── progress.md          ← appended during implement
  ├── audit.yml            ← append-only invocation log
  └── (optional) prd.md   ← inherited from parent epic, frontmatter-linked
```

The ledger holds *status*; the repo holds *content*. Conflicts resolve to repo for content, ledger for state.

### 4.3 The two-PR pattern (plus optional design-PR)

```
ticket created ──► /ldd:triage (bugs only) ──► /ldd:refine ──► /ldd:design ──► /ldd:plan
                                                                                 │
                                                                                 ▼
                                                                          ┌──────────────┐
                                                                          │  Plan PR     │  ← engineer reviews
                                                                          │  (plan.md)   │     before any code
                                                                          └──────┬───────┘
                                                                                 │ merged
                                                                                 ▼
                                                                          /ldd:implement
                                                                                 │
                                                                          opens  ▼
                                                                          ┌──────────────┐
                                                                          │  Code PR     │  ← spot-check
                                                                          │  (impl+tests)│     (alignment already done)
                                                                          └──────────────┘
```

For epic-level work, an additional **design-PR** is opened from `/ldd:design` so architectural decisions are reviewed before the execution plan is written.

### 4.4 Health checks with overrides (cross-cutting)

Every LDD skill follows this shape:

```
┌───────────────────────────────────────────────────────────┐
│  Skill execution                                          │
├───────────────────────────────────────────────────────────┤
│  1. Preflight checks (refuse if invalid; suggest fix)     │
│  2. Body (the actual work)                                │
│  3. Postcondition verification (was the work durable?)    │
│  4. Audit record (frontmatter / ticket comment)           │
└───────────────────────────────────────────────────────────┘
```

Preflight refusals are bypassed with `--override="<reason>"`. The override is captured durably in artifact frontmatter and mirrored as a ticket comment. Overrides are always allowed; they are never silent.

`--dry-run` runs only preflight checks and reports what would happen — useful for CI gates and ticket-readiness queries.

### 4.5 Subagent dispatch and model tiers

LDD skills are *orchestrators*. The main agent does coordination + final synthesis; subagents do heavy lifting in isolated context windows. This enables:

- **Ticket-blind research** — fresh-context subagent investigates the codebase with no ticket reference, then findings are synthesised back into the main agent's context.
- **Parallel alternatives exploration** — multiple subagents explore design options concurrently.
- **Cost-aware routing** — different sub-tasks dispatched to different model tiers based on cognitive load required.

Three model tiers:

| Tier | Purpose |
|---|---|
| `fast` | High-volume, pattern-matching, low-stakes |
| `balanced` | Structured generation, conversation, most operational work |
| `reasoning` | High-leverage decisions, synthesis, alternatives weighing |

Users map tiers to their platform's available models at setup time. Skills only reference tiers — never concrete model IDs.

For platforms without subagent primitives, LDD falls back to **phased prompting** (the main agent is instructed to investigate without referencing the ticket as a first phase, then revealed the ticket as a second phase). Lower rigour but workable.

## 5. Phase Model

### 5.1 Six macro phases

Tickets move through these phases. Each is represented by a `phase:*` label.

| Phase | Label | What happens | When |
|---|---|---|---|
| Refinement | `phase:refinement` | Ticket gets contextually complete (PRD, role-owned sections, decomposition if epic) | Pre-sprint (during backlog refinement) |
| Design | `phase:design` | Codebase research + architectural decisions + structure outline → `design.md` | In-sprint |
| Plan | `phase:plan` | Ordered execution slices → `plan.md`, plan-PR opened | In-sprint |
| Implement | `phase:implement` | TDD execution following the merged plan, code-PR opened | In-sprint |
| Verify | `phase:verify` | PR review + CI + acceptance-criteria validation | In-sprint |
| Close | `phase:close` | Ticket closed, traceability complete | In-sprint |

### 5.2 Label namespaces

Universal across ledger backends. Set/modified by skills and PR-merge webhooks.

- **`phase:*`** — current macro phase (mutually exclusive)
- **`kind:*`** — `bug`, `feature`, `refactor`, `epic`
- **`risk:*`** — `low`, `med`, `high`
- **`plan:*`** — `draft`, `in-review`, `approved`
- **`gate:*`** — sticky markers that a gate cleared (`gate:prd-approved`, `gate:design-approved`, `gate:plan-approved`, `gate:tests-green`)
- **`triage:*`** — `accepted`, `needs-info`, `duplicate-of:#N`, `wontfix` (bug intake only)

Setup maps these canonical labels to ledger-specific strings (since JIRA labels ≠ GH labels ≠ Linear labels).

### 5.3 Board column mapping

`/ldd:setup` writes a default mapping that users override to match their existing board:

```
phase:refinement  → "Ready"
phase:design      → "Design"
phase:plan        → "Plan in Review"
phase:implement   → "In Progress"
phase:verify      → "In Review"
phase:close       → "Done"
```

## 6. Skill Inventory

Six macro skills. Each is a single user-facing verb that orchestrates internal sub-steps and subagent dispatches.

### 6.0 Skill ↔ phase mapping at a glance

| Skill | Applies to | Phase transition produced | Notes |
|---|---|---|---|
| `/ldd:setup` | repo, one-time | — | Bootstrap; not part of any ticket's phase flow |
| `/ldd:triage` | `kind:bug` only | (unlabelled) → `phase:refinement` | Continuous; not sprint-bound |
| `/ldd:refine` | any ticket | `phase:refinement` → `phase:design` (for stories); also creates child tickets (for epics) | Three internal branches: PRD, ticket, decompose |
| `/ldd:design` | any ticket with `phase:design` | `phase:design` → `phase:plan` | Subagent-driven ticket-blind research by default |
| `/ldd:plan` | any ticket with `phase:plan` | `phase:plan` → (via plan-PR merge) `phase:implement` | Opens plan-PR |
| `/ldd:implement` | any ticket with `phase:implement` + `gate:plan-approved` | `phase:implement` → `phase:verify` → (on code-PR merge) `phase:close` | Opens code-PR; TDD-driven |

Verify and close are not skills — they happen via PR review + CI + automated label flips on merge.

### 6.1 `/ldd:setup` — bootstrap

**Inputs:** invoked once per repo; user answers configuration questions interactively.

**Outputs:**
- `.ldd/config.yml` — ledger backend, render target, label mapping, role definitions, board column mapping, model tier resolution
- `.ldd/labels.yml` — canonical labels mapped to ledger-specific strings
- `.ldd/templates/{bug,feature,refactor,epic}.md` — ticket templates per kind
- `.ldd/renderer/` — HTML rendering templates
- `.github/workflows/ldd-render.yml` (or platform equivalent) — CI hook to regenerate HTML on commit
- `docs/tickets/` — directory created
- Canonical labels created in the ledger via API

**Re-runnable:** yes, idempotent.

### 6.2 `/ldd:triage` — bug intake (orthogonal)

**Inputs:** a `kind:bug` ticket (or unlabelled ticket suspected to be a bug).

**Process:**
1. Attempt reproduction (subagent, `fast` tier)
2. Detect duplicates by signature (subagent, `fast` tier)
3. Recommend severity and decision (`balanced` tier)

**Outputs:**
- Ticket labels: `kind:bug`, `risk:*`, one of `triage:accepted` | `triage:needs-info` | `triage:duplicate-of:#N` | `triage:wontfix`
- If accepted: also sets `phase:refinement`, creates `docs/tickets/PROJ-NNN/` skeleton
- Ticket comment with triage notes (repro outcome, severity reasoning, duplicate links)
- Audit record

**Continuous, not sprint-bound.** Bugs arrive on their own schedule.

### 6.3 `/ldd:refine` — refinement (three internal branches)

The skill detects input type and branches internally according to this decision tree:

```
input is conversation context only (no ticket reference)        → Branch A (PRD)
input is a ticket with kind:epic AND no prd.md                  → Branch A (PRD)
input is a ticket with kind:epic AND gate:prd-approved set      → Branch C (decompose)
input is a ticket with kind:feature|refactor|bug                → Branch B (ticket)
none of the above                                                → refuse with helpful error
```

Users can force a specific branch with `--as=prd|ticket|decompose` (e.g., to run PRD production on a `kind:feature` ticket that was misclassified).

**Branch A: PRD production** (input: idea/chat OR epic ticket without PRD)
- Bounded grill at PRD scope (`balanced` tier)
- Outputs: `docs/tickets/PROJ-NNN/prd.md` → `prd.html`; new epic ticket if absent; `kind:epic`, `phase:refinement`, `prd:in-review`; PRD-PR opened

**Branch B: Ticket refinement** (input: thin ticket with `kind:feature|refactor|bug`)
- Bounded grill at ticket scope (`balanced` tier); fills role-owned sections (problem, acceptance criteria, affected modules, out-of-scope)
- Outputs: `ticket.md` → `ticket.html`; ledger description synced; `phase:refinement` → `phase:design` on completion
- No PR (committed directly to main; reviewed implicitly at the next phase's gate)

**Branch C: Decomposition** (input: epic with `gate:prd-approved`)
- Decomposes PRD into child tickets with inherited frontmatter (`reasoning` tier — bad decomposition costs days)
- Outputs: N new ledger child tickets with `kind:feature`, `phase:refinement`, `parent: PROJ-100`; each child gets `ticket.md` with inherited PRD context; parent epic gets `decomposed:true` + child links

**Bounded grilling is the anti-scope-creep mechanism** — each branch grills only against the artifact's surface, not against the whole project.

### 6.4 `/ldd:design`

**Inputs:** a ticket with `phase:design`.

**Process:**
1. **Ticket-blind research subagent** (`balanced` tier, fresh context, no ticket reference) characterises affected modules objectively. Default-on for `kind:bug`, `kind:refactor`, `risk:high`, and brown-field feature work. Off for green-field features in fresh modules. Overridable with `--research-mode=blind|sighted|skip`.
2. **Alternatives exploration** (parallel subagents, `balanced` tier) — 2–3 design options compared.
3. **Design synthesis** (main agent, `reasoning` tier) produces `design.md` with three mandatory sections:
   - **Research** — ticket-blind findings (objective characterisation of the codebase)
   - **Decisions** — chosen architectural approach with alternatives considered
   - **Structure** — proposed interface shape (signatures, types, module boundaries)

**Outputs:**
- `docs/tickets/PROJ-NNN/design.md` → `design.html` (collapsible sections, diagrams, file pills)
- `phase:design` → `phase:plan` on completion
- For `kind:epic`: separate design-PR opened (`ldd/design/PROJ-NNN` branch) with `design.md`
- For story-level work (`kind:feature|refactor|bug`): no separate PR; `design.md` commits to main and is reviewed inline as part of the upcoming plan-PR
- On design-PR merge (epics only): `gate:design-approved`

### 6.5 `/ldd:plan`

**Inputs:** a ticket with `phase:plan` and `design.md` present.

**Process:**
1. Read design.md
2. Generate ordered vertical slices (`balanced` tier) — each slice with name, files touched, red-test description, acceptance for that slice
3. Plan-review pass (`reasoning` tier) — catches plan-reading illusions before commit

**Outputs:**
- `docs/tickets/PROJ-NNN/plan.md` → `plan.html`
- Branch `ldd/plan/PROJ-NNN` created
- Plan-PR opened against main with `plan.md` (and, for story-level work, the previously-committed `design.md` is included in the diff so reviewers see both)
- Ticket: `plan:in-review` set when PR opens
- On plan-PR merge: `plan:approved`, `gate:plan-approved`, `phase:implement`

### 6.6 `/ldd:implement`

**Inputs:** a ticket with `phase:implement` and `gate:plan-approved`.

**Process:**
1. Read approved plan.md
2. For each slice, walk TDD red → green → refactor:
   - Red test (`balanced` tier — test design quality matters)
   - Implementation code (`fast` tier; escalate to `balanced` on test failure)
   - Refactor pass (`balanced` tier)
3. Append progress per slice to `progress.md`
4. Post progress comment on ticket per completed slice
5. On all slices complete: open code-PR

**Outputs:**
- Code commits on branch `ldd/impl/PROJ-NNN`
- Test files (unit + integration as plan specified)
- `docs/tickets/PROJ-NNN/progress.md` — appended per slice
- Code-PR opened against main with frontmatter:
  ```yaml
  ticket: PROJ-NNN
  plan: docs/tickets/PROJ-NNN/plan.md@<sha>
  design: docs/tickets/PROJ-NNN/design.md@<sha>
  prd: docs/tickets/PROJ-100/prd.md@<sha>   # parent if applicable
  ```
- Ticket: `phase:implement` (in progress) → `phase:verify` when code-PR opens
- On code-PR merge: `gate:tests-green`, `phase:close`, ticket auto-closed

## 7. Workflow Sequences

### 7.1 Direct ticket (bug / feature / refactor without epic parent)

```
/ldd:triage (bugs only) ──► /ldd:refine ──► /ldd:design ──► /ldd:plan
                                                                 │
                                                                 ▼
                                                          [Plan PR review]
                                                                 │
                                                                 ▼
                                                          /ldd:implement
                                                                 │
                                                                 ▼
                                                          [Code PR review]
                                                                 │
                                                                 ▼
                                                              [Close]
```

### 7.2 PRD-initiated work (epic with decomposition)

```
/ldd:refine (PRD branch) ──► [PRD PR review] ──► /ldd:refine (decompose branch)
                                                          │
                          ┌───────────────────────────────┼───────────────────────────┐
                          ▼                               ▼                           ▼
                   child PROJ-101                  child PROJ-102               child PROJ-103
                  /ldd:refine                   /ldd:refine                /ldd:refine
                  /ldd:design                   /ldd:design                /ldd:design
                  /ldd:plan                     /ldd:plan                  /ldd:plan
                  [plan-PR]                     [plan-PR]                  [plan-PR]
                  /ldd:implement                /ldd:implement             /ldd:implement
                  [code-PR]                     [code-PR]                  [code-PR]
```

Sibling children proceed in parallel after decomposition. Only explicit `depends_on:` frontmatter imposes ordering.

### 7.3 Hotfix override (production incident)

```
ticket created (kind:bug, risk:high)
       │
       ▼
/ldd:triage --override="hotfix:incident:INC-42"
       │
       ▼
/ldd:implement --override="hotfix:incident:INC-42"
       │
       ▼
[Code PR, fast-track review]
       │
       ▼
(retrospectively) /ldd:design + /ldd:plan committed post-merge for audit
```

Overrides logged on both ticket and code-PR; the gap between hotfix and retroactive design is visible at retro time.

## 8. Artifact Schemas

All artifacts are structured markdown with YAML frontmatter. HTML companions are auto-generated.

### 8.1 PRD (`prd.md`)

```yaml
---
ticket: PROJ-100
kind: epic
created: 2026-05-11
authors: [pm-name]
status: in-review
---

# <Product feature name>

## Problem
Who is affected, what they currently can't do, why it matters now.

## Goals
Business outcomes this enables (metrics, OKR ties).

## Non-goals
Explicitly out of scope; what this PRD is *not* trying to solve.

## User stories
- As X, I want Y, so that Z.

## Success metrics
How we'll know it worked.

## Open questions
Unresolved items that need PM/EM/stakeholder input.
```

### 8.2 Ticket (`ticket.md`)

```yaml
---
ticket: PROJ-101
parent: PROJ-100         # if decomposed from epic
kind: feature
risk: med
created: 2026-05-11
status: phase:refinement
---

# <Ticket title>

## Problem framing
User-facing problem. Why this ticket exists.

## Acceptance criteria
- [ ] Testable condition 1
- [ ] Testable condition 2

## Affected modules
File/module pointers populated during refinement.

## Out of scope
What this ticket is *not* doing. Future work split into new tickets.
```

### 8.3 Design (`design.md`)

```yaml
---
ticket: PROJ-101
created: 2026-05-11
research_mode: blind        # blind | sighted | skip
---

# Design — <Ticket title>

## Research (ticket-blind findings)
Objective characterisation of the affected modules, produced by a subagent
without ticket context. What the code actually contains and does today.

## Decisions
Chosen architectural approach. Components, relationships, data flow.

### Alternatives considered
- Option A: ... (rejected because ...)
- Option B: ... (rejected because ...)
- Option C: chosen.

## Structure
Proposed interface shape — signatures, types, module boundaries.
Reads like a C header file or .d.ts before implementation.
```

### 8.4 Plan (`plan.md`)

```yaml
---
ticket: PROJ-101
design: design.md@<sha>
created: 2026-05-11
---

# Plan — <Ticket title>

## Slice 1: <name>
- Files touched: src/auth/oauth_config.ts (new), src/auth/oauth_config.test.ts (new)
- Red test: "OAuth config rejects missing client_id"
- Acceptance: test passes; config type exported

## Slice 2: <name>
...
```

## 9. Configuration (`/ldd:setup`)

The setup skill asks the user a sequence of questions and writes `.ldd/config.yml`. Re-runnable to reconfigure.

### 9.1 Questions asked

1. **Ledger backend** — GitHub Issues | JIRA | Linear | local files
2. **Ledger credentials** — env var name where the token lives
3. **Artifact location** — default `docs/tickets/`, customisable
4. **Render target** — GitHub Pages | none (raw markdown only) | custom URL | Confluence push
5. **Label vocabulary mapping** — for each canonical LDD label, what's the ledger-specific string? (Default mapping provided for each backend.)
6. **Board column mapping** — for each `phase:*`, which board column does it correspond to? (Default mapping provided.)
7. **Role definitions** — does your team have a PM/PO? An EM separate from senior engineers? (Affects default ownership of refine branches.)
8. **Agent platform** — Claude Code | Codex CLI | Gemini CLI | Cursor | Continue.dev | Generic. (Determines skill install location and subagent primitive.)
9. **Subagent capability** — auto-detect; user can force off if their platform lacks support.
10. **Model tier resolution** — for each of `fast`, `balanced`, `reasoning`, what's the concrete model ID on your platform?

### 9.2 Output

```yaml
# .ldd/config.yml
ledger:
  backend: github-issues          # or jira | linear | files
  credentials_env: GITHUB_TOKEN
  repo: org/repo                  # backend-specific

artifacts:
  location: docs/tickets/
  render_target: github-pages
  render_url: https://org.github.io/repo/tickets/

labels:
  # canonical → ledger-specific
  "phase:refinement": "phase: refinement"
  "phase:design": "phase: design"
  # ... etc

board:
  "phase:refinement": "Ready"
  "phase:design": "Design"
  # ... etc

roles:
  pm: true
  em_separate_from_se: false
  qa_lead: false

agent:
  platform: claude-code            # or codex-cli | gemini-cli | cursor | continue-dev | generic
  subagents_supported: true
  fallback_strategy: phased-prompt

models:
  triage_repro: fast
  triage_severity: balanced
  refine_grill: balanced
  refine_decompose: reasoning
  design_research_subagent: balanced
  design_synthesis: reasoning
  design_alternatives: balanced
  plan_generation: balanced
  plan_review: reasoning
  implement_test: balanced
  implement_code: fast
  implement_refactor: balanced

tier_resolution:
  fast: "<your-fast-model-id>"
  balanced: "<your-balanced-model-id>"
  reasoning: "<your-reasoning-model-id>"

cost_ceilings:
  per_skill_invocation_usd: null   # optional
```

## 10. Platform Adapters

Skills are written in plain markdown with YAML frontmatter — readable and executable by any modern coding agent. The installer detects platform and places them in the right location.

| Platform | Skill location | Adapter doc |
|---|---|---|
| Claude Code | `.claude/skills/ldd/` | `docs/ldd/adapters/claude-code.md` |
| Codex CLI | `~/.codex/skills/ldd/` (or equivalent) | `docs/ldd/adapters/codex-cli.md` |
| Gemini CLI | `.gemini/skills/ldd/` (or equivalent) | `docs/ldd/adapters/gemini-cli.md` |
| Cursor | `.cursorrules` snippets + `docs/` | `docs/ldd/adapters/cursor.md` |
| Continue.dev | `.continue/` | `docs/ldd/adapters/continue-dev.md` |
| Generic / fallback | `docs/ldd/skills/` (user includes in system prompt) | `docs/ldd/adapters/generic.md` |

Each adapter doc maps platform-specific concerns (subagent dispatch primitives, tool naming, slash-command syntax) to the generic LDD model.

## 11. Renderer

A small Markdown → HTML renderer ships with LDD (Python + Jinja templates, ~200 lines target). Triggered automatically by a CI hook on every commit to a `docs/tickets/**/*.md` file.

### 11.1 HTML capabilities

- Collapsible sections (large plans become scannable)
- Risk/status badges (color-coded for TPM scanning)
- Mermaid → SVG for sequence/architecture diagrams
- Auto-generated TOC + anchors (deep-linking from tickets)
- Tabs for "current vs proposed" code comparisons
- File pills (`auth.py:42` rendered as clickable repo links)
- Syntax-highlighted code blocks
- Print-friendly view

### 11.2 Source-of-truth invariant

The structured markdown is the source of truth. HTML is regenerated deterministically. The renderer never modifies markdown.

## 12. Non-goals (deliberate)

- **No release management.** Cutting release notes, deploying, rolling out — out of scope. LDD ends at code-PR merge.
- **No verify or close skills.** PR review + CI cover verification. Closing is automated on code-PR merge. These don't need skill-level handles.
- **No sprint planning / standup / retrospective automation.** Scrum ceremonies are human-coordination concerns; LDD doesn't replace them.
- **No new database, no service to run.** Ledger + git is the entire state.
- **No real-time sync.** Skills operate on-demand; CI/webhooks flip labels on PR events; no daemon.
- **No bidirectional ledger-as-truth and repo-as-truth.** Ledger is authoritative for status; repo is authoritative for content. Conflicts resolve to repo for content, ledger for state.

## 13. Open Questions / Future Work

- **PRD-PR review mechanics for PM-heavy orgs.** PMs unfamiliar with PRs may resist. Mitigation: `--override="pm-workflow-exception"` exists; `prd:review-skipped` label visible at retro time. Worth revisiting after first team adoption.
- **Cost ceilings as hard limits vs. warnings.** Configured as warnings initially; revisit if teams hit unexpected bills.
- **Verify-skill candidacy.** A future `/ldd:verify` skill could summarise acceptance-criteria checks, coverage deltas, and security scan outputs as a single readable verification report. Not in v1.
- **Cross-ticket dependency graph visualisation.** The frontmatter `depends_on:` + `parent:` data is queryable; a visualisation tool could render a project-wide DAG. Out of scope for v1; possible future companion.
- **Templates per ticket `kind:`** — `kind:bug` template is 3 fields (repro, expected, actual); `kind:feature` is the lean 4 (problem, AC, affected modules, out-of-scope); `kind:refactor` adds risk explicitly. Templates ship in `.ldd/templates/`; teams can customise.

## 14. Glossary

- **Ledger** — the ticket tracker (JIRA, GitHub Issues, Linear, or local files) holding ticket status.
- **Artifact** — a structured markdown file committed to `docs/tickets/<KEY>/` carrying ticket content (PRD, ticket-detail, design, plan, progress).
- **Phase** — one of six macro states a ticket passes through (refinement → design → plan → implement → verify → close).
- **Slice** (in LDD) — one step inside `plan.md`; the unit of execution within a single ticket. Minutes–hours of work. TDD red-test-first.
- **Slice** (in Pocock) — note that Pocock uses this term to mean *ticket-sized* deliverables; in LDD it means *intra-ticket* execution steps. Vocabulary collision.
- **Ticket-blind research** — codebase investigation performed by a subagent with the ticket reference hidden, to prevent biased "find evidence supporting the proposed direction" patterns.
- **Tier** — a logical capability bucket (`fast`, `balanced`, `reasoning`) mapped to concrete model IDs at setup time. Skills only reference tiers.
- **Override** — a `--override="<reason>"` flag that bypasses a preflight check. Always allowed; always logged.
