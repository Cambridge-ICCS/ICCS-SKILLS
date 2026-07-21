![ICCS Logo](images/UCAM_ICCS_Logo.png)

# ICCS Skills

A shared collection of GenAI skills for the [Institute of Computing for Climate Science](https://github.com/Cambridge-ICCS) team.

Skills are plain-text instructions designed for AI coding assistants (OpenCode, Claude, Cursor, etc.) to reliably perform domain-specific tasks across our codebase.

## Skills Index

| Skill | Description |
|-------|-------------|
| [ford](skills/ford/SKILL.md) | Use this skill for adding FORD documentation comments to Fortran source code. |
| [ftorch](SKILLS/ftorch/SKILL.md) | Use this skill when working with the FTorch library to couple PyTorch ML models to Fortran code. |

## How to Use

### With OpenCode

OpenCode discovers skills automatically from `SKILL.md` files placed in its search paths (`.opencode/skills/`, `.claude/skills/`, `.agents/skills/`, or their `~/.config/` equivalents).

Pick any skill from this repo and:

```bash
# Option 1: symlink a specific skill
ln -s /path/to/ICCS-SKILLS/skills/<skill-name> .opencode/skills/<skill-name>

# Option 2: copy-paste SKILL.md into your own skills directory
cp /path/to/ICCS-SKILLS/skills/<skill-name>/SKILL.md .opencode/skills/<skill-name>/
```

See the [OpenCode skills docs](https://opencode.ai/docs/skills/) for the full list of discovery paths.

### With Claude, Cursor & Others

Skills in this repo are designed to be usable by any AI coding tool that supports custom instructions or prompt augmentation. Copy a `SKILL.md` into your tool's skill directory, or reference it directly when configuring your agent.

The YAML frontmatter (`name`, `description`) is used for discovery by tooling that scans skill directories. Other systems can parse the index table below to find and consume individual skills.

## How to Contribute

Contributions follow a simple PR workflow:

1. **Fork** this repository
2. **Create** a new skill or **modify** an existing one
3. **Submit** a Pull Request
   - For new skills: update the index table in [README.md](README.md) with your entry
   - For modifications: update the relevant `SKILL.md` directly

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## Adding a Skill

### Step-by-Step

1. Create the directory:
   ```bash
   mkdir skills/<your-skill-name>
   ```

2. Create `skills/<your-skill-name>/SKILL.md` with the required YAML frontmatter:
   ```yaml
   ---
   name: your-skill-name
   description: One-line description of what this skill does.
   ---
   ```

3. Add the content — see [Writing a Skill](SKILL-AUTHORING.md) for a crash course on structure, conventions, and best practices.

4. Add an entry to the index table in [README.md](README.md):
   ```markdown
   | your-skill-name | One-line description. |
   ```

5. Commit the changes and open a Pull Request:
   ```bash
   git add skills/<your-skill-name>/SKILL.md README.md
   git commit -m "docs(SKILLS): add your-skill-name skill"
   git push -u origin skill/your-skill-name
   ```

### Referencing a Skill Elsewhere

Skills in this repo can be linked to from elsewhere (your project's README, codebase, documentation, etc.):

**Markdown link:**
```markdown
[Skill name](https://github.com/Cambridge-ICCS/ICCS-SKILLS/tree/main/skills/<skill-name>/SKILL.md)
```

**Raw SKILL.md reference (for agents):**
```markdown
For this task, see the skill at: https://raw.githubusercontent.com/Cambridge-ICCS/ICCS-SKILLS/main/skills/<skill-name>/SKILL.md
```

**GitHub URL pattern:**
```
https://github.com/Cambridge-ICCS/ICCS-SKILLS/blob/main/skills/<skill-name>/SKILL.md
```

## SKILL-AUTHORING

See [SKILL-AUTHORING.md](SKILL-AUTHORING.md) for a crash course on writing skills: structure, frontmatter conventions, best practices, and examples.

## AGENTS.md

See [AGENTS.md](AGENTS.md) for AI agent instructions on working with this repository.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for full guidelines.

## License

This repository is licensed under the [MIT License](LICENSE).
