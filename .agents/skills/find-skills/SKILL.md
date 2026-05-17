---
name: find-skills
description: >-
  Use when the user explicitly asks to find, compare, recommend, install,
  update, or check availability of installable agent skills. Also use when the
  user asks whether a reusable skill exists for a domain or workflow. Not for
  ordinary coding help, direct task execution, repo-local GADD commands, or
  plugin/connector installation.
allowed-tools: Bash WebFetch WebSearch
---

# Find Skills

## Purpose

Help users discover installable agent skills and make a safe, evidence-based
decision about whether to install one.

## Essential Principles

1. **Discovery is explicit.** Only use this skill when the user is asking about
   reusable skills, skill packages, or extending agent capabilities.
2. **Current evidence wins.** Treat install counts, package names, URLs, and
   repository reputation as time-sensitive. Verify them before reporting.
3. **No silent installs.** Installing third-party skill code requires explicit
   user approval for the exact package and scope.
4. **Recommend fewer, better options.** Prefer one to three relevant skills with
   clear tradeoffs over a long, weak list.

## When to Use

- The user asks "find a skill for X", "is there a skill for X", or similar.
- The user wants to compare installable agent skills for a specific workflow.
- The user asks to install, update, or check availability of an agent skill.
- The user asks how to extend the agent with reusable domain capabilities.
- The user asks for skills, templates, workflows, or packages from the agent
  skills ecosystem.

## When NOT to Use

- The user asks for ordinary coding, writing, research, or debugging help. Do
  the task directly instead.
- The user invokes a repo-local `/gadd:*` command or asks about this repository's
  built-in GADD workflow. Use the matching repo skill or command documentation.
- The user asks to install a Codex plugin, ChatGPT connector, MCP server, or
  editor extension. Use the host's plugin or connector workflow instead.
- The user names an already-installed skill for the current task. Load and use
  that skill directly.
- The request is only "can you do X?" and no reusable skill discovery intent is
  present. Answer based on available capabilities.

## Workflow

### Phase 1: Confirm Skill-Discovery Intent

**Entry:** The user request might involve finding or installing reusable skills.

**Actions:**

1. Identify the requested domain, workflow, or capability.
2. Decide whether the user is asking for an installable skill or just asking the
   agent to perform a task.
3. If the intent is ambiguous, ask one short clarifying question before searching.

**Exit:** The request is confirmed as skill discovery, comparison, update, or
installation.

### Phase 2: Search Current Sources

**Entry:** Phase 1 confirmed skill-discovery intent.

**Actions:**

1. Search the current skill ecosystem source, such as `https://skills.sh/`, for
   the user's domain or workflow.
2. If a CLI search is appropriate and available, use:

   ```bash
   npx skills find <query>
   ```

3. Use precise search terms first, then one synonym pass if results are weak.
4. Record the package name, skill name, source repository, description, install
   command, and URL for each plausible candidate.

**Exit:** You have a small candidate set or confirmed that no relevant candidate
was found.

### Phase 3: Verify Candidate Quality

**Entry:** Phase 2 found one or more candidate skills.

**Actions:**

1. Verify that each candidate's package name and install command still exist.
2. Check the source repository or publisher reputation when available.
3. Prefer official, well-maintained, or widely used sources, but do not reject a
   niche skill solely because it is new.
4. Look for signs of risk: stale repository, missing documentation, unclear
   ownership, broad tool permissions, or unreviewed install scripts.
5. Drop candidates whose identity, source, or install instructions cannot be
   verified.

**Exit:** Each recommended candidate has current evidence and an identified risk
profile.

### Phase 4: Present Recommendation

**Entry:** Phase 3 produced verified candidates, or no candidates survived.

**Actions:**

1. Present one to three options, ordered by fit.
2. For each option, include:
   - Skill/package name
   - What it is useful for
   - Source or publisher
   - Current evidence checked
   - Install command
   - Notable risks or limitations
3. If no skill is found, say so directly and offer to help with the task using
   current capabilities.

**Exit:** The user can make an informed decision without needing hidden context.

### Phase 5: Install Gate

**Entry:** The user asks to install a specific skill or accepts a recommendation.

**Actions:**

1. Restate the exact package, source, install scope, and command.
2. Ask for explicit approval before running an install command.
3. Default to the least broad install scope supported by the CLI. Use global
   install only when the user asks for global availability or the CLI requires it.
4. Do not skip CLI confirmations with `-y` unless the user explicitly approves
   unattended installation.
5. After approval, install with the command appropriate to the selected package,
   for example:

   ```bash
   npx skills add <owner/repo@skill>
   ```

**Exit:** Either installation was not performed, or the user explicitly approved
and the install command completed or failed with reported output.

### Phase 6: Validate and Report

**Entry:** Recommendation or installation work is complete.

**Actions:**

1. Confirm whether the skill was recommended, installed, updated, or not found.
2. If installed or updated, run the relevant check command when available:

   ```bash
   npx skills check
   ```

3. Report any command failure, network limitation, or source uncertainty.
4. Keep the final answer concise and include the next useful command only if the
   user needs to run it manually.

**Exit:** The user knows the outcome, evidence, and any remaining limitation.

## Quick Reference

| Need | Action |
| --- | --- |
| Search by keyword | `npx skills find <query>` |
| Install selected skill | `npx skills add <owner/repo@skill>` |
| Check updates | `npx skills check` |
| Update installed skills | `npx skills update` |
| Browse ecosystem | `https://skills.sh/` |

## Search Examples

| User need | First query |
| --- | --- |
| React performance help | `react performance` |
| Pull request review workflow | `pr review` |
| Changelog generation | `changelog` |
| Browser automation | `browser automation` |
| Accessibility review | `accessibility audit` |

## Success Criteria

- The skill only activates for explicit skill-discovery or skill-installation
  intent.
- Current sources were checked before reporting volatile metadata.
- Recommendations include package identity, source, install command, and risk.
- No install or update command ran without explicit user approval.
- If no skill fits, the response says so and offers a direct fallback path.
