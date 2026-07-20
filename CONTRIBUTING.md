# Contributing to ICCS Skills

Thank you for contributing to this shared skills repository. This document covers how to create new skills, modify existing ones, and submit changes.

## Quick Start

### Adding a New Skill

1. **Create the directory:**
   ```bash
   mkdir skills/<skill-name>
   ```

2. **Create `SKILL.md`** — the core skill file with required frontmatter:
   ```yaml
   ---
   name: your-skill-name
   description: One-line summary of what this skill does.
   ---
   ```
   Then add your skill content below the frontmatter. See [SKILL-AUTHORING.md](SKILL-AUTHORING.md) for a full guide to writing skills.

3. **Add an index entry** to the index table in [README.md](README.md):
   ```markdown
   | your-skill-name | One-line description. |
   ```

4. **Commit and PR:**
   ```bash
   git add skills/<skill-name>/SKILL.md README.md
   git commit -m "docs(SKILLS): add your-skill-name skill"
   git push -u origin your-branch-name
   ```

### Updating an Existing Skill

Edit the `SKILL.md` file directly and submit a PR:

```bash
git edit skills/<skill-name>/SKILL.md
git add skills/<skill-name>/SKILL.md
git commit -m "docs(SKILLS): update <skill-name> skill"
git push -u origin your-branch-name
```

### Removing a Skill

```bash
rm -rf skills/<skill-name>
# Also remove the corresponding table row from README.md
git add skills/ README.md
git commit -m "docs(SKILLS): remove <skill-name> skill"
git push -u origin your-branch-name
```

## Conventions

### Naming

- Directory names: lowercase with hyphens (e.g. `ftorch`, `green-ci`, `fortuno`)
- The `name` field in frontmatter must match the directory name
- Names must be unique within the repo

### Frontmatter

- Always include both `name` and `description`
- `description` should be a single sentence, no trailing period
- Example:

  ```yaml
  ---
  name: my-new-skill
  description: Use this skill when working with my project's build system.
  ---
  ```

### Content

- Each section header should be preceded by a blank line
- Code blocks must include a language identifier where applicable
- Keep explanations concise and focused on actions the AI can take
- Use tables to present structured information (config options, parameters, commands)
- Provide copy-pasteable examples

### Commit Messages

Use [conventional commits](https://www.conventionalcommits.org/) with the scope `SKILLS`:

```
docs(SKILLS): add <skill-name> skill
docs(SKILLS): update <skill-name> skill
docs(SKILLS): remove <skill-name> skill
docs(SKILLS): fix formatting in <skill-name>
```

## Pull Requests

All changes go through Pull Requests for review.

### PR Checklist

Use the provided [pull request template](.github/PULL_REQUEST_TEMPLATE.md) — it will be populated automatically when you create a PR.

At minimum, ensure:

- [ ] The skill works (tested with the AI tool you use)
- [ ] Frontmatter is correct and matches the directory name
- [ ] The `description` is clear and accurate
- [ ] Content is well-structured and follows the guidelines above
- [ ] The index table in [README.md](README.md) has been updated (for new skills)
- [ ] Commit messages follow the conventional commits convention

### Review Process

PRs will be reviewed for:

1. **Correctness:** Does the skill perform as intended?
2. **Clarity:** Is the guidance clear and actionable?
3. **Conventions:** Does it follow repo-wide formatting and naming?

## Questions

If you're unsure whether a skill belongs in this repo, open an issue or ask in our team channel — we're happy to help!
