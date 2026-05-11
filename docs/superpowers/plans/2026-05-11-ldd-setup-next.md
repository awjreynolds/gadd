# LDD Command-Shaped Skills Implementation Plan

> Supersedes the earlier `ldd-core` packaging plan. The MVP now exposes installable skills that match the user-facing `/ldd:*` command surface.

**Goal:** Build the first installable LDD MVP skill set: one skill per command, with the shared LDD contract duplicated in each command skill instead of hidden in a separate core skill.

**Architecture:** `skills/ldd-<command>/SKILL.md` is the canonical source for each command. Shared rules stay short and local to each skill: GitHub is the ledger, GitHub mutations require human confirmation, and LDD must not create duplicate local workflow state. The setup skill owns the bundled templates copied into target repositories.

**Tech Stack:** Codex/OpenAI installable skills, YAML skill UI metadata, Markdown templates, POSIX shell validation, `git`, `gh`.

## File Structure

- `skills/ldd-setup/SKILL.md`
  - Bootstraps a target repository with `.ldd/config.yml`, `.ldd/templates/`, and `docs/tickets/`.
  - Does not mutate GitHub, create labels, install Actions, or create ADR folders.
- `skills/ldd-next/SKILL.md`
  - Read-only workflow diagnosis for a single GitHub issue.
  - Reads GitHub-native issue and PR state and reports the next LDD command.
- `skills/ldd-scope/SKILL.md`
  - PM-hat PRD scoping.
- `skills/ldd-elaborate/SKILL.md`
  - PM-hat PRD elaboration.
- `skills/ldd-refine/SKILL.md`
  - PM-hat PRD handoff refinement and PRD PR prompt.
- `skills/ldd-design/SKILL.md`
  - SE-hat SDD creation and ADR threshold check.
- `skills/ldd-plan/SKILL.md`
  - Implementation plan and generated `plan.html` from approved design.
- `skills/ldd-implement/SKILL.md`
  - Plan execution with code and tests.
- `skills/ldd-*/agents/openai.yaml`
  - UI metadata for each installable command skill.
- `skills/ldd-setup/assets/templates/*`
  - Setup-owned templates copied into target repositories.
- `scripts/validate-ldd-mvp.sh`
  - Smoke test that validates the installable command skills and setup template set.

## Validation Contract

The validation script must fail if:

- any command skill is missing `SKILL.md`
- any command skill is missing `agents/openai.yaml`
- any command skill omits its `/ldd:<command>` invocation
- any command skill omits the GitHub-ledger invariant
- any command skill omits human confirmation for GitHub mutations
- PM-hat commands can read the codebase as design input
- setup templates are missing or lose their expected headings/prompts

Run:

```sh
./scripts/validate-ldd-mvp.sh
```

Expected output:

```text
LDD MVP installable skills validated
```

## Completion Checklist

- [x] Command-shaped skills exist for setup, next, scope, elaborate, refine, design, plan, and implement.
- [x] Setup skill owns the target-repo templates.
- [x] Shared LDD invariants are present in every command skill.
- [x] `ldd-core` is not a user-facing installable skill.
- [x] Validation checks the command-shaped installable surface.
