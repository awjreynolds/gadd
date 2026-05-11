#!/usr/bin/env sh
set -eu

required_files='
skills/ldd-core/SKILL.md
skills/ldd-core/agents/openai.yaml
skills/ldd-core/assets/claude-commands/ldd/setup.md
skills/ldd-core/assets/claude-commands/ldd/next.md
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
