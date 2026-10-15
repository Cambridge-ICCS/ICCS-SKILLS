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

`green-ci` templates can be applied without cloning the respository. Simply run
```bash
copier copy https://github.com/Cambridge-ICCS/green-ci.git /path/to/my-project
```
and follow the prompts.

## Approach for agents

- Agents are not easily able to follow on-screen prompts in the same way that humans can.
- Instead, it makes more sense to pass an 'answers file' with
  ```sh
  copier copy --answers-file /path/to/answers/file https://github.com/Cambridge-ICCS/green-ci.git /path/to/my-project
  ```
- The answers file is a YAML file that specifies the git commit hash, path to copy to, and the answers to the prompts.
- The commit hash is specified by `_commit` and the path to copy to is specified by `_src_path`.
- The prompts by `green-ci` are specified in the [options](#options) section below.

### Example answers file

Consider the following YAML file, which is used in the test suite CI for `green-ci` itself (at `.github/answers/test_suite.yml`):
```yaml
_commit: 44528ab
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
    # Triggers the workflow on pushes to open pull requests with code changes
    pull_request:
      paths:
        - '.github/workflows/test_suite_python.yml'
        - '**.py'
        - 'requirements.txt'
```

## Separation of concerns

Where possible, separate workflows should be used for distinct tasks.
For example, it is good practice to have separate workflows containing test suites, static analysis checks, and documentation builds, and to use appropriate path triggers.

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

1. Apply `green-ci` to your project via `copier`
2. Follow the prompts to match the requirements of the project
3. Fill in any `TODO` notes left in the workflow definitions by `green-ci`

## See Also

- [green-ci repository](https://github.com/Cambridge-ICCS/green-ci)
- [green-ci docs](https://cambridge-iccs.github.io/green-ci)
