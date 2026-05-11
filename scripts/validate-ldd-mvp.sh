#!/usr/bin/env sh
set -eu

commands='setup next scope elaborate refine design plan implement'

required_files='
skills/ldd-setup/assets/templates/config.yml
skills/ldd-setup/assets/templates/prd.md
skills/ldd-setup/assets/templates/sdd.md
skills/ldd-setup/assets/templates/plan.md
skills/ldd-setup/assets/templates/plan.html
skills/ldd-setup/assets/templates/pr-body-prd.md
skills/ldd-setup/assets/templates/pr-body-sdd-plan.md
skills/ldd-setup/assets/templates/pr-body-implementation.md
'

for command in $commands; do
  required_files="$required_files
skills/ldd-$command/SKILL.md
skills/ldd-$command/agents/openai.yaml"
done

for file in $required_files; do
  if [ ! -f "$file" ]; then
    echo "missing required file: $file" >&2
    exit 1
  fi
done

for command in $commands; do
  grep -q "/ldd:$command" "skills/ldd-$command/SKILL.md"
  grep -q 'GitHub is the ledger' "skills/ldd-$command/SKILL.md"
  grep -q 'GitHub mutations require human confirmation' "skills/ldd-$command/SKILL.md"
  grep -q 'display_name: "LDD ' "skills/ldd-$command/agents/openai.yaml"
done

grep -q 'Verify the repo has a GitHub remote' skills/ldd-setup/SKILL.md
grep -q '`.ldd/config.yml`' skills/ldd-setup/SKILL.md
grep -q 'Do not create LDD labels, GitHub Actions' skills/ldd-setup/SKILL.md

grep -q 'Read-only' skills/ldd-next/SKILL.md
grep -q 'It never mutates GitHub' skills/ldd-next/SKILL.md
grep -q 'If issue is closed' skills/ldd-next/SKILL.md

grep -q 'do not read the codebase as a design input' skills/ldd-scope/SKILL.md
grep -q 'do not read the codebase as a design input' skills/ldd-elaborate/SKILL.md
grep -q 'do not read the codebase as a design input' skills/ldd-refine/SKILL.md

grep -q 'docs/tickets' skills/ldd-setup/assets/templates/config.yml
grep -q '# PRD:' skills/ldd-setup/assets/templates/prd.md
grep -q '# Software Design Document:' skills/ldd-setup/assets/templates/sdd.md
grep -q '# Implementation Plan:' skills/ldd-setup/assets/templates/plan.md
grep -q 'Does this implementation follow the approved plan?' skills/ldd-setup/assets/templates/pr-body-implementation.md

echo "LDD MVP installable skills validated"
