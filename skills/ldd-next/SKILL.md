---
name: ldd-next
description: Run /ldd:next for one GitHub issue. Use when the user says /ldd:next, asks for the next LDD command, or wants to diagnose LDD workflow state from GitHub Issues and Pull Requests.
---

# /ldd:next

Read GitHub-native workflow state for one issue and report the next explicit LDD command.

## Input

`/ldd:next <issue-number>`

## Reads

- GitHub issue state
- linked PRs
- PR branch names
- PR titles and bodies
- PR review / merge state
- expected local branches
- expected local artifacts

## Rules

- Read-only. It never mutates GitHub or local files.
- GitHub is the ledger. Local artifacts guide unfinished local work, but they do not override GitHub state.
- GitHub mutations require human confirmation, and this command does not request mutations.
- Use `.ldd/config.yml` when present; otherwise infer repo from the GitHub remote.

## Decision Tree

```text
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
```

## Stop Conditions

- issue number missing or invalid
- issue not found
- GitHub state cannot be read
- more than one PR matches a workflow phase
- a PR references the issue but uses the wrong branch for its phase
- local artifacts imply a later state than GitHub
