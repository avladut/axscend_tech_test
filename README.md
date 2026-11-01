# axscend_tech_test

[![CI](https://github.com/avladut/axscend_tech_test/actions/workflows/ci.yml/badge.svg)](https://github.com/avladut/axscend_tech_test/actions/workflows/ci.yml)

A Flutter app (phone and tablet) for browsing the
[JSONPlaceholder](https://jsonplaceholder.typicode.com/) API: users, with their
posts and comments, albums and photos, and todos. Built for the Axscend
technical test.

**Status:** the app opens on the users list, which you can search, sort and
pull to refresh. It loads 20 users at a time as you scroll, and keeps at most
60 in memory. From a user you open their albums, an album's photos (the
thumbnails are cached on the device) and a photo at full size. Posts and
todos come next.

## Requirements

Flutter **3.47.2** (Dart 3.13), the version CI uses.

## Getting started

Install the dependencies for every package (one command, from the repo root):

```bash
flutter pub get
```

Run everything CI runs (format check, analyze, tests with coverage, and the
70% coverage minimum):

```bash
dart run melos run ci
```

Run the app:

```bash
cd apps/axscend_tech_test && flutter run
```

Optional: `dart pub global activate melos` lets you type `melos …` directly. It
switches to the version pinned in `pubspec.lock`.

## Structure

A [pub workspace](https://dart.dev/tools/pub/workspaces) managed with
[Melos](https://melos.invertase.dev/). Why it's split this way:
[ADR 0001](docs/adr/0001-melos-workspace.md).

```
apps/axscend_tech_test/         Flutter app: screens, blocs, routing, DI
packages/app_ui/                Flutter: design tokens, theme, reusable widgets
packages/domain/                Pure Dart: models, repository contracts, failures
packages/jsonplaceholder_data/  Pure Dart: the JSONPlaceholder backend
tool/ai_review/                 Dev tooling: the AI pull request reviewer
tool/coverage_gate/             Dev tooling: the 70% coverage minimum
docs/adr/                       Architecture decisions
docs/ai/prompts/                The prompt behind each task
```

Which package may use which:

- `app_ui` and `domain` depend on none of the others.
- `jsonplaceholder_data` depends on `domain` only.
- The app depends on all three, but only its injector may import the data
  package. Swapping the backend is a new sibling package plus one line there.

## How it's built

I built this with two AI models in fixed roles. Every decision stayed mine.

| Role | Who | What they do |
|---|---|---|
| Direction and decisions | Me (Alex) | I write or approve each task's prompt, decide every review finding, resolve the review threads and merge. |
| Author | **Claude Opus 5.5** (`claude-opus-5-5`) in [Claude Code](https://claude.com/claude-code) | Plans each task, writes the code and its tests, runs the checks, opens the pull request, answers the reviewer, and fixes what I accept. Its commits carry a `Co-Authored-By: Claude Opus 5.5` line. Its working rules are in [CLAUDE.md](CLAUDE.md). |
| Reviewer | **Qwen3.8-Flash-Next** (`qwen38-flash`), self-hosted on my own server | Reviews every pull request through [tool/ai_review](tool/ai_review). Advisory only: it comments, and never approves, blocks or merges. |

The two models come from different families on purpose: the reviewer doesn't
share the author's blind spots.

### A task, from prompt to `main`

1. **Prompt.** I describe the task. My words are kept verbatim in
   [docs/ai/prompts](docs/ai/prompts), with Claude's plan and the choices it
   made for me to check. When a decision is mine (a new package, a design
   trade-off), Claude asks before building.
2. **Branch.** One branch per task, `task/NN-name`. Nothing is committed to
   `main` directly.
3. **Build.** Claude writes the code with its tests and runs everything CI
   runs (`dart run melos run ci`). Each bug fix gets a test that fails without
   the fix. UI changes are also checked in the running app, on the web and the
   iPhone simulator.
4. **Pull request,** titled `Task NN: what it solves`. Two required checks
   run:
   - **checks:** formatting, the analyzer with infos as errors, and the
     design-token check (the app's code may not hard-code a colour, text
     size, spacing or radius, only use [app_ui](packages/app_ui)'s tokens);
   - **tests:** every package's tests, and at least **70% line coverage per
     package** ([tool/coverage_gate](tool/coverage_gate)). The coverage table
     is on each run's summary page.
5. **AI review.** Qwen reviews the diff and posts one GitHub thread per
   finding, at most 10, ranked by severity. A large PR is reviewed in up to 4
   parts. The job runs `main`'s copy of the reviewer, so a PR can't weaken its
   own review.
6. **Discuss first.** Claude replies in every thread with its assessment
   (agree, partly agree or disagree), the reasons, and the fix it would make.
   It changes no code at this point.
7. **I decide,** in the thread or in our chat. Claude fixes what I accept in
   a new commit and replies with it. The one exception is a failing check:
   Claude fixes that straight away.
8. **Merge.** I resolve every thread and squash-merge. `main` gets one commit
   per task, titled `Task NN: …`, which keeps the branch's commit messages and
   their `Co-Authored-By` lines.

Claude works with my GitHub access, but never approves a pull request,
resolves a review thread or merges. That rule is in [CLAUDE.md](CLAUDE.md).

### What `main` enforces

| Rule | Setting |
|---|---|
| Changes only through pull requests | No direct pushes, no force-pushes, no deletion. It applies to admins too. |
| Required checks | `checks` and `tests`, run on the branch brought up to date with `main` |
| Review threads | Every one must be resolved before the merge |
| History | Linear: squash merge is the only merge method |

### The record so far

- **10 tasks,** each merged through its own pull request (#1 to #10), after
  a setup commit.
- **36 findings from Qwen** across those pull requests. Claude agreed with
  about 4 in 10, fully or in part, and proposed a fix for each. It disagreed
  with the rest and gave its reasons in each thread. I made the call on every
  one.
- **Not every bug came from the reviewer.**
  - Task 09 fixed 11 issues from a full code review by four independent
    Claude reviewers.
  - Task 10 fixed 2 bugs found by testing the app on the web and the iPhone
    simulator.

Each task's prompt record says what was asked, what was built, and what was
found along the way.
