# Task 04: Tests and coverage gate

- **Status:** approved by Alex on 2026-11-01 (see below)
- **Branch:** `task/04-coverage-gate`

## Alex's prompts (verbatim)

While PR #3 was in review, Alex wrote:

> stop. I want an additional step in the mr process. the tests must be ran
> and pass. also, can you give the test coverage? eventually set a limit. say
> 70% in order for the mr to pass?

Claude answered that the tests already ran inside the required `checks` job,
so a failing test already blocked the merge, and measured the coverage:
`domain` 100%, `jsonplaceholder_data` 98.1%, the app 92.3%, `ai_review`
94.7%, and `app_ui` had no code yet. Claude proposed a gate of at least 70%
per package, and asked whether it should be its own required check or a step
inside `checks`. Alex answered:

> Own check, go

The app frame, planned as task 04, becomes task 05.

Once the gate was built and passing locally, Alex paused it before anything
was committed:

> keep the changes, stash them. we need to discuss more. First, answer/solve
> to comments from qwen

Claude stashed the work and fixed PR #3's two review findings. Alex then
wrote:

> now, add the changes to the pipeline regarding test coverage to the project
> as a pr

## Goal

Every PR shows its own **tests** check. It runs every package's tests with
coverage and fails unless each package covers at least 70% of its lines.

## Must

- **A `tests` job in `ci.yml`,** separate from `checks` (which keeps format
  and analyze). It runs every package's tests with coverage, then the gate.
- **Coverage without new tools:** `dart test --coverage-path` and
  `flutter test --coverage` write lcov reports themselves.
- **The gate:** a small pure Dart tool, `tool/coverage_gate`, with its own
  tests.
  - It reads the workspace's package list from the root `pubspec.yaml`, so a
    new package can't be missed.
  - It counts each package's own `lib/` files only, never its dependencies,
    and skips generated files.
  - It fails if any package is below 70% of its lines.
  - It writes a coverage table to the run's summary page and to the log.
- **Melos:** a script for the coverage run and one for the gate, both part of
  `dart run melos run ci`, so the local check matches CI.
- **README and CLAUDE.md** say that the `tests` check and the 70% minimum are
  part of every PR.

## Setup that needs Alex's yes (Claude asks at the time)

- **Branch protection:** require the new `tests` check on `main`, next to
  `checks`. Until then it shows on PRs but doesn't block them.

## Out of scope

- Raising the minimum per package, or measuring branch coverage.
- Posting coverage as a PR comment. The run's summary page has it.

## Choices Claude made (Alex's to change)

- **Each package must reach 70% on its own,** not the total. Otherwise the
  well-tested `ai_review` could hide an untested app.
- **A package with code but nothing covered fails,** even if its tests pass.
  That catches a package with no tests at all.
- **A package with no code yet is skipped,** as `app_ui` is today. Files with
  only `library`, `import`, `export` or `part` lines don't count as code.
- **Known limit: a file that no test imports at all isn't counted.**
  Coverage reports only see loaded files. A file that is imported but never
  run is counted (it showed up at 0%). Claude first made every unloaded file
  fail the gate, but that also flagged the domain's abstract repository
  interfaces, which have nothing to run. Telling those apart reliably would
  need a generated test that imports every file, which is more machinery
  than this task asked for.
- **`ai_review` and `coverage_gate` count too.** They're dev tooling, but
  they're our code.

## Done when

- The PR shows a `tests` check that passes, with the coverage table on its
  summary page.
- Dropping a package below 70% makes it fail (checked locally: an untested
  file took `domain` to 18.3%, and the gate exited 1).
- `dart run melos run ci` passes.
- The AI review has run on the PR, and Alex has decided every finding.

## Agent plan

1. Build `tool/coverage_gate`: lcov parsing, the per-package rules, the
   report and the command line, each with tests.
2. Add the Melos scripts and the `tests` job.
3. Update README and CLAUDE.md, then run everything locally, including the
   two failure cases.
4. Ask Alex before committing, pushing, and changing branch protection.
