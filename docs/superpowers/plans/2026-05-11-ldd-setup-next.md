# LDD Setup/Next Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the first executable LDD MVP slice: `/ldd:setup` and `/ldd:next`, backed by shared LDD rules and template files.

**Architecture:** Claude command markdown files are thin entry points. A shared `ldd-core` skill carries the invariant workflow rules, GitHub ledger contract, command contract matrix, and artifact templates. A small shell validation script checks that the command surface and template set remain complete as the repo evolves.

**Tech Stack:** Claude Code command markdown, Claude skill markdown, POSIX shell, `git`, `gh`.

---

## File Structure

- Create `skills/ldd-core/assets/claude-commands/ldd/setup.md`
  - Slash-command prompt for bootstrapping a target repository.
  - Owns `.ldd/config.yml`, `docs/tickets/`, and local template creation in the target repo.
- Create `skills/ldd-core/assets/claude-commands/ldd/next.md`
  - Slash-command prompt for read-only workflow diagnosis for a single GitHub issue.
  - Reads GitHub-native state with `gh`; never writes files or mutates GitHub.
- Create `skills/ldd-core/SKILL.md`
  - Shared LDD principles used by both commands.
  - Contains the command contract, human-control rules, artifact paths, branch naming, and PR title/body conventions.
- Create `skills/ldd-core/agents/openai.yaml`
  - UI metadata for the installable skill.
- Create `skills/ldd-core/assets/templates/config.yml`
  - Default `.ldd/config.yml` template written by `/ldd:setup`.
- Create `skills/ldd-core/assets/templates/prd.md`
  - Default PRD artifact template.
- Create `skills/ldd-core/assets/templates/sdd.md`
  - Default SDD artifact template.
- Create `skills/ldd-core/assets/templates/plan.md`
  - Default implementation plan artifact template.
- Create `skills/ldd-core/assets/templates/plan.html`
  - Minimal generated-plan HTML template for the setup slice.
- Create `skills/ldd-core/assets/templates/pr-body-prd.md`
  - PRD PR body template.
- Create `skills/ldd-core/assets/templates/pr-body-sdd-plan.md`
  - SDD/Plan PR body template.
- Create `skills/ldd-core/assets/templates/pr-body-implementation.md`
  - Implementation PR body template.
- Create `scripts/validate-ldd-mvp.sh`
  - Repo-local smoke test that validates the command and template files exist and contain required contract language.

## Task 1: Add the validation harness first

**Files:**
- Create: `scripts/validate-ldd-mvp.sh`

- [ ] **Step 1: Write the failing validation script**

Create `scripts/validate-ldd-mvp.sh` with:

```sh
#!/usr/bin/env sh
set -eu

required_files='
skills/ldd-core/assets/claude-commands/ldd/setup.md
skills/ldd-core/assets/claude-commands/ldd/next.md
skills/ldd-core/SKILL.md
skills/ldd-core/agents/openai.yaml
skills/ldd-core/assets/templates/config.yml
skills/ldd-core/assets/templates/prd.md
skills/ldd-core/assets/templates/sdd.md
skills/ldd-core/assets/templates/plan.md
skills/ldd-core/assets/templates/plan.html
skills/ldd-core/assets/templates/pr-body-prd.md
skills/ldd-core/assets/templates/pr-body-sdd-plan.md
skills/ldd-core/assets/templates/pr-body-implementation.md
'

for file in $required_files; do
  if [ ! -f "$file" ]; then
    echo "missing required file: $file" >&2
    exit 1
  fi
done

grep -q 'GitHub is the ledger' skills/ldd-core/SKILL.md
grep -q 'GitHub mutations require human confirmation' skills/ldd-core/SKILL.md
grep -q 'must not read the codebase as a design input' skills/ldd-core/SKILL.md
grep -q 'display_name: "LDD Core"' skills/ldd-core/agents/openai.yaml

grep -q 'verify the repo has a GitHub remote' skills/ldd-core/assets/claude-commands/ldd/setup.md
grep -q 'create `.ldd/config.yml`' skills/ldd-core/assets/claude-commands/ldd/setup.md
grep -q 'It should not create labels or GitHub Actions' skills/ldd-core/assets/claude-commands/ldd/setup.md

grep -q 'Read-only diagnostic command' skills/ldd-core/assets/claude-commands/ldd/next.md
grep -q 'It never mutates GitHub' skills/ldd-core/assets/claude-commands/ldd/next.md
grep -q 'If issue is closed' skills/ldd-core/assets/claude-commands/ldd/next.md

grep -q 'docs/tickets' skills/ldd-core/assets/templates/config.yml
grep -q '# PRD:' skills/ldd-core/assets/templates/prd.md
grep -q '# Software Design Document:' skills/ldd-core/assets/templates/sdd.md
grep -q '# Implementation Plan:' skills/ldd-core/assets/templates/plan.md
grep -q 'Does this implementation follow the approved plan?' skills/ldd-core/assets/templates/pr-body-implementation.md

echo "LDD MVP command surface validated"
```

- [ ] **Step 2: Make the script executable**

Run:

```bash
chmod +x scripts/validate-ldd-mvp.sh
```

- [ ] **Step 3: Run the validation script and confirm it fails**

Run:

```bash
./scripts/validate-ldd-mvp.sh
```

Expected: fail with:

```text
missing required file: skills/ldd-core/assets/claude-commands/ldd/setup.md
```

- [ ] **Step 4: Commit**

```bash
git add scripts/validate-ldd-mvp.sh
git commit -m "test: add LDD MVP command validation"
```

## Task 2: Add shared LDD core rules

**Files:**
- Create: `skills/ldd-core/SKILL.md`

- [ ] **Step 1: Create the skill file**

Create `skills/ldd-core/SKILL.md` with:

```markdown
---
name: ldd-core
description: Shared Ledger-Driven Development MVP rules for /ldd commands. Use whenever executing an /ldd:* command.
---

# Ledger-Driven Development Core Rules

GitHub is the ledger. LDD reads workflow state from GitHub Issues and Pull Requests, not from local progress logs, labels, generated audit files, or agent-session state.

## MVP Command Surface

- `/ldd:setup`
- `/ldd:next`
- `/ldd:scope`
- `/ldd:elaborate`
- `/ldd:refine`
- `/ldd:design`
- `/ldd:plan`
- `/ldd:implement`

## Human Control

LDD commands may make local repo changes when explicitly invoked:

- create or switch to the matching `ldd/...` branch for the active issue and phase
- edit artifacts
- generate `plan.html`
- create local commits

GitHub mutations require human confirmation:

- pushing a branch
- opening or updating a PR
- commenting on an issue or PR
- requesting reviewers
- closing an issue

## Requirements / Code Influence Boundary

PM-hat commands (`/ldd:scope`, `/ldd:elaborate`, `/ldd:refine`) must not read the codebase as a design input. If code knowledge appears during PM work, capture it only as a dependency, constraint, or open question.

SE-hat commands (`/ldd:design`, `/ldd:plan`) may use the existing codebase. `/ldd:design` reads the merged PRD, relevant code, and ADRs. `/ldd:plan` reads the PRD, SDD, and ADRs and must not introduce new architecture decisions.

## Paths

- PRD: `docs/tickets/{issue}/prd.md`
- SDD: `docs/tickets/{issue}/sdd.md`
- Plan: `docs/tickets/{issue}/plan.md`
- Plan HTML: `docs/tickets/{issue}/plan.html`

## Branches

- PRD: `ldd/prd/{issue}`
- SDD/Plan: `ldd/sdd-plan/{issue}`
- Implementation: `ldd/impl/{issue}`

## Pull Requests

- PRD title: `PRD: {title}`
- SDD/Plan title: `SDD + Plan: {title}`
- Implementation title: `{title}`
- PRD and SDD/Plan bodies use `references #{issue}`
- Implementation body uses `Closes #{issue}`

## Forbidden In MVP

- LDD-specific phase labels, gate labels, PR labels, or issue-state labels
- generated `progress.md`
- generated audit event files
- automatic GitHub Actions for workflow state transitions
- backend abstraction beyond GitHub
```

- [ ] **Step 2: Run validation and confirm the next missing file**

Run:

```bash
./scripts/validate-ldd-mvp.sh
```

Expected: fail with:

```text
missing required file: skills/ldd-core/assets/claude-commands/ldd/setup.md
```

- [ ] **Step 3: Commit**

```bash
git add skills/ldd-core/SKILL.md
git commit -m "feat: add shared LDD core rules"
```

## Task 3: Add setup templates

**Files:**
- Create: `skills/ldd-core/assets/templates/config.yml`
- Create: `skills/ldd-core/assets/templates/prd.md`
- Create: `skills/ldd-core/assets/templates/sdd.md`
- Create: `skills/ldd-core/assets/templates/plan.md`
- Create: `skills/ldd-core/assets/templates/plan.html`
- Create: `skills/ldd-core/assets/templates/pr-body-prd.md`
- Create: `skills/ldd-core/assets/templates/pr-body-sdd-plan.md`
- Create: `skills/ldd-core/assets/templates/pr-body-implementation.md`

- [ ] **Step 1: Add `config.yml` template**

Create `skills/ldd-core/assets/templates/config.yml` with:

```yaml
github:
  repo: "{repo}"
  default_branch: "{default_branch}"

artifacts:
  root: docs/tickets

branches:
  prd: ldd/prd/{issue}
  sdd_plan: ldd/sdd-plan/{issue}
  implementation: ldd/impl/{issue}

prs:
  prd_title: "PRD: {title}"
  sdd_plan_title: "SDD + Plan: {title}"
  implementation_title: "{title}"

renderer:
  plan_html: true

adr:
  directory: docs/adr
  update_policy: immutable_superseded
  filename_style: dated_slug
```

- [ ] **Step 2: Add artifact templates**

Create `skills/ldd-core/assets/templates/prd.md` with:

```markdown
---
issue: {issue}
title: "{title}"
created: {date}
updated: {date}
---

# PRD: {title}

## Problem

## Goals

## Non-goals

## Users / Personas

## User Stories

## Acceptance Criteria

## Success Metrics

## Dependencies

## Open Questions
```

Create `skills/ldd-core/assets/templates/sdd.md` with:

```markdown
---
issue: {issue}
prd: docs/tickets/{issue}/prd.md
created: {date}
updated: {date}
adrs: []
---

# Software Design Document: {title}

## Context

## Constraints

## Existing System

## Decision Summary

## Alternatives Considered

## Proposed Design

## Data Flow / Control Flow

## Interfaces / Contracts

## Migration / Compatibility

## Observability

## Security / Privacy

## ADRs

## Open Design Questions
```

Create `skills/ldd-core/assets/templates/plan.md` with:

```markdown
---
issue: {issue}
prd: docs/tickets/{issue}/prd.md
sdd: docs/tickets/{issue}/sdd.md
created: {date}
updated: {date}
plan_html: docs/tickets/{issue}/plan.html
adrs: []
---

# Implementation Plan: {title}

## Review Context

### PRD Summary

### SDD Summary

### ADR Summary

## Slices

## Acceptance Criteria Traceability

## Files / Modules

## Test Strategy

## Review Checklist
```

Create `skills/ldd-core/assets/templates/plan.html` with:

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Implementation Plan: {title}</title>
</head>
<body>
  <main>
    <h1>Implementation Plan: {title}</h1>
    <p>This file is generated from <code>plan.md</code>.</p>
    {rendered_plan}
  </main>
</body>
</html>
```

- [ ] **Step 3: Add PR body templates**

Create `skills/ldd-core/assets/templates/pr-body-prd.md` with:

```markdown
## Issue

References #{issue}

## PRD

`docs/tickets/{issue}/prd.md`

## Goals / Non-goals Summary

{summary}

## Reviewer Prompt

Is this ready for engineering design?
```

Create `skills/ldd-core/assets/templates/pr-body-sdd-plan.md` with:

```markdown
## Issue

References #{issue}

## Review Package

- PRD: `docs/tickets/{issue}/prd.md`
- SDD: `docs/tickets/{issue}/sdd.md`
- Plan: `docs/tickets/{issue}/plan.md`
- Plan HTML: `docs/tickets/{issue}/plan.html`

## ADRs

{adr_links}

## Reviewer Prompt

Does this design and plan correctly implement the PRD?
```

Create `skills/ldd-core/assets/templates/pr-body-implementation.md` with:

```markdown
## Issue

Closes #{issue}

## Approved Artifacts

- PRD: `docs/tickets/{issue}/prd.md`
- SDD: `docs/tickets/{issue}/sdd.md`
- Plan: `docs/tickets/{issue}/plan.md`
- Plan HTML: `docs/tickets/{issue}/plan.html`

## ADRs

{adr_links}

## Test / Check Summary

{test_summary}

## Reviewer Prompt

Does this implementation follow the approved plan?
```

- [ ] **Step 4: Run validation and confirm command files are still missing**

Run:

```bash
./scripts/validate-ldd-mvp.sh
```

Expected: fail with:

```text
missing required file: skills/ldd-core/assets/claude-commands/ldd/setup.md
```

- [ ] **Step 5: Commit**

```bash
git add skills/ldd-core/assets/templates
git commit -m "feat: add LDD setup templates"
```

## Task 4: Add `/ldd:setup`

**Files:**
- Create: `skills/ldd-core/assets/claude-commands/ldd/setup.md`

- [ ] **Step 1: Create setup command**

Create `skills/ldd-core/assets/claude-commands/ldd/setup.md` with:

```markdown
---
description: Bootstrap the repository for the Ledger-Driven Development MVP workflow
allowed-tools: Read, Write, Glob, Grep, Bash
argument-hint: ""
---

# /ldd:setup

Use the `ldd-core` skill before executing this command.

Bootstraps the current repository for the MVP workflow.

## Contract

- verify the repo has a GitHub remote
- infer the GitHub repository and default branch
- verify `gh` is installed and authenticated
- create `docs/tickets/`
- create `.ldd/config.yml`
- create local templates for `prd.md`, `sdd.md`, `plan.md`, `plan.html`, and PR bodies
- create or confirm the ADR directory configured in `.ldd/config.yml` only when the first ADR is needed

It should not create labels or GitHub Actions in the MVP.

## Procedure

1. Run `git remote -v` and identify the GitHub origin remote.
2. Run `gh auth status` and stop if authentication is unavailable.
3. Run `gh repo view --json nameWithOwner,defaultBranchRef` and use the result for `.ldd/config.yml`.
4. Create `docs/tickets/` if missing.
5. Create `.ldd/templates/` if missing.
6. Write `.ldd/config.yml` from `skills/ldd-core/assets/templates/config.yml`.
7. Copy the artifact and PR body templates into `.ldd/templates/`.
8. Summarize changed files.
9. Create a local commit only after showing the diff summary to the human and receiving approval.

## Stop Conditions

- no GitHub remote
- multiple plausible GitHub remotes and no clear origin
- `gh` is unavailable
- `gh` is unauthenticated
- default branch cannot be inferred
- `.ldd/config.yml` exists with conflicting settings; show the diff and ask how to proceed

## Human Control

Do not push. Do not create labels. Do not create GitHub Actions. Do not mutate GitHub.
```

- [ ] **Step 2: Run validation and confirm only `/ldd:next` is missing**

Run:

```bash
./scripts/validate-ldd-mvp.sh
```

Expected: fail with:

```text
missing required file: skills/ldd-core/assets/claude-commands/ldd/next.md
```

- [ ] **Step 3: Commit**

```bash
git add skills/ldd-core/assets/claude-commands/ldd/setup.md
git commit -m "feat: add ldd setup command"
```

## Task 5: Add `/ldd:next`

**Files:**
- Create: `skills/ldd-core/assets/claude-commands/ldd/next.md`

- [ ] **Step 1: Create next command**

Create `skills/ldd-core/assets/claude-commands/ldd/next.md` with:

````markdown
---
description: Diagnose the Ledger-Driven Development workflow state for one GitHub issue
allowed-tools: Read, Glob, Grep, Bash
argument-hint: <issue-number>
---

# /ldd:next

Use the `ldd-core` skill before executing this command.

Read-only diagnostic command.

Input:

```text
/ldd:next <issue-number>
```

## Reads

- GitHub issue state
- linked PRs
- PR branch names
- PR titles and bodies
- PR review / merge state
- expected local branches
- expected local artifacts

It never mutates GitHub.

## Procedure

1. Validate that `$ARGUMENTS` is a single issue number.
2. Read `.ldd/config.yml` if present; otherwise use the GitHub origin remote.
3. Run `gh issue view <issue> --json number,title,state,body,url,closed,closedAt`.
4. Run `gh pr list --state all --search "<issue>" --json number,title,state,isDraft,headRefName,baseRefName,body,url,reviewDecision,mergeStateStatus,mergedAt,closedAt`.
5. Classify PRs by expected branch first, then title/body issue reference:
   - `ldd/prd/<issue>`
   - `ldd/sdd-plan/<issue>`
   - `ldd/impl/<issue>`
6. Check local branches with `git branch --list`.
7. Check local artifacts under `docs/tickets/<issue>/`.
8. Report the current workflow state, next explicit command, and inconsistencies.

## Decision Tree

If issue is closed:
  done

Else if Implementation PR exists:
  inspect Implementation PR state

Else if SDD/Plan PR is merged:
  next: /ldd:implement

Else if SDD/Plan PR exists:
  inspect SDD/Plan PR state

Else if PRD PR is merged:
  next: /ldd:design

Else if PRD PR exists:
  inspect PRD PR state

Else if ldd/prd/<issue> branch exists:
  inspect prd.md completeness and recommend /ldd:scope, /ldd:elaborate, or /ldd:refine

Else:
  next: /ldd:scope

## Stop Conditions

- issue number is missing or invalid
- issue is not found
- GitHub state cannot be read
- more than one PR matches a workflow phase
- a PR references the issue but uses the wrong branch for its phase
- local artifacts imply a later state than GitHub
````

- [ ] **Step 2: Run validation and confirm it passes**

Run:

```bash
./scripts/validate-ldd-mvp.sh
```

Expected:

```text
LDD MVP command surface validated
```

- [ ] **Step 3: Commit**

```bash
git add skills/ldd-core/assets/claude-commands/ldd/next.md
git commit -m "feat: add ldd next command"
```

## Task 6: Final smoke review

**Files:**
- Read: `docs/superpowers/specs/2026-05-11-ledger-driven-development-design.md`
- Read: `skills/ldd-core/assets/claude-commands/ldd/setup.md`
- Read: `skills/ldd-core/assets/claude-commands/ldd/next.md`
- Read: `skills/ldd-core/SKILL.md`
- Run: `scripts/validate-ldd-mvp.sh`

- [ ] **Step 1: Run validation**

Run:

```bash
./scripts/validate-ldd-mvp.sh
```

Expected:

```text
LDD MVP command surface validated
```

- [ ] **Step 2: Check command docs against the design spec**

Run:

```bash
grep -n "Command Contract Matrix" docs/superpowers/specs/2026-05-11-ledger-driven-development-design.md
grep -n "Requirements / Code Influence Boundary" docs/superpowers/specs/2026-05-11-ledger-driven-development-design.md
grep -n "It never mutates GitHub" skills/ldd-core/assets/claude-commands/ldd/next.md
grep -n "It should not create labels or GitHub Actions" skills/ldd-core/assets/claude-commands/ldd/setup.md
```

Expected: each command prints one matching line.

- [ ] **Step 3: Commit final plan bookkeeping if needed**

If the plan file is not yet committed:

```bash
git add docs/superpowers/plans/2026-05-11-ldd-setup-next.md
git commit -m "docs: add LDD setup next implementation plan"
```

## Coverage Checklist

- `/ldd:setup` has explicit inputs, writes, stop conditions, and no GitHub mutation.
- `/ldd:next` is read-only and follows the MVP decision tree.
- The shared skill preserves the GitHub ledger model and PM/code influence boundary.
- The canonical source is an installable `skills/ldd-core` folder, not an adapter-specific `.claude` folder.
- Skill UI metadata exists at `skills/ldd-core/agents/openai.yaml`.
- Templates cover config, PRD, SDD, plan, plan HTML, and all three PR body types.
- Validation catches missing command/template files and missing critical contract language.
