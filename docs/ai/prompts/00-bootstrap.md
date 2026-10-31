# Task 00: Project setup

- **Date:** 2026-10-31
- **Agent:** Claude Code (Claude Opus 5.5)
- **Result:** the first commit on `main`, before branch protection was turned on

## Alex's prompts (verbatim, in order)

The earlier messages were planning. Claude only proposed options there; nothing
was built until message 4.

1. *(with the task brief attached)*
   > I have an interview tech task we need to make for tomorrow evening. Don't
   > start work, just give me ideas. what do you think?

2. > okay. sirst, I need a pipeline and a code review tool. for merge requests
   > in the main branch. using the local Ai to do reviews to your code. That
   > would be cool, I guess. Planning to get it there bit by bit, creating it
   > one task at a time. Since AI use is accepted as per the document, I will
   > need to show good use of AI. can it be done? suggest a way. my idea is to
   > split it into a clean architecture, modular, and give prompts for each
   > steps

3. > good, I want control of the prompts. let's setup an initial repository at
   > the moment. and a pipeline on github action if it can handle this. a basic
   > empty folder structure. before you act, how should the packages be
   > managed? I would rather use melos to separate UI components from business
   > logic in a core UI package, do you think it's a good idea? also, to make
   > the backend easy to swap. Just to show I can work with Melos

4. > set up the basic pipeline and repository, melos, default project,
   > gitignore

5. *(before the first push)*
   > why name the repo so terrible? change the project name to
   > axscend_tech_test

## What Claude proposed (summary)

- **Message 1:** an app built around users (profile tabs for posts, albums
  and todos, plus an Explore tab for search, sort and filter), a list-detail
  layout on tablet, and an offline cache. It also found that every user has
  the same number of posts, albums and todos, so sorting by a count would show
  nothing.
- **Message 2:** CI on every PR into `main`, plus a review bot on Alex's own
  model server that comments on PRs but never blocks them. The app is then
  built as a series of small PRs, each with its own prompt.
- **Message 3:** Melos 8 on top of pub workspaces, with three packages and the
  app. This breaks the house standard of "only `app_ui` is a package", so the
  reason is recorded in [ADR 0001](../../adr/0001-melos-workspace.md).

## Agent plan (what message 4 produced)

- The workspace root `pubspec.yaml`, which also holds the Melos scripts:
  `check:format`, `check:analyze`, `check:test`, and `ci` to run all three.
- `apps/axscend_tech_test` from `flutter create` (Android, iOS, web), with empty
  `lib/app`, `lib/common` and `lib/journeys` folders.
- The empty `app_ui`, `domain` and `jsonplaceholder_data` packages, with their
  dependency rules already in the pubspecs.
- One shared `analysis_options.yaml` (very_good_analysis), and a `.gitignore`.
- `.github/workflows/ci.yml` runs the same Melos scripts on every PR and every
  push to `main`.

## Decisions Claude made along the way (for Alex to check)

- **Naming (message 5):** Claude had picked `jsonplaceholder-explorer`. The
  repo, folder and app are now `axscend_tech_test`. The app was regenerated
  with `flutter create` so the Android and iOS ids match:
  `net.poseidonapps.axscend_tech_test`, and `net.poseidonapps.axscendTechTest`
  on iOS, which doesn't allow underscores. The workspace root is
  `axscend_tech_test_workspace`, because two workspace packages can't share a
  name.

- **Commit email:** the GitHub noreply address, set for this repo only, so a
  public repo doesn't show a personal email.
- **CI hardening:** actions pinned to commit SHAs, minimal permissions,
  `persist-credentials: false`, and `pub get --enforce-lockfile`.
- **Melos scripts:** they call `dart run melos …`. In Melos 8.10, `steps`
  only recognise some built-in commands (`format` works, `analyze` and `test`
  don't), so this is the reliable way, and it needs no global install.
- **New constructor syntax:** `dart fix` rewrote the default app's
  constructors to Dart 3.13's `const new(...)` form, because the current
  very_good_analysis asks for it.
