# Ledger-Driven Development Skills

Agent-agnostic skills for the Ledger-Driven Development MVP.

LDD uses a repo-local ledger as canonical workflow state. External trackers such as GitHub, Linear, or Jira are optional sync and review surfaces. LDD separates product scope, engineering design, implementation planning, decomposition, and implementation so AI-assisted work has explicit, reviewable handoffs.

## Package Model

The canonical source is the Agent Skills layout:

```text
skills/<skill-name>/SKILL.md
skills/<skill-name>/assets/
skills/<skill-name>/agents/openai.yaml
```

Adapter manifests make the same skills installable in specific agents:

| Agent | Adapter files |
| --- | --- |
| Codex | `skills/ldd-*`, `agents/openai.yaml`, `ldd-skills.json` |
| Claude Code | `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `skills/ldd-*` |
| Gemini CLI | `gemini-extension.json`, `GEMINI.md`, `commands/ldd/*.toml`, `skills/ldd-*` |

There is no `ldd-core` skill to install. Shared LDD rules are intentionally embedded in each command-shaped skill so every agent sees the same command contract.

## Commands

```text
/ldd:setup
/ldd:next
/ldd:scope
/ldd:elaborate
/ldd:refine
/ldd:design
/ldd:plan
/ldd:decompose
/ldd:implement
```

## Install

### Codex

Use `$skill-installer` from inside Codex and ask it to install all skills from this repository:

```text
Use $skill-installer to install all LDD skills from
https://github.com/awjreynolds/ledger-driven-development:
skills/ldd-setup, skills/ldd-next, skills/ldd-scope,
skills/ldd-elaborate, skills/ldd-refine, skills/ldd-design,
skills/ldd-plan, skills/ldd-decompose, and skills/ldd-implement.
```

Restart Codex after installing.

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

Restart Gemini CLI after installing. The extension provides `commands/ldd/*.toml`, which map to `/ldd:setup`, `/ldd:next`, `/ldd:scope`, `/ldd:elaborate`, `/ldd:refine`, `/ldd:design`, `/ldd:plan`, `/ldd:decompose`, and `/ldd:implement`.

## MVP Workflow

```text
draft PRD ledger
  -> promoted Product Requirement ticket
  -> SDD/Plan
  -> child vertical-slice tickets
  -> implementation
  -> completed children archived
```

The repo-local `ledger.yml` is canonical. External trackers are synchronized only when configured and approved by the human.

## Handoff Artifacts

`/ldd:setup` installs templates into a target repository:

```text
.ldd/config.yml
.ldd/templates/ledger.yml
.ldd/templates/prd.md
.ldd/templates/sdd.md
.ldd/templates/plan.md
.ldd/templates/plan.html
.ldd/templates/pr-body-prd.md
.ldd/templates/pr-body-sdd-plan.md
.ldd/templates/pr-body-implementation.md
docs/tickets/_drafts/
docs/tickets/_archive/
```

The templates are quality contracts, not blank forms:

- PRDs keep product scope separate from technical design.
- SDDs translate approved PRDs into designs grounded in code and ADRs.
- Plans trace acceptance criteria to implementation slices and verification.
- Decomposition turns approved plan slices into child vertical-slice tickets.
- PR bodies focus reviewers on the correct handoff question.

## Validate This Repo

```sh
./scripts/validate-ldd-mvp.sh
```
