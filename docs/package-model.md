# GADD Package Model

GADD is published as a normal Agent Skills collection. The primary install path is:

```bash
npx skills add awjreynolds/gadd
```

Use `--list` to inspect the available skills before installing:

```bash
npx skills add awjreynolds/gadd --list
```

Install one skill by name:

```bash
npx skills add awjreynolds/gadd --skill gadd-setup
```

Install all skills without prompts:

```bash
npx skills add awjreynolds/gadd --all -y
```

## Source Layout

The canonical skill source is the `skills/` directory:

```text
skills/gadd-<command>/
  SKILL.md
  agents/openai.yaml
  assets/
```

Examples include `gadd-setup`, `gadd-next`, `gadd-triage`, `gadd-research`, `gadd-design`, and `gadd-implement`.

Each `SKILL.md` is standalone. A GADD command must not require other installed skills such as external Test-Driven Development, issue-generation, planning, triage, or debugging skills. A host agent may provide helpful tools, but every `/gadd:*` command carries its own workflow contract.

## Templates

The portable setup templates live inside the setup skill:

```text
skills/gadd-setup/assets/templates/
```

Those assets are installed with `gadd-setup`. `/gadd:setup` copies them into a target repository as:

```text
gadd/config.yml
gadd/templates/
gadd/work-items/_drafts/
gadd/work-items/_archive/
```

This package does not include repo-root `gadd/` runtime state. `/gadd:setup` generates that state in consumer repositories.

## Compatibility Surfaces

`npx skills` is the front door. The additional adapter files exist only for hosts that still need them:

| Surface | Files | Status |
| --- | --- | --- |
| Agent Skills CLI | `skills/gadd-*` | Primary |
| Codex | `skills/gadd-*`, `agents/openai.yaml` | Supported through Agent Skills |
| Claude Code plugin compatibility | `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `commands/gadd/*.md` | Optional |
| Gemini CLI extension compatibility | `gemini-extension.json`, `GEMINI.md`, `commands/gadd/*.toml` | Optional |

Adapter-specific files point back to the matching skill. They are not a second source of truth.
