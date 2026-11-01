# Task 10: Fixes from testing the app

- **Status:** approved by Alex on 2026-11-01 (see below)
- **Branch:** `task/10-test-fixes`

## Alex's prompts (verbatim)

With PR #9 open, Alex asked:

> test the app

Claude tested the web build at phone and tablet widths, in light and dark,
and the iPhone simulator. It checked:

- the users list, search, sort and clearing the search;
- pull-to-refresh;
- user → albums → photos → photo, and back;
- wrong links (a non-numeric id, someone else's album, a photo from another
  album, an unknown user);
- the same page with other ids;
- the photo grid's columns.

Almost everything passed. Two real bugs turned up, and Alex answered:

> Yes, fix both

The fixes were first pushed to PR #9's branch, but Alex had already merged
PR #9, so they never reached `main`. When Alex said:

> can't see the pull request

Claude moved the two fixes into this task, on a fresh branch from `main`.

## Must

1. **Page transitions and swipe-back on iPhone.**
   - The bug: go_router 18 didn't recognise the `MaterialApp.router` as a
     Material app, even a bare one in a test. It fell back to
     `NoTransitionPage`, which has no page transition anywhere and no swipe
     from the left edge to go back on iOS.
   - The check: a widget test showed it isn't the simulator. Dragging from
     the left edge on iOS didn't go back, and the route was a
     `_CustomTransitionPageRoute`.
   - The fix: each route, and the "page not found" page, builds its page
     as a `MaterialPage` itself.
   - New tests check that the iOS edge swipe goes back and that a new page
     slides in. Both fail without the fix. Swipe-back was checked live on
     the iPhone.
2. **The search field was autocorrected.**
   - The bug: on iOS, typing "erv" offered "etc", so a name could be
     rewritten while you type.
   - The fix: `AppSearchField` has autocorrect and suggestions off.
   - A test checks it, and it fails without the fix. On the iPhone, "erv"
     now stays "erv".

## Also seen, not a bug

The backend's search covers every field, so "erv" also finds two users whose
company catchphrases contain "client-server". That is how the server search
(`q`) works. Changing it would mean filtering on the device again.

## Done when

- `dart run melos run ci` passes.
- The AI review has run on the PR, and Alex has decided every finding.

## Agent plan

1. Branch from `main` and bring over the two fixes from PR #9's branch.
2. This prompt record, then the full CI.
3. Open the PR, and remove the note added to PR #9's description after its
   merge, since PR #9 doesn't contain these fixes.
