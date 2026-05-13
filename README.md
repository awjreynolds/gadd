# Ledger-Driven Development Skills

Agent-agnostic skills for the Ledger-Driven Development MVP.

LDD uses a repo-local ledger as canonical workflow state. External trackers such as GitHub, Linear, or Jira are optional sync and review surfaces. LDD separates product scope, engineering design, implementation planning, decomposition, implementation, verification, and closure so AI-assisted work has explicit, reviewable handoffs.

## Package Model

The canonical package manifest is `agent-skills.json`.

The canonical skill source is the Agent Skills layout:

```text
skills/<skill-name>/SKILL.md
skills/<skill-name>/assets/
skills/<skill-name>/agents/openai.yaml
```

`agent-skills.json` lists every installable skill path and adapter manifest. Adapter-specific files point back to the matching skill. They are not a second source of truth.

Adapter manifests make the same skills installable in specific agents:

| Agent | Adapter files |
| --- | --- |
| Codex | `skills/ldd-*`, `agents/openai.yaml`, `agent-skills.json` |
| Claude Code | `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `skills/ldd-*` |
| Gemini CLI | `gemini-extension.json`, `GEMINI.md`, `commands/ldd/*.toml`, `skills/ldd-*` |

There is no `ldd-core` skill to install. Shared LDD rules are intentionally embedded in each command-shaped skill so every agent sees the same command contract.

LDD skills are standalone. They must not require other installed skills such as external TDD, issue-generation, planning, triage, or debugging skills. A host agent may provide helpful tools, but every `/ldd:*` command must carry its own workflow contract.

The current workflow design is `docs/superpowers/specs/2026-05-12-local-ledger-mvp-design.md`. Older GitHub-ledger specs remain as historical context only.

## Commands

```text
/ldd:setup
/ldd:next
/ldd:scope
/ldd:elaborate
/ldd:refine
/ldd:approve
/ldd:design
/ldd:plan
/ldd:decompose
/ldd:implement
/ldd:verify
/ldd:close
```

## Install

### Codex

Use `$skill-installer` from inside Codex and ask it to install the skills listed by `agent-skills.json`:

```text
Use $skill-installer to install all skills from
https://github.com/awjreynolds/ledger-driven-development
using agent-skills.json.
```

Until the stock installer reads `agent-skills.json` directly, install the paths in that manifest:

```text
skills/ldd-setup
skills/ldd-next
skills/ldd-scope
skills/ldd-elaborate
skills/ldd-refine
skills/ldd-approve
skills/ldd-design
skills/ldd-plan
skills/ldd-decompose
skills/ldd-implement
skills/ldd-verify
skills/ldd-close
```

Installed Codex skills are local copies under `~/.codex/skills`. They are not live-linked to this repository. To update, remove the installed `ldd-*` skills, reinstall from the current `agent-skills.json`, and restart Codex.

### Claude Code

Add this repository as a plugin marketplace, then install the plugin:

```text
/plugin marketplace add awjreynolds/ledger-driven-development
/plugin install ldd@ledger-driven-development
```

Restart Claude Code after installing.

### Gemini CLI

Install this repository as a Gemini CLI extension:

```sh
gemini extensions install https://github.com/awjreynolds/ledger-driven-development
```

Restart Gemini CLI after installing. The extension provides `commands/ldd/*.toml`, which map to `/ldd:setup`, `/ldd:next`, `/ldd:scope`, `/ldd:elaborate`, `/ldd:refine`, `/ldd:approve`, `/ldd:design`, `/ldd:plan`, `/ldd:decompose`, `/ldd:implement`, `/ldd:verify`, and `/ldd:close`.

## Source Of Truth

- Workflow state: repo-local `ledger.yml` files in the target project.
- Skill package: `agent-skills.json`.
- Command behavior: `skills/ldd-*/SKILL.md`.
- Claude adapters: `commands/ldd/*.md`.
- Gemini adapters: `commands/ldd/*.toml` plus `GEMINI.md`.

External trackers are optional review and sync surfaces. They are not canonical LDD state.

GitHub is the first external-tracker dogfooding path:

- GitHub issues project PRD and child work visibility.
- GitHub PRs project SDD/plan review and implementation review.
- LDD updates managed GitHub bodies only after explicit human confirmation and drift checks.
- Linear and Jira remain follow-on optional collaboration surfaces until the GitHub model is proven.

## MVP Workflow

```text
draft PRD ledger
  -> promoted Product Requirement ticket
  -> PRD approval with /ldd:approve
  -> SDD/Plan
  -> child vertical-slice tickets
  -> implementation
  -> verification
  -> human-approved closure/archive
```

The repo-local `ledger.yml` is canonical. `/ldd:refine` commits the final PRD and routes PRD approval to `/ldd:approve <ticket-id>`. In local tracker mode, a promoted stable ticket directory such as `docs/tickets/LDD-0001-short-slug/` is the real ticket. External trackers are synchronized only when configured and approved by the human.

New Product Requirements can be scoped while other promoted tickets are still in progress. `/ldd:scope` creates or updates the local draft ticket directory; incomplete promoted tickets do not block new draft PRDs. Local mode keeps one active draft, so starting another draft first requires continuing, renaming, promoting, or discarding the existing draft.

## Handoff Artifacts

`/ldd:setup` installs templates into a target repository:

```text
.ldd/config.yml
.ldd/templates/ledger.yml
.ldd/templates/prd.md
.ldd/templates/sdd.md
.ldd/templates/plan.md
.ldd/templates/plan.html
.ldd/templates/issue-body-prd.md
.ldd/templates/issue-body-child.md
.ldd/templates/pr-body-prd.md
.ldd/templates/pr-body-sdd-plan.md
.ldd/templates/pr-body-implementation.md
.ldd/templates/verification.md
docs/tickets/_drafts/
docs/tickets/_archive/
```

The templates are quality contracts, not blank forms:

- PRDs keep product scope separate from technical design.
- `/ldd:approve` records explicit human approval for PRD and SDD gates. It does not approve plans, decomposition, closure, or external mutations.
- SDDs translate approved PRDs into designs grounded in code and ADRs.
- Plans trace acceptance criteria to implementation slices and verification.
- Decomposition turns approved plan slices into child vertical-slice tickets.
- Implementation completes child work but does not close it.
- Verification checks child-ticket closure readiness before archive or external close.
- Close applies verified closure, archives child work locally, and can close/archive a parent only when every child is verified and closeable.
- External issue bodies are rich projections of the ledger and artifacts, readable without opening the repo.
- GitHub-first projections use issues for PRD/child work and PRs for SDD/plan/implementation review while keeping the repo-local ledger canonical.
- Child tickets follow LDD's standalone independently-grabbable shape: parent, what to build, acceptance criteria, blockers, user stories covered, and LDD traceability.
- PR bodies focus reviewers on the correct handoff question.

## Validate This Repo

```sh
./scripts/validate-ldd-mvp.sh
```
