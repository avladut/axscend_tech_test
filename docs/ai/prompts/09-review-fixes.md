# Task 09: Fixes from a full code review

- **Status:** approved by Alex on 2026-11-01 (see below)
- **Branch:** `task/09-review-fixes`

## Alex's prompts (verbatim)

After PR #8 merged, Alex wrote:

> review the code again, all of it, see if there's any issue and make a
> diagram of the app calls and architecture

Four reviewers worked in parallel, one per area: the app, `app_ui` with
`domain`, the data package, and the dev tooling with CI. Each started
fresh, without Claude's conclusions. Claude re-checked the main findings
against the code, including go_router's source, before reporting. The
architecture and the call flow for opening an album were drawn as two
diagrams in the chat.

The review found nothing high-severity, and the package rules hold. Claude
listed eleven fixes worth making before submission, and Alex answered:

> Yes, fix the top list

## Goal

Fix the eleven issues below, each with a test that fails without its fix.

## Must

**The app and its packages:**

1. **Same page, other ids.** go_router keys a page by its route pattern,
   so going from `/users/1/albums` to `/users/2/albums` without leaving the
   page reused the old screen and its bloc. On web, the browser's history
   or an edited address could show user 1's albums under user 2's link.
   Each screen is now keyed by its ids.
2. **A refresh refreshes every page.** After a pull-to-refresh, later pages
   came from the old cache. Pages of a refreshed list now skip the cache
   too.
3. **Only answers that parse are cached.** The cache saved an answer
   before the repository checked its shape, so one malformed answer
   replaced the last good one. The client now parses first and saves only
   what parsed. A page without its total is never saved.
4. **The search field shows focus.** It looked the same when focused
   (WCAG 2.4.7). It now gets a primary-coloured border.
5. **Readable tags.** Success and warning tags had about 4:1 and 3.3:1
   contrast, below the 4.5:1 minimum. They now use the matching "on
   container" colours, in light and dark.
6. **A failed search keeps the search field.** The error used to replace
   the whole screen, so you couldn't clear the search. The error now shows
   in the list area only.
7. **Paging during a search change.** For the 300 ms before a search runs,
   page requests used the new query but filled the old list. Pages now use
   the query of the list on screen.
8. **Placeholder rows match real rows.** A subtitle could wrap to two
   lines, which made rows taller than their placeholders. List subtitles
   are now one line.

**The AI reviewer:**

9. **Skipped work isn't marked as reviewed.** When a part got no answer,
   the review still marked the head commit as reviewed, so those files were
   never reviewed again. The marker now stays at the last fully reviewed
   commit.
10. **A deadline the job can meet.** The worst case was about 32 minutes,
    but the job is killed at 15, before it can say the model was
    unavailable. A run now stops starting parts after 12 minutes and posts
    what it has. The job gets 25 minutes.
11. **Main's reviewer reviews a PR.** The job ran the PR's own copy of the
    reviewer and its prompt, so a PR could weaken its own review. The job
    now runs main's copy and only reads the PR's commits as data.

**Found while testing,** after Alex asked:

> test the app

The web build at phone and tablet widths, in light and dark, and the iPhone
simulator. Almost everything passed. Two real bugs turned up, and Alex
answered "Yes, fix both":

12. **No page transitions, and no swipe-back on iPhone.** go_router 18
    didn't recognise the `MaterialApp.router` as a Material app, even a
    bare one in a test. It fell back to `NoTransitionPage`, which has no
    transition and no iOS edge swipe. A widget test showed it isn't the
    simulator: dragging from the left edge on iOS didn't go back. Each
    route now builds its page as a `MaterialPage` itself, and so does the
    "page not found" page. New tests check the swipe on iOS and the slide
    in on a new page.
13. **The search field was autocorrected.** On iOS, typing "erv" offered
    "etc". A name could be rewritten while you type. The field now has
    autocorrect and suggestions off.

Also seen, and not a bug: the backend's search covers every field, so "erv"
also finds two users whose company catchphrases contain "client-server".

## Out of scope

These go on the list for after submission:

- the model's odd-shaped answers showing as "no findings";
- an unpaired backtick or `@` slipping through in posted text;
- the progress ring at 0 of 0 (this comes with the todos screen);
- the photo title read twice by screen readers;
- the two weaker bloc tests;
- design tokens split across lines;
- the coverage gate's known limit.

## Choices Claude made (Alex's to change)

- **Parsing moves into the client (item 3):** `get` and `getPage` take an
  optional `parse` callback, so the cache can tell a good answer from a bad
  one. The repositories pass their DTO parsing.
- **One-line subtitles (item 8),** instead of placeholders that guess
  whether a row will wrap. A long subtitle ends with "…".
- **A failed load always keeps the search field (item 6),** not only
  during a search. The screen is the same shape in every state.
- **What a PR can still change (item 11):** the workflow file itself still
  comes from the PR, because GitHub runs `pull_request` workflows that way.
  Changing it is visible in the diff, and only Alex merges.

## Done when

- `dart run melos run ci` passes.
- Each fix has a test that fails without it.
- The AI review has run on the PR, and Alex has decided every finding.

## Agent plan

1. The app: keyed screens, refreshed paging, the shown list's query, and
   the failure inside the list area.
2. Data: `parse` through the clients, and no saved page without a total.
3. `app_ui`: focus border, container text colours, one-line subtitles.
4. The reviewer: the marker, the deadline, main's checkout.
5. Tests for each, the full CI, then ask Alex before committing.
