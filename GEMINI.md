# Ledger-Driven Development

This extension provides Ledger-Driven Development commands for Gemini CLI.

Canonical command instructions live in `skills/ldd-*/SKILL.md`. When a user invokes an `/ldd:*` command, read the matching skill file first and follow it as the source of truth.

LDD invariants:

- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- GitHub, Linear, Jira, or other external mutations require explicit human confirmation.
- Do not create duplicate workflow state with progress logs, audit ledgers, phase labels, or workflow Actions.
- Preserve PM, SE, planning, and implementation handoff boundaries.
- Use `.ldd/config.yml` in the target repository when present.

Command mapping:

- `/ldd:setup` -> `skills/ldd-setup/SKILL.md`
- `/ldd:next` -> `skills/ldd-next/SKILL.md`
- `/ldd:research` -> `skills/ldd-research/SKILL.md`
- `/ldd:scope` -> `skills/ldd-scope/SKILL.md`
- `/ldd:elaborate` -> `skills/ldd-elaborate/SKILL.md`
- `/ldd:refine` -> `skills/ldd-refine/SKILL.md`
- `/ldd:approve` -> `skills/ldd-approve/SKILL.md`
- `/ldd:design` -> `skills/ldd-design/SKILL.md`
- `/ldd:plan` -> `skills/ldd-plan/SKILL.md`
- `/ldd:decompose` -> `skills/ldd-decompose/SKILL.md`
- `/ldd:implement` -> `skills/ldd-implement/SKILL.md`
- `/ldd:verify` -> `skills/ldd-verify/SKILL.md`
- `/ldd:close` -> `skills/ldd-close/SKILL.md`
- `/ldd:archive` -> `skills/ldd-archive/SKILL.md`
