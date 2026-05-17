# GADD

This extension provides GADD commands for Gemini CLI. GADD applies the Governed Autonomy philosophy to software delivery by keeping AI execution inside explicit role, scope, evidence, and approval boundaries.

Canonical command instructions live in `skills/gadd-*/SKILL.md`. When a user invokes an `/gadd:*` command, read the matching skill file first and follow it as the source of truth.

GADD's canonical work unit is a Work Item. External issues and tickets are tracker-native collaboration surfaces. Use `/gadd:triage` for unclassified intake, including free-form prompts, and `/gadd:research` or `/gadd:scope` for known PM-led Product Requirement discovery.

GADD invariants:

- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- GitHub, Linear, Jira, or other external mutations require explicit human confirmation.
- Do not create duplicate workflow state with progress logs, audit ledgers, phase labels, or workflow Actions.
- Preserve PM, SE, planning, and implementation handoff boundaries.
- Use `gadd/config.yml` in the target repository when present.

Command mapping:

- `/gadd:setup` -> `skills/gadd-setup/SKILL.md`
- `/gadd:next` -> `skills/gadd-next/SKILL.md`
- `/gadd:triage` -> `skills/gadd-triage/SKILL.md`
- `/gadd:research` -> `skills/gadd-research/SKILL.md`
- `/gadd:scope` -> `skills/gadd-scope/SKILL.md`
- `/gadd:elaborate` -> `skills/gadd-elaborate/SKILL.md`
- `/gadd:refine` -> `skills/gadd-refine/SKILL.md`
- `/gadd:approve` -> `skills/gadd-approve/SKILL.md`
- `/gadd:design` -> `skills/gadd-design/SKILL.md`
- `/gadd:plan` -> `skills/gadd-plan/SKILL.md`
- `/gadd:decompose` -> `skills/gadd-decompose/SKILL.md`
- `/gadd:implement` -> `skills/gadd-implement/SKILL.md`
- `/gadd:verify` -> `skills/gadd-verify/SKILL.md`
- `/gadd:close` -> `skills/gadd-close/SKILL.md`
- `/gadd:archive` -> `skills/gadd-archive/SKILL.md`
