# Task 07: The users screen, with routing and DI

- **Status:** approved by Alex on 2026-11-01 (see below)
- **Branch:** `task/07-users-screen`

## Alex's prompt (verbatim)

After PR #6 merged, Alex wrote:

> merged. Now, let's continue with screens and routing. Start with the main
> screen, listing users from the api. Use injector to create bloc instances
> and Bloc for state management. Add gorouter to manage routing/navigating

Before the first commit, Alex added:

> before committing, make sure you use the listview.builder method, as it is
> a dynamic list. Also, make sure the list only keeps in memory a limited
> number of users, as too many can overflow the memory

The list already used `ListView.builder`, which only builds the rows on
screen. The data was the gap: the bloc held every user, and the HTTP cache
held every answer. Claude checked that JSONPlaceholder pages (`_page`,
`_limit`, `X-Total-Count`), sorts (`_sort`, `_order`) and searches (`q`) on
the server. Claude offered three options: pages with a memory cap, pages
with no cap, or no change. Alex picked **pages with a memory cap**:

- Pages of 20 are fetched as you scroll, with search and sort done by the
  server.
- At most 3 pages (60 users) stay in memory. A page far from the screen is
  dropped, and fetched again when you scroll back to it.
- Typing in the search waits 300 ms and cancels the search it replaces.
- The HTTP cache keeps the last 50 answers.
- The header count comes from `X-Total-Count`.

## Goal

The app's frame plus its first screen. The app starts on a list of users
loaded from JSONPlaceholder, which you can search, sort and pull to refresh.
Everything later builds on this frame: the get_it injector, the typed
go_router routes, translations and the Screen/View split.

## Must

- **get_it injector:**
  - `lib/injector.dart` is the only file that imports `jsonplaceholder_data`.
    It registers the backend's repositories under their `domain` interfaces.
  - `UsersInjector` registers `UsersBloc` as a factory, so each screen gets a
    fresh bloc that closes with it.
- **Bloc for state management:**
  - `UsersBloc` reacts to four events: load (or refresh), search changed,
    sort changed, and a page needed.
  - The first three start the list again from page one. They share
    `restartable()`, so a newer one cancels an older one still running, and
    an old answer never overwrites a newer list.
  - Search waits for typing to pause (300 ms) before asking the backend.
  - Pages load side by side, each fetched once at a time. An answer that
    arrives after the list changed is dropped.
- **A memory limit (Alex's addition):**
  - A reusable `PagedWindow` in `lib/common/paging/` keeps at most 3 pages
    of 20 users. Adding a page drops the one farthest from it.
  - A row whose page isn't in memory shows an `AppListTilePlaceholder` and
    asks for its page. A page that failed shows "Try again" rows.
  - `ListView.builder` builds only the rows on screen.
  - The HTTP cache keeps the last 50 answers (least recently used goes
    first).
- **Domain and data changes for paging:**
  - `domain` gains `PageRequest`, `ResultPage`, `UserQuery` and `UserSort`,
    and `UserRepository.getUsersPage`.
  - `JsonClient` gains `getPage`, which passes query parameters and reads
    the total from `X-Total-Count`. The cache keeps each query apart.
- **go_router:**
  - Typed routes (go_router_builder), with the generated file committed.
  - `/users` is the start page, and `/` redirects there. The redirect is a
    pure function with its own test.
  - An unknown address shows a "page not found" screen with a way back to
    the users.
- **The users screen:**
  - A `UsersScreen` provides the bloc from the injector. A `UsersView`
    renders the state, so tests can pump it with a mock bloc.
  - It is built only from `app_ui` components: a search field, a sort menu,
    a section header with the count, and tiles with avatars.
  - Loading, error (with "Try again"), no users and no matches each show an
    `AppStatusView`.
- **Search** is the backend's full-text search (`q`), ignoring case.
- **Sorting** is done by the backend (`_sort`, `_order`): name A to Z, name
  Z to A, company and city.
- **Translations:** `flutter gen-l10n`, with every string in an ARB file
  from day one. `DataFailure`s are turned into translated messages in one
  place, with a switch the compiler checks covers every case.
- **Tests,** to the flutter-standards bar:
  - bloc tests for every event and failure, the dropped stale answers and
    the 60-user limit while scrolling through 1,000 users;
  - unit tests for the window, the paging models, the query parameters, the
    total header and the cache limit;
  - View tests for each state and interaction;
  - the redirect and the not-found page;
  - the injector's registrations.

## Out of scope

- The user detail screen and the posts, albums and todos screens (the next
  tasks). The user tiles aren't tappable yet.
- A second language and an in-app language switch.
- The tablet list-detail layout, which comes with the detail screen. Until
  then, the list is centred and capped at the readable width on tablets.

## Choices Claude made (Alex's to change)

- **A Bloc, not a Cubit,** as Alex asked. The events earn their place:
  `restartable()` lets a newer search or sort cancel an older one, and the
  search waits for typing to pause.
- **"Try again" on a page that failed,** not an automatic retry. A row that
  keeps asking for a failing page would hammer the backend.
- **The placeholder row's bars are one text line tall** (an invisible space
  sets the height). So a placeholder is as tall as the row it stands for at
  any text size, and the list doesn't jump when a page arrives.
- **The state carries the typed failure, not a message.** flutter-standards
  puts a user-safe message in the state. With translations, the bloc can't
  know the language, so the View turns the failure into text.
- **The design-token check** from flutter-standards
  (`tool/check_design_tokens.sh`) joins the `checks` job. It is the first
  feature code, so the rule "all visual values come from app_ui" is enforced
  from the start.
- **The single-source check isn't copied.** Its table names Aspire's
  components (`AppLoader`, `showAppSnackBar` and others), which this app's
  slim `app_ui` doesn't have.
- **A fix in `app_ui`,** found in the visual check. `AppSectionHeader`
  showed its action (the sort button) in the middle of the row, because the
  title's `Flexible` and the `Spacer` split the free space between them. The
  action now sits at the far end, and a new test checks that.
- **The brand** is a placeholder: the name "JSONPlaceholder Explorer" and an
  indigo seed. It is one line in `lib/app/brand.dart`.

## Done when

- `dart run melos run ci` passes, including the token check and the 70%
  coverage minimum.
- The app runs and shows the users at phone and tablet widths.
- The AI review has run on the PR, and Alex has decided every finding.

## Agent plan

1. Add the packages: flutter_bloc, bloc_concurrency, equatable, get_it,
   go_router, intl and flutter_localizations, plus go_router_builder,
   build_runner, bloc_test and mocktail for development.
2. The frame: the injector, brand, `App`, the router with the redirect and
   the not-found page, l10n, and the failure messages.
3. The users journey: the sort and query models, the bloc, its injector,
   then the Screen and View.
4. The tests, then the token check in Melos and CI.
5. The full CI, a visual check at phone and tablet widths, then ask Alex
   before committing.
