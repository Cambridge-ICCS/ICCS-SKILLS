# Writing Skills — A Crash Course

This guide covers how to write skills for this repository. Each skill is a Markdown file (`SKILL.md`) that an AI coding assistant uses to reliably perform domain-specific tasks.

## SKILL.md Structure

A skill has two parts: **YAML frontmatter** and **Markdown content**.

### 1. YAML Frontmatter (required)

Must be at the very top of the file, enclosed in `---` delimiters:

```yaml
---
name: skill-name
description: One-line description of what this skill does.
---
```

| Field | Requirement | Description |
|-------|-------------|-------------|
| `name` | **Required** | Unique identifier, lowercase with hyphens (`snake-case`) |
| `description` | **Required** | One-line summary. Used for discovery. No trailing period. |

Additional fields are welcome: `author`, `version`, `tags`, `source-repo`, `created`. They are optional and up to the author's discretion.

### 2. Markdown Content

Organize your content so an AI assistant can perform tasks confidently. A complete skill typically covers:

| Section | Purpose |
|---------|---------|
| **What I do** | What the skill covers; the domain |
| **When to use** | Triggers, conditions, workflow decision tree |
| **Prerequisites** | What needs to be in place before using the skill |
| **Core concepts** | Key ideas, patterns, or structures |
| **Quick start** | The most common or essential commands, patterns, or steps |
| **Reference / Details** | Comprehensive coverage: types, functions, config, commands |
| **Best practices / Gotchas** | Tips, pitfalls, common mistakes |
| **Examples** | Concrete, copy-pasteable examples |
| **Workflow** | Step-by-step summary of how to apply the skill |
| **See also** | Links to related skills, docs, or resources |

## Structure Tips

- Use code blocks with appropriate language tags for commands, code, and configuration snippets
- Use Markdown tables for listing multiple items (options, parameters, commands, etc.)
- Use headers to structure content at multiple levels
- Keep sections focused and scannable
- Use `@note` and `@warning` (if using Doxygen-style) for important callouts
- Prefer lists over paragraphs where possible

## Conventions

- Keep skill names lowercase with hyphens (`snake-case` → `snake-case`) unless the tool uses dots
- The `description` in frontmatter must be a single sentence, no trailing period
- Reference external docs with full URLs
- If the skill modifies code, make it clear **what files** are affected and **where**
- If the skill runs commands, make the commands explicit and copy-pasteable
- Prefer self-contained guidance — don't require the user to know about the skill author's other tools
- Aim for **~500 lines or fewer** per `SKILL.md`. If a skill exceeds that, move supplementary material (examples, reference docs, etc.) into separate files in the skill directory and reference them from `SKILL.md`

## Extra Files

`SKILL.md` is the only required file. You may add additional files as needed:

- Code examples or templates
- Diagrams or assets
- Configuration snippets
- Supporting documentation

Place them in the same skill directory and reference them from `SKILL.md` using relative paths (e.g., `examples/` or `assets/`).

## Bad Example vs Good Example

**Bad (too vague):**

```markdown
helps with building C++
use this for cmake
```

**Good (specific, actionable):**

```markdown
# What I do
I help set up CMake build configurations for C++ projects. I generate CMakeLists.txt files, configure targets, and manage dependencies.

# When to use this skill
- The user asks about CMake, C++ builds, or compile flags
- There is no CMakeLists.txt in the project
```
