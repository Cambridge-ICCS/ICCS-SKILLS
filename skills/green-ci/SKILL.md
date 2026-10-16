---
name: green-ci
description: Use this skill when creating or modifying GitHub Actions workflows and when making git commits related to such workflows
---

# What I do

I help use the `green-ci` utility to create GitHub Actions workflows that follow best practices for green continuous integration (CI) and continuous deployment (CD).

# When to use this skill

Use this skill when:
- Creating or modifying GitHub Actions workflows
- Setting up CI/CD workflows for a new project
- When making git commits related to GitHub Actions workflows

# Prerequisites

- The Python package `copier` installed
  - We recommend using a Python virtual environment for this

# Quick Start

## Approach for humans

`green-ci` templates can be applied without cloning the repository. Simply run
```bash
copier copy https://github.com/Cambridge-ICCS/green-ci.git /path/to/my-project
```
and follow the prompts.

## Approach for agents

- Agents are not easily able to follow on-screen prompts in the same way that humans can.
- Instead, pass an 'answers file' together with the `--defaults` flag (which makes the run fully non-interactive — without it `copier` aborts with "Interactive session required"):
  ```sh
  copier copy --defaults --answers-file <relative-path-to-answers-file> https://github.com/Cambridge-ICCS/green-ci.git /path/to/my-project
  ```
- **Important:** the `--answers-file` path must be **relative to the destination directory**, not absolute. Passing an absolute path fails with a pydantic `ValidationError: "... is not a relative path"`. A reliable pattern is to place the answers file inside the destination directory (e.g. `<dest>/answers.yml`) and run `copier` with `workdir` set to the destination, passing just the basename.
- The answers file is a YAML file that specifies the git commit hash, path to copy to, and the answers to the prompts.
- The commit hash is specified by `_commit` and the path to copy to is specified by `_src_path`.
  - To find the current upstream `_commit` value, inspect the template's `copier.yml` (e.g. via `curl https://raw.githubusercontent.com/Cambridge-ICCS/green-ci/main/copier.yml`) — the value used in this skill's example below may be stale.
- The prompts by `green-ci` are specified in the [options](#options) section below. The defaults for each prompt are recorded in the template's `copier.yml` (also accessible at the URL above), which is useful as a reference when filling out an answers file.

## Working with existing workflows

- Copier will crash if files already exist whose names match those that would be created.
- Note that the workflow names may not match those used by `green-ci`.
  - As such, you may need to merge the recommendations from the newly created workflows into the existing ones.

### Recommended pattern for agents: generate into a scratch directory

When the goal is to merge green-ci recommendations into existing workflows (rather than to adopt green-ci's filenames verbatim), the cleanest approach is:

1. Generate the template workflows into a scratch directory outside the project (e.g. `/tmp/green-ci-output/`), so there are no filename conflicts to resolve:
   ```sh
   mkdir -p /tmp/green-ci-output
   cp answers.yml /tmp/green-ci-output/answers.yml
   cd /tmp/green-ci-output
   copier copy --defaults --answers-file answers.yml https://github.com/Cambridge-ICCS/green-ci.git .
   ```
2. Read the generated `.github/workflows/*.yml` files directly to see green-ci's current recommended content for the configured options.
3. Manually merge the relevant snippets into the project's existing workflows (see "Merging recommendations into existing workflows" below).

This avoids the `--force` + `git diff` + restore-intended-functionality dance entirely, and avoids having to delete the generated files afterwards.

### Alternative pattern: apply in-place with `--force`

If you do need to apply green-ci directly into the project root, use the `--force` option to overwrite existing files. Then use `git diff` to see what was changed and make edits to restore the intended functionality.

### Generated workflows and their purposes

| Generated file          | Purpose                                              |
| ----------------------- | ---------------------------------------------------- |
| `test_suite.yml`        | Build the project and run its test suite             |
| `static_analysis.yml`   | Linting and other static analysis checks             |
| `build_docs.yml`        | Build (and optionally deploy) documentation          |
| `render_joss_paper.yml` | Render a JOSS paper draft and upload the PDF         |

### Merging recommendations into existing workflows

When a project already has workflows — perhaps named differently, or split by platform/compiler — treat the generated files as a statement of best practice rather than a drop-in replacement:

1. Find the generated workflows (e.g., `git status --short .github/workflows/` if generated in-place, or list the files in the scratch directory) and read the `.copier_answers.yml` file to see which options were provided.
2. Map each generated workflow to the existing workflow(s) of the same type. A project may have several of a given type (e.g., one test suite per compiler); the recommendations apply to each of them, adapted to what that workflow builds.
3. `diff` each generated workflow against its existing counterpart to isolate the deltas, then sort them into:
   - **Recommendations to merge**: see the checklist below.
   - **Project-specific content to preserve**: build and test steps, matrix configurations, runner labels, and pinned action versions.
4. Keep the project's own conventions where they are already equivalent (e.g., an alternative `concurrency` group expression or job name).
5. If you generated the templates in-place, delete the generated files once their recommendations are merged, so that they do not shadow the project's workflows. (If you generated into a scratch directory, this step is unnecessary.)
6. Validate the merged workflows (e.g., parse the YAML; run `actionlint` or `zizmor` if available) and review the final `git diff`.

### Checklist of green-ci recommendations to apply per workflow

For each existing `.github/workflows/*.yml`, ensure the following are present (adapted to what the workflow actually builds/tests):

- [ ] **Trigger `paths:` filters on the `pull_request` trigger only**, covering the workflow file itself (`.github/workflows/<name>.yml`) plus the source/build/doc patterns the workflow depends on. Do *not* add `paths:` to the `push` trigger — developers usually want every workflow to run on merges to `main` regardless of which files changed, both as a final safety net and to keep the main-branch CI record complete. The `push` trigger should just constrain `branches: ["main"]`.
- [ ] **`merge_group:`** trigger if the project uses merge queues.
- [ ] **`workflow_dispatch:`** trigger so the workflow can be run manually from the Actions tab.
- [ ] **`concurrency:`** block that cancels in-progress runs on the same ref. Either form is acceptable:
  - The green-ci template form: `group: ${{ github.workflow }}-${{ github.ref }}` with `cancel-in-progress: true`
  - The softer project convention: `cancel-in-progress: ${{ startsWith(github.ref, 'refs/pull/') }}` (only cancel for PR builds)
- [ ] **Top-level `permissions: {}`** so the workflow token has no permissions by default. Jobs that need write access (e.g., `zizmor` needs `security-events: write`, `deploy-pages` needs `pages: write` and `id-token: write`) should declare them at the job level.
- [ ] **`timeout-minutes`** on every job, sized as an over-estimate of typical runtime. As a rough guide: lint/format ~5 min, docs ~15 min, unit tests ~15–60 min, integration tests ~30–120 min.
- [ ] **Deployment guards**: any deploy-to-Pages / publish job should have `if: ${{ github.ref == 'refs/heads/main' }}` so it doesn't fire on PRs or manual dispatches of other branches.
- [ ] **Descriptive comments** on triggers and `permissions:` blocks, matching the style used by the green-ci templates (`# Triggers the workflow on pushes to the "main" branch...`, `# Write permissions are not needed for this workflow`, etc.). This makes the intent of each trigger clear to future editors.

### Example answers file

Consider the following YAML file, which is used in the test suite CI for `green-ci` itself (at `.github/answers/test_suite.yml`):
```yaml
_commit: 44528ab  # NOTE: replace with the current upstream commit hash before use
_src_path: .
build_docs_timeout: 15
build_sys_file_paths:
- 'copier.yml'
carbon_aware: false
deploy_docs: false
docs_file_paths:
- '**/*.md'
joss_render_timeout: 5
joss_upload_timeout: 5
requirements_file_paths:
- requirements-dev.txt
source_file_paths:
- '**/*.jinja'
static_analysis_timeout: 5
test_suite_timeout: 15
```

# Best practices

In the following we summarise the best practices that `green-ci` seeks to follow.

## Time limits

By default, a job will continue running for 360 minutes before being cancelled. This can be extremely wasteful.
As such, it is good practice to provide a shorter time limit after which the job will be cancelled.
This should be an over-estimate, so that the job will still pass when the code is working as expected.

Example:
```yaml
  jobs:
    test-ubuntu-serial:
      runs-on: ubuntu-latest
      timeout-minutes: 10
      # <Further job definition>
```

## Concurrency

In most cases, there is no need for a job to continue running once a more recent commit is pushed.
In such cases, configure the `concurrency` so that in-progress jobs will be cancelled.

Example:
```yaml
  concurrency:
    group: ${{ github.workflow }}-${{ github.event.pull_request.number || github.ref }}
    cancel-in-progress: true
```

## Fail-fast

Sometimes workflow jobs contain several steps that are executed in series.
For such jobs, it is important to order the steps such that failure is detected as soon as possible, i.e., a *fail-fast* policy.
Put jobs that are likely to fail faster before jobs that are likely to fail slower.

A good general ordering is as follows:

1. Formatting/style/linting checks
2. Other static analysis checks
3. Unit test suites
4. System/integration test suites

## Triggers

Workflow triggers should be configured so that jobs are only run when files that affect them are modified.

Example configuring `paths`:
```yaml
  name: MyPythonTestSuite

  on:
    # Triggers the workflow on pushes to the "main" branch, i.e., PR merges
    push:
      branches: [ "main" ]

    # Triggers the workflow on pushes to open pull requests with code changes
    pull_request:
      paths:
        - '.github/workflows/test_suite_python.yml'
        - '**.py'
        - 'requirements.txt'

    # Allows you to run this workflow manually from the Actions tab
    workflow_dispatch:
```

- Apply `paths` filters to the `pull_request` trigger only. Do **not** add `paths` to the `push` trigger — although GitHub Actions supports it, maintainers usually want every workflow to run on merges into `main` regardless of which files changed. This gives a complete CI record on the main branch and acts as a final safety net for changes whose impact might have been underestimated by the `paths` patterns.
- Retain `workflow_dispatch` (if present) so the workflow can still be run manually.

## Separation of concerns

- Where possible, separate workflows should be used for distinct tasks.
- For example, it is good practice to have separate workflows containing test suites, static analysis checks, and documentation builds, and to use appropriate path triggers.

## Skip CI

GitHub Actions supports manually skipping of CI workflows that would be triggered by ``push`` or ``pull_request`` by including any of the following strings in a commit message:

* ``[skip ci]``
* ``[ci skip]``
* ``[no ci]``
* ``[skip actions]``
* ``[actions skip]``

Use these when committing changes that you don't need CI/CD to run for, or for commits that you don't expect to pass CI/CD checks.

# Options

* `source_file_paths`: A YAML list of source file patterns (strings) including the file extension.
* `docs_file_paths`: A YAML list of documentation file patterns (strings) including the file extension.
* `build_sys_file_paths`: A YAML list of build system file patterns (strings) including the file extension.
* `requirements_file_paths`: A YAML list of requirements file patterns (strings) including the file extension.
* `build_docs_timeout`: The timeout in minutes for the documentation build job (integer)
* `static_analysis_timeout`: The timeout in minutes for the static analysis job (integer)
* `test_suite_timeout`: The timeout in minutes for the test suite job (integer)
* `joss_render_timeout`: The timeout in minutes for the JOSS paper render job (integer)
* `joss_upload_timeout`: The timeout in minutes for the JOSS paper upload job (integer)
* `deploy_docs`: Whether to include a deployment job in the docs workflow (boolean)
* `carbon_aware`: Whether to include carbon-aware energy measurement steps in the workflow (boolean)

# Workflow

## For a new project (no existing workflows)

1. Apply `green-ci` to your project via `copier copy --defaults --answers-file <answers.yml> https://github.com/Cambridge-ICCS/green-ci.git .` (see "Approach for agents" above).
2. Fill in any `TODO` notes left in the workflow definitions by `green-ci`.

## For a project with existing workflows

1. Generate the green-ci templates into a scratch directory (see "Working with existing workflows" above).
2. For each existing workflow, work through the checklist in "Checklist of green-ci recommendations to apply per workflow" above.
3. Validate the resulting YAML files (e.g. `python3 -c "import yaml, sys; [yaml.safe_load(open(f)) for f in sys.argv[1:]]" .github/workflows/*.yml`) and review the diff.
4. Discard the scratch directory — there is nothing to clean up in the project itself.

# Other notes

- Invoking `copier` will create directories `.github/workflows/` (if they do not already exist) and insert several GitHub Actions workflows.
- It will also create a `.copier_answers.yml` file for convenience of seeing what prompts were provided.
  - Note that `.gitignore` files are not created or modified so the `.copier_answers.yml` file will likely be picked up by git as untracked.
  - The `.copier_answers.yml` file is in the same format as accepted by the `--answers-file` argument.

## See Also

- [green-ci repository](https://github.com/Cambridge-ICCS/green-ci)
- [green-ci docs](https://cambridge-iccs.github.io/green-ci)
