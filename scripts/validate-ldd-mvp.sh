#!/usr/bin/env sh
set -eu

commands='setup next scope elaborate refine design plan decompose implement'

required_files='
agent-skills.json
README.md
CONTEXT.md
docs/superpowers/specs/2026-05-12-local-ledger-mvp-design.md
.claude-plugin/plugin.json
.claude-plugin/marketplace.json
gemini-extension.json
GEMINI.md
skills/ldd-setup/assets/templates/config.yml
skills/ldd-setup/assets/templates/ledger.yml
skills/ldd-setup/assets/templates/prd.md
skills/ldd-setup/assets/templates/sdd.md
skills/ldd-setup/assets/templates/plan.md
skills/ldd-setup/assets/templates/plan.html
skills/ldd-setup/assets/templates/issue-body-prd.md
skills/ldd-setup/assets/templates/issue-body-child.md
skills/ldd-setup/assets/templates/pr-body-prd.md
skills/ldd-setup/assets/templates/pr-body-sdd-plan.md
skills/ldd-setup/assets/templates/pr-body-implementation.md
'

for command in $commands; do
  required_files="$required_files
commands/ldd/$command.md
commands/ldd/$command.toml
skills/ldd-$command/SKILL.md
skills/ldd-$command/agents/openai.yaml"
done

for file in $required_files; do
  if [ ! -f "$file" ]; then
    echo "missing required file: $file" >&2
    exit 1
  fi
done

for json_file in agent-skills.json .claude-plugin/plugin.json .claude-plugin/marketplace.json gemini-extension.json; do
  python3 -m json.tool "$json_file" >/dev/null
done

if [ -f ldd-skills.json ]; then
  echo "ldd-skills.json must not exist; use agent-skills.json" >&2
  exit 1
fi

grep -q '"canonicalSkillRoot": "skills"' agent-skills.json
grep -q '"command": "/ldd:setup"' agent-skills.json
grep -q '"command": "/ldd:decompose"' agent-skills.json
grep -q '"command": "/ldd:implement"' agent-skills.json
grep -q '"pluginManifest": ".claude-plugin/plugin.json"' agent-skills.json
grep -q '"extensionManifest": "gemini-extension.json"' agent-skills.json
grep -q 'agent-skills.json' README.md
grep -q 'Installed Codex skills are local copies' README.md
grep -q 'Package Source Of Truth' docs/superpowers/specs/2026-05-12-local-ledger-mvp-design.md
grep -q 'A repo-local, machine-readable record' CONTEXT.md
grep -q 'Ticket Promotion' CONTEXT.md
grep -q 'Vertical Slice' CONTEXT.md
grep -q 'Agent Skills Manifest' CONTEXT.md

grep -q '"name": "ldd"' .claude-plugin/plugin.json
grep -q '"commands":' .claude-plugin/plugin.json
grep -q './commands/ldd/setup.md' .claude-plugin/plugin.json
grep -q './commands/ldd/decompose.md' .claude-plugin/plugin.json
grep -q './commands/ldd/implement.md' .claude-plugin/plugin.json
grep -q '"name": "ledger-driven-development"' .claude-plugin/marketplace.json
grep -q '"name": "ldd"' .claude-plugin/marketplace.json
grep -q '"source": "./"' .claude-plugin/marketplace.json

grep -q '"name": "ledger-driven-development"' gemini-extension.json
grep -q '"contextFileName": "GEMINI.md"' gemini-extension.json
grep -q 'Repo-local ledger is canonical' GEMINI.md

for command in $commands; do
  grep -q "/ldd:$command" "skills/ldd-$command/SKILL.md"
  grep -q 'Repo-local ledger is canonical' "skills/ldd-$command/SKILL.md"
  grep -q 'External mutations require human confirmation' "skills/ldd-$command/SKILL.md"
  grep -q 'display_name: "LDD ' "skills/ldd-$command/agents/openai.yaml"
  grep -q "ldd-$command" "commands/ldd/$command.md"
  grep -q 'canonical' "commands/ldd/$command.md"
  grep -q "description =" "commands/ldd/$command.toml"
  grep -q "prompt =" "commands/ldd/$command.toml"
  grep -q "/ldd:$command" "commands/ldd/$command.toml"
  grep -q "ldd-$command" "commands/ldd/$command.toml"
  grep -q 'Agent Skill' "commands/ldd/$command.toml"
  grep -q 'canonical' "commands/ldd/$command.toml"
done

grep -q '`.ldd/config.yml`' skills/ldd-setup/SKILL.md
grep -q 'docs/tickets/_drafts/' skills/ldd-setup/SKILL.md
grep -q 'docs/tickets/_archive/' skills/ldd-setup/SKILL.md

grep -q 'Read-only' skills/ldd-next/SKILL.md
grep -q 'It never mutates GitHub or local files' skills/ldd-next/SKILL.md
grep -q 'next: /ldd:decompose' skills/ldd-next/SKILL.md

grep -q 'do not read the codebase as a design input' skills/ldd-scope/SKILL.md
grep -q 'do not read the codebase as a design input' skills/ldd-elaborate/SKILL.md
grep -q 'do not read the codebase as a design input' skills/ldd-refine/SKILL.md

grep -q 'draft_directory: docs/tickets/_drafts' skills/ldd-setup/assets/templates/config.yml
grep -q 'archive_directory: docs/tickets/_archive' skills/ldd-setup/assets/templates/config.yml
grep -q 'schema_version: 1' skills/ldd-setup/assets/templates/ledger.yml
grep -q 'children: \[\]' skills/ldd-setup/assets/templates/ledger.yml
grep -q 'external_body_hash:' skills/ldd-setup/assets/templates/ledger.yml
grep -q 'managed_body_version:' skills/ldd-setup/assets/templates/ledger.yml
grep -q '# PRD:' skills/ldd-setup/assets/templates/prd.md
grep -q 'PM-hat artifact' skills/ldd-setup/assets/templates/prd.md
grep -q 'PRD Handoff Checklist' skills/ldd-setup/assets/templates/prd.md
grep -q 'No implementation decisions' skills/ldd-setup/assets/templates/prd.md
grep -q 'Avoid: Gherkin/Cucumber syntax here' skills/ldd-setup/assets/templates/prd.md
grep -q 'Given/When/Then' skills/ldd-setup/assets/templates/prd.md
grep -q '# Software Design Document:' skills/ldd-setup/assets/templates/sdd.md
grep -q 'Quality bar:' skills/ldd-setup/assets/templates/sdd.md
grep -q 'ADR threshold:' skills/ldd-setup/assets/templates/sdd.md
grep -q 'Review Checklist' skills/ldd-setup/assets/templates/sdd.md
grep -q '# Implementation Plan:' skills/ldd-setup/assets/templates/plan.md
grep -q 'Acceptance Criteria Traceability' skills/ldd-setup/assets/templates/plan.md
grep -q 'Slice quality bar:' skills/ldd-setup/assets/templates/plan.md
grep -q 'must not introduce new architecture decisions' skills/ldd-setup/assets/templates/plan.md
grep -q '## Problem Statement' skills/ldd-setup/assets/templates/issue-body-prd.md
grep -q '## LDD Links' skills/ldd-setup/assets/templates/issue-body-prd.md
grep -q '## What to build' skills/ldd-setup/assets/templates/issue-body-child.md
grep -q '## Acceptance criteria' skills/ldd-setup/assets/templates/issue-body-child.md
grep -q '## Blocked by' skills/ldd-setup/assets/templates/issue-body-child.md
grep -q '## User stories covered' skills/ldd-setup/assets/templates/issue-body-child.md
grep -q 'Decompose only from an approved plan' skills/ldd-decompose/SKILL.md
grep -q 'vertical slices' skills/ldd-decompose/SKILL.md
grep -q 'Preview Before Creation' skills/ldd-decompose/SKILL.md
grep -q 'independently grabbable' skills/ldd-decompose/SKILL.md
grep -q 'Pocock `to-issues` shape' skills/ldd-decompose/SKILL.md
grep -q 'external contribution' skills/ldd-decompose/SKILL.md
grep -q 'PM Boundary' skills/ldd-setup/assets/templates/pr-body-prd.md
grep -q 'Handoff Checklist' skills/ldd-setup/assets/templates/pr-body-prd.md
grep -q 'Traceability Checks' skills/ldd-setup/assets/templates/pr-body-sdd-plan.md
grep -q 'Does this implementation follow the approved plan?' skills/ldd-setup/assets/templates/pr-body-implementation.md
grep -q 'Plan Conformance' skills/ldd-setup/assets/templates/pr-body-implementation.md
grep -q 'Treat <code>plan.md</code> as the source of truth' skills/ldd-setup/assets/templates/plan.html

grep -q 'artifact quality guidance' skills/ldd-setup/SKILL.md
grep -q 'PRD template as a quality contract' skills/ldd-scope/SKILL.md
grep -q "SDD template's quality bar" skills/ldd-design/SKILL.md
grep -q "plan template's traceability" skills/ldd-plan/SKILL.md
grep -q 'repo-local ledger as canonical workflow state' docs/superpowers/specs/2026-05-12-local-ledger-mvp-design.md

echo "LDD MVP installable skills validated"
