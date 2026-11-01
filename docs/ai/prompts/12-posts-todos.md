# Task 12: A user's profile, posts with comments, and todos

- **Status:** approved by Alex on 2026-11-01 (see below)
- **Branch:** `task/12-posts-todos`

## Alex's prompt (verbatim)

Alex asked Claude to make his submission email more professional. Claude
pointed out a gap: the email said the task was finished, but the app had no
posts, comments or todos screens, and the README said they "come next".
Claude asked whether to build them before sending, and Alex answered:

> Yes, build them

## Goal

Every part of the brief is reachable from a user:

- their profile and contact details;
- their albums (already built);
- their posts, each with its comments;
- their todos, with a filter and their progress.

## Must

- **A profile page** at `/users/:userId`, which tapping a user now opens:
  - the avatar, name and username;
  - email, phone and website;
  - the address;
  - the company and its catchphrase.
  - Three rows lead on: **Posts** (with a count), **Albums** (with a count)
    and **Todos** (how many are done, with a progress ring).
- **Posts** at `/users/:userId/posts`, a list of the user's posts. Tapping
  one opens `/users/:userId/posts/:postId`: the post, then its comments.
  A post that isn't that user's is "not found".
- **Todos** at `/users/:userId/todos`:
  - All, Done and Pending chips, each with its count;
  - the share done as a ring;
  - each todo as a check row.
- **Routes:** the albums routes move under the profile, so back from a
  user's albums returns to their profile. The URLs don't change.
- **Lists** use `ListView.builder`.
- **Every screen** has loading, failure with "Try again", empty states and
  pull-to-refresh. Each is built on the existing `LoadBloc<T>` and
  `LoadStateView<T>`.
- **Blocs come from the injector:** one injector per journey (posts,
  todos), and the profile in the users journey.
- **Translations** for every new string, with plural forms for the counts.
- **The progress ring at 0 of 0** shows 0%, not 100%. Dart's `clamp` turns
  NaN into 1.0. The full code review found this, and it waited until the
  todos screen.
- **Tests,** to the flutter-standards bar:
  - each bloc, including the ownership check;
  - each View in each state, and for taps and the filter;
  - the deep links;
  - the injector;
  - the ring at 0 of 0.

## Out of scope

- A second language and an in-app language switch.
- Two panes on tablets.
- The README's status line, because PR #11 changes the same lines. It's
  updated once both are merged.

## Choices Claude made (Alex's to change)

- **A profile page as the hub,** rather than tabs. Each section has its own
  URL, so a deep link opens it directly, and back goes one level up.
- **The todos filter is View state,** not bloc state. It only decides which
  of the 20 loaded todos are shown, and needs no backend call.
- **The profile loads the user's posts, albums and todos** to show their
  counts. They're cached, so opening any of them afterwards is instant.

## Done when

- `dart run melos run ci` passes, at 70% coverage or more.
- The screens work in the app at phone and tablet widths.
- The AI review has run on the PR, and Alex has decided every finding.

## Agent plan

1. The progress ring fix in `app_ui`.
2. The profile in the users journey, then the posts and todos journeys:
   models, blocs, injectors, screens and widgets.
3. The routes nested under `/users/:userId`, and tapping a user opens the
   profile.
4. Strings, tests, the full CI, and a check in the app, then ask Alex
   before committing.
