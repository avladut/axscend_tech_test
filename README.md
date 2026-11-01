# axscend_tech_test

[![CI](https://github.com/avladut/axscend_tech_test/actions/workflows/ci.yml/badge.svg)](https://github.com/avladut/axscend_tech_test/actions/workflows/ci.yml)

A Flutter app (phone and tablet) for browsing the
[JSONPlaceholder](https://jsonplaceholder.typicode.com/) API: users, with their
posts and comments, albums and photos, and todos. Built for the Axscend
technical test.

**Status:** project setup only (workspace, packages, CI). Features land one
pull request at a time.

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
apps/axscend_tech_test/         Flutter app: screens, cubits, routing, DI
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

- `main` is protected: changes arrive only through pull requests, and two CI
  checks must pass first:
  - **checks:** formatting and the analyzer, with infos as errors;
  - **tests:** every package's tests, and at least **70% line coverage per
    package** ([tool/coverage_gate](tool/coverage_gate)). The coverage table
    is on each run's summary page.
- Each task starts from a prompt I write or approve, kept in
  [docs/ai/prompts](docs/ai/prompts).
- **AI review, human decision.** Every PR is also reviewed by a second model
  of a different family, running on my own server
  ([tool/ai_review](tool/ai_review)). Each finding is a separate thread. I
  reply to each one (accept, or ask for a change) and resolve it, and `main`
  only accepts the merge once every thread is resolved. The bot only
  comments: it never approves, blocks or merges.
- AI use: the code is written with Claude Code under my direction. Commits it
  wrote carry a `Co-Authored-By: Claude` line. A full write-up of how AI was
  used, and where it was wrong, comes before submission.
