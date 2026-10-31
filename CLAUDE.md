# CLAUDE.md

## Before you change anything

- Code follows Alex's `flutter-standards` skill, except where `docs/adr/` says
  otherwise. ADR 0001: a Melos workspace with `domain` and
  `jsonplaceholder_data` packages next to `app_ui`.
- Package rules (pubspec-enforced; keep them that way):
  - `domain` is pure Dart: no Flutter, no http, no other workspace package.
  - `app_ui` knows nothing about the domain or any backend.
  - `jsonplaceholder_data` depends on `domain` only.
  - In the app, only `lib/injector.dart` imports `jsonplaceholder_data`.
- Cubits, screens, routes and injectors live in `apps/axscend_tech_test/lib/journeys/`.

## Workflow

- Never commit to `main`. One branch per task (`task/NN-short-name`), merged
  through a pull request.
- Every task starts from a prompt Alex approved in
  `docs/ai/prompts/NN-short-name.md`. Don't start a task without one. Save
  Alex's own words verbatim; put your plan under "Agent plan".
- Before opening a PR, `dart run melos run ci` must pass.
- Commits you write end with a `Co-Authored-By: Claude …` trailer.
