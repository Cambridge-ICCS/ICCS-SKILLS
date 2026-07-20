# ICCS Skills Repository — Agent Instructions

This repository contains AI coding assistant skills for the Cambridge Institute of Computing for Climate Science team. Skills are used by agents to reliably perform domain-specific tasks.

## Repository Layout

```
├── LICENSE                       MIT licence (ICCS 2026)
├── README.md                     Landing page, usage guide, and skills index
├── SKILL-AUTHORING.md            Guide to writing skills
├── AGENTS.md                     This file — agent instructions
├── CONTRIBUTING.md               How to contribute (PRs, conventions)
├── .github/
│   └── PULL_REQUEST_TEMPLATE.md  PR template for contributions
└── skills/
    └── <skill-name>/
        └── SKILL.md              The skill file (required)
        └── ...                   Additional files (optional, e.g. examples, assets)
```

## SKILL.md Conventions

Each skill is primarily defined in `SKILL.md` within its directory. Files must follow these conventions:

1. **YAML frontmatter** at the very top:
   ```yaml
   ---
   name: skill-name
   description: One-line description of what this skill does.
   ---
   ```
2. **name** — lowercase, hyphen-separated, unique within the repo
3. **description** — one sentence, no trailing period
4. Content follows in Markdown after the closing `---`
5. Additional files may be added as needed (code examples, templates, assets, etc.)

## Operations

### Adding a New Skill

```bash
# 1. Create the directory and SKILL.md
mkdir -p skills/<skill-name>

# 2. Write content to skills/<skill-name>/SKILL.md
# Start with the frontmatter, then add your content sections.

# 3. Add an index entry to README.md
# Update the table: | <skill-name> | <one-line description> |

# 4. Commit
git add skills/<skill-name>/ README.md
git commit -m "docs(SKILLS): add <skill-name> skill"
```

### Modifying an Existing Skill

```bash
# 1. Edit the SKILL.md file directly
# 2. Commit the change
git add skills/<existing-skill>/SKILL.md
git commit -m "docs(SKILLS): update <skill-name> skill"
```

### Removing a Skill

```bash
# 1. Remove the directory and its index entry
rm -rf skills/<skill-name>

# 2. Remove the table row from README.md

# 3. Commit
git add skills/ README.md
git commit -m "docs(SKILLS): remove <skill-name> skill"
```

### Updating the Index (README.md)

To regenerate the index from the filesystem:

```bash
# Scan skills/ directory and rebuild the table in README.md
# Each directory becomes a row: | name | description (from frontmatter) |
```

## Conventions

- Follow [conventional commits](https://www.conventionalcommits.org/) with a `docs(SKILLS):` prefix for all changes in this repo
- Keep skill directories flat (no nested `skills/something/nested/`)
- Name directories with lowercase hyphen-separated identifiers
- Do not commit large files (>5 MB) — use assets or external links instead
- If a skill references code from another repo, include a full URL in the skill content
