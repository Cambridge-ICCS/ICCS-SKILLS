---
name: fortitude
description: Use this skill when linting Fortran source code with the Fortitude linter, including running checks, fixing warnings, and configuring rule selection.
---

# What I do

I help lint Fortran source code with [Fortitude](https://github.com/PlasmaFAIR/fortitude), a Fortran linter inspired by (and built upon) [Ruff](https://github.com/astral-sh/ruff), written in Rust and installable with Python. This skill covers running checks, interpreting and fixing warnings, selecting/ignoring rules, and project configuration.

# When to use this skill

Use this skill when the user asks to:

- Lint or check Fortran code for correctness, style, or modernisation issues
- Automatically fix Fortran lint warnings (`--fix`)
- Set up or modify Fortitude configuration (`fortitude.toml`, `fpm.toml`, `pyproject.toml`)
- Select, ignore, or explain specific Fortitude rules
- Integrate Fortitude into CI or pre-commit hooks

# Prerequisites

Fortitude must be installed. The PyPI package is `fortitude-lint`:

```bash
# With uv:
uv tool install fortitude-lint@latest

# With pip:
pip install fortitude-lint

# Standalone installer (macOS and Linux):
curl -LsSf https://github.com/PlasmaFAIR/fortitude/releases/latest/download/fortitude-installer.sh | sh
```

Verify the installation with `fortitude --version`.

# Quick Start

```bash
# Lint the whole project under the working directory
fortitude check

# Check specific files, globs, or directories
fortitude check src/ tests/test_utils.f90

# Automatically fix fixable warnings
fortitude check --fix

# Include unsafe fixes (fixes that may change code meaning)
fortitude check --fix --unsafe-fixes

# Preview fixes without applying them
fortitude check --diff

# Shorter output
fortitude check --output-format=concise

# Get help
fortitude --help
fortitude check --help
```

# Core Commands

| Command | Purpose |
|---------|---------|
| `fortitude check [PATHS]` | Lint files, globs, or directories |
| `fortitude explain [RULES]` | Print extra information about rules |
| `fortitude config [OPTION]` | Describe configuration options |
| `fortitude --help` | Show all commands and arguments |

## Useful `check` Options

| Option | Purpose |
|--------|---------|
| `--fix` | Automatically apply fixes for fixable rules |
| `--select=RULES` | Select rules or groups to check (replaces config selection) |
| `--ignore=RULES` | Ignore rules or groups |
| `--extend-select=RULES` | Select additional rules on top of config file |
| `--preview` | Enable unstable preview rules |
| `--file-extensions=f90,F` | Extensions to search for in directories (deprecated since 0.8.0 — use top-level `include` in config instead) |
| `--extend-exclude=benchmarks,tests` | Additional paths to exclude |
| `--statistics` | Show counts for every rule with at least one violation |
| `--no-respect-gitignore` | Don't ignore files/dirs in `.gitignore` (default: respected) |
| `--output-format=concise` | Shorter output (also `full`, `json`, SARIF, GitHub/GitLab CI formats) |
| `--summary` | Brief overview (with `explain`) |

# Rule Categories

Rules are grouped by category, each with a prefix:

| Prefix | Category | Focus |
|--------|----------|-------|
| `E` | Error | I/O and syntax errors (always on by default) |
| `C` | Correctness | Common bugs: implicit typing, missing `intent`, magic numbers, uninitialised variables |
| `OB` | Obsolescent | Deleted/obsolescent language features: `common`, `equivalence`, `entry`, computed `goto`, `pause`, `mpif.h` |
| `MOD` | Modernisation | Discouraged constructs: `double precision`, old-style array literals, deprecated operators |
| `S` | Style | Formatting and naming: line length, `::`, end-statement naming, keyword case |
| `PORT` | Portability | Non-portable constructs: literal kinds, `real*8`, tabs |
| `FORT` | Fortitude | Issues with Fortitude's own allow comments |

## Commonly Encountered Rules

| Code | Rule | Message |
|------|------|---------|
| `C001` | implicit-typing | {entity} uses implicit typing |
| `C061` | missing-intent | {entity} argument '{name}' missing 'intent' attribute |
| `C092` | procedure-not-in-module | {procedure} not contained within (sub)module or program |
| `C121` | use-all | 'use' statement missing 'only' clause |
| `C131` | missing-accessibility-statement | module '{}' missing default accessibility statement |
| `S001` | line-too-long | line length exceeds maximum (default 100, often set to 132) |
| `S061` | unnamed-end-statement | end statement should be named |
| `S071` | missing-double-colon | variable declaration missing '::' |
| `S101` | trailing-whitespace | trailing whitespace |
| `PORT021` | star-kind | '{dtype}{size}' uses non-standard syntax (e.g. `real*8`) |

Refer to rules by code or by name, e.g. `C001` or `implicit-typing`. Explore interactively:

```bash
# Information on specific rules
fortitude explain C001 C092

# Overview of all rules or a category
fortitude explain --summary
fortitude explain style --summary
```

Full table of rules: https://fortitude.readthedocs.io/en/stable/rules/

# Selecting and Ignoring Rules

```bash
# Just check for missing 'implicit none' (and in interfaces)
fortitude check --select=C001,C002

# Ignore all style rules
fortitude check --ignore=S

# Only style rules, but ignore superfluous implicit none
fortitude check --select=S --ignore=S201

# Rules and categories can be referred to by name
fortitude check --select=style --ignore=superfluous-implicit-none

# Add categories on top of the config file
fortitude check --extend-select=OB
```

# Suppressing Rules in Source

Place an `! allow(...)` comment on the line *before* the statement to suppress. It applies to the whole of the next statement — which can be an entire module:

```fortran
! allow(superfluous-implicit-none)
module numbers
  ! allow(use-all)
  use, intrinsic :: iso_fortran_env
```

Multiple rules can be comma-separated, by code, name, or category:

```fortran
! allow(style, M, FORT002, implicit-real-kind)
```

Unused, unknown, redirected, duplicated, or disabled rules in allow comments are themselves flagged by the `FORT` rules. Use `--ignore-allow-comments` to ignore them.

# Configuration

Fortitude looks for `fortitude.toml`, `.fortitude.toml`, `fpm.toml`, or `pyproject.toml` in the current directory or its parents.

`fortitude.toml` / `.fortitude.toml` (settings under the command name):

```toml
[check]
select = ["C", "E", "S"]
ignore = ["S001", "S082"]
line-length = 132
```

`fpm.toml` (nested under `extra.fortitude`):

```toml
[extra.fortitude.check]
select = ["C", "E", "S"]
ignore = ["S001", "S082"]
line-length = 132
```

`pyproject.toml` (under `tool.fortitude`):

```toml
[tool.fortitude.check]
select = ["C", "E", "S"]
```

Explore configuration options:

```bash
fortitude config check
fortitude config check.extend-select
```

## Preview Rules

Some rules are only available in opt-in preview mode:

```bash
fortitude check --preview
```

or permanently in `fpm.toml`:

```toml
[extra.fortitude.check]
preview = true
```

# Fixes

Some rules are automatically fixable (e.g. superfluous `implicit none`, missing `::`, trailing whitespace):

```bash
fortitude check --fix
```

Run `fortitude explain` to see which rules have fixes available. Prefer `--fix` over manual edits for mechanical fixes; review the diff afterwards.

Fixes are labelled **safe** or **unsafe**: safe fixes do not change code meaning, unsafe fixes may. Only safe fixes are applied by default; add `--unsafe-fixes` to include unsafe ones (Fortitude hints when unsafe fixes are available but not enabled).

# Editor Integration and pre-commit

- LSP support for real-time diagnostics: https://fortitude.readthedocs.io/en/stable/editors/
- VSCode plugin: https://marketplace.visualstudio.com/items?itemName=PlasmaFAIR.fortitude
- pre-commit hooks: https://github.com/PlasmaFAIR/fortitude-pre-commit

# Workflow

1. Check whether a config file (`fortitude.toml`, `.fortitude.toml`, `fpm.toml`, or `pyproject.toml`) exists. If not, run `fortitude check` with defaults first to see what is flagged.
2. Run `fortitude check` and read the output (file:line:column, rule code, message).
3. Look up unfamiliar rules with `fortitude explain <RULE>`.
4. Fix genuine issues in the source; use `--fix` for automatically fixable warnings and review the diff.
5. For deliberate exceptions, use allow comments or add rules to `ignore` in the config — prefer narrow, targeted suppressions.
6. Re-run `fortitude check` until clean, then report the result to the user.

# Gotchas

- Fortitude respects `.gitignore` by default; use `--no-respect-gitignore` if expected files are skipped.
- In directories, only known Fortran extensions are scanned (default: `*.f90 *.F90 *.f95 *.F95 *.f03 *.F03 *.f08 *.F08 *.f18 *.F18 *.f23 *.F23 *.pf`). `.fpp` is **not** included by default — add it via top-level `include = ["*.fpp"]` in the config (`--file-extensions` is deprecated).
- `line-length` is commonly set to 132 (matching legacy fixed-form limits) rather than the default.
- Some rules are in preview mode and require `--preview` or `preview = true` in the config.
- Rule renames are rare but documented in `BREAKING_CHANGES.md`; renamed/redirected codes in allow comments are flagged by `FORT003` (`redirected-allow-comment`).

# See Also

- [Fortitude documentation](https://fortitude.readthedocs.io/) — full user guide
- [Fortitude rules table](https://fortitude.readthedocs.io/en/stable/rules/) — all rules with codes and messages
- [Fortitude repository](https://github.com/PlasmaFAIR/fortitude) — source and issue tracker
- [fortitude-pre-commit](https://github.com/PlasmaFAIR/fortitude-pre-commit) — pre-commit hooks
- [Fortran best practices](https://fortran-lang.org/learn/best_practices/) — the community guidance Fortitude follows
