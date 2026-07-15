# ICCS Skills

A shared collection of GenAI skills for the [Institute of Computing for Climate Science](https://github.com/Cambridge-ICCS) team.

Skills are plain-text instructions designed for AI coding assistants (OpenCode, Claude, Cursor, etc.) to reliably perform domain-specific tasks across our codebase.

---

## Skills

Each skill lives in its own directory under `SKILLS/`. The index of all available skills is maintained in [SKILLS.md](SKILLS.md).

| Skill | Description |
|-------|-------------|
| _No skills added yet — [contributions welcome](#contributing)._ | |

---

## How to Use

### With OpenCode

To consume a skill, add a symlink to the skill directory in your local OpenCode configuration:

```bash
# Add to your opencode.json
"skills": {
  "iccs-skills": {
    "path": "./ICCS-SKILLS/SKILLS/<skill-name>"
  }
}
```

Or use a direct path:

```bash
ln -s /path/to/ICCS-SKILLS/SKILLS/<skill-name> <local-skills-dir>/<skill-name>
```

Skill directories should be inside a directory that OpenCode discovers via its configured `skills` paths. See the [OpenCode docs](https://opencode.ai) for details on configuring skill locations.

### With Claude, Cursor & Others

Skills in this repo are designed to be usable by any AI coding tool that supports custom instructions or prompt augmentation. Copy or symlink the `SKILL.md` file into your tool's appropriate location, or reference it when configuring your agent.

The YAML frontmatter (`name`, `description`) is used for discovery by tooling that scans skill directories. Other systems can parse `SKILLS.md` to find and consume individual skills.

---

## How to Contribute

Contributions follow a simple PR workflow:

1. **Fork** this repository
2. **Create** a new skill or **modify** an existing one
3. **Submit** a Pull Request
   - For new skills: update [SKILLS.md](SKILLS.md) with your entry
   - For modifications: update the relevant `SKILL.md` directly

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

---

## Adding a Skill

### Step-by-Step

1. Create the directory:
   ```bash
   mkdir SKILLS/<your-skill-name>
   ```

2. Create `SKILLS/<your-skill-name>/SKILL.md` with the required YAML frontmatter:
   ```yaml
   ---
   name: your-skill-name
   description: One-line description of what this skill does.
   ---
   ```

3. Add the content — see [Writing a Skill](SKILL-AUTHORING.md) for a crash course on structure, conventions, and best practices.

4. Add an entry to [SKILLS.md](SKILLS.md):
   ```markdown
   | your-skill-name | One-line description. |
   ```

5. Commit the changes and open a Pull Request:
   ```bash
   git add SKILLS/<your-skill-name>/SKILL.md SKILLS.md
   git commit -m "docs(SKILLS): add your-skill-name skill"
   git push -u origin skill/your-skill-name
   ```

### Referencing a Skill Elsewhere

Skills in this repo can be linked to from elsewhere (your project's README, codebase, documentation, etc.):

**Markdown link:**
```markdown
[Skill name](https://github.com/Cambridge-ICCS/ICCS-SKILLS/tree/main/SKILLS/<skill-name>/SKILL.md)
```

**Raw SKILL.md reference (for agents):**
```markdown
For this task, see the skill at: https://raw.githubusercontent.com/Cambridge-ICCS/ICCS-SKILLS/main/SKILLS/<skill-name>/SKILL.md
```

**GitHub URL pattern:**
```
https://github.com/Cambridge-ICCS/ICCS-SKILLS/blob/main/SKILLS/<skill-name>/SKILL.md
```

---

## SKILL-AUTHORING

See [SKILL-AUTHORING.md](SKILL-AUTHORING.md) for a crash course on writing skills: structure, frontmatter conventions, best practices, and examples.

---

## AGENTS.md

See [AGENTS.md](AGENTS.md) for AI agent instructions on working with this repository.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for full guidelines.

---

## License

This repository is licensed under the [MIT License](LICENSE).
