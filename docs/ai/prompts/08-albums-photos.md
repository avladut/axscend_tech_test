# Task 08: A user's albums and their photos, with cached thumbnails

- **Status:** approved by Alex on 2026-11-01 (see below)
- **Branch:** `task/08-albums-photos`

## Alex's prompt (verbatim)

After PR #7 merged, Alex wrote:

> next step. albums, for users, and photos in the albums. make sure the
> thumbnail pictures have local caching

Claude checked the API first:

- Photos come from picsum.photos: 150 px thumbnails and 600 px photos.
  picsum sends CORS headers, so the web build can load them too.
- Every album has 50 photos.

Claude then asked four questions, and Alex picked the recommended answer to
each:

| Question | Alex's answer |
|---|---|
| How to cache thumbnails on the device | **cached_network_image**, inside `app_ui`'s `AppNetworkImage` |
| Where a user's albums open | **Their own page**: `/users/:userId/albums`, then `/users/:userId/albums/:albumId` |
| What tapping a photo does | **Opens the full photo** on its own page |
| How an album's photos load | **All 50 at once**. The memory goes to the images, which are capped instead |

## Goal

From the users list, open a user's albums, then an album's photos as a grid
of thumbnails, then one photo at full size. Every picture is saved on the
device, so it shows again without the network.

## Must

- **Local image caching in `app_ui`:**
  - `AppNetworkImage` loads through cached_network_image, so every screen
    gets the cache without knowing about it.
  - The disk cache is capped: the last 500 pictures, each kept for 30
    days.
  - The in-memory image cache is capped too, set once in `main`.
  - Each picture is decoded at the size it's shown, not its full size.
  - `AppNetworkImage` gains `onTap`, so a photo can be tapped with the
    usual ink ripple.
- **Navigation:**
  - Typed routes nested under `/users`:
    - `/users/:userId/albums`
    - `/users/:userId/albums/:albumId`
    - `/users/:userId/albums/:albumId/photos/:photoId`
  - Ids go in the path, so a deep link or a web refresh works.
  - Tapping a user, an album or a photo opens the next page. Back returns
    with the list where it was.
- **Ownership is checked.** An album that isn't the user's, or a photo that
  isn't the album's, shows "not found", so a mistyped link can't mix them up.
- **Blocs from the injector,** one per screen:
  - A generic `LoadBloc<T>` in `lib/common/` handles loading, refresh
    (`droppable()`) and failures.
  - Each screen's bloc only says how to load its data.
  - The injector registers them with `registerFactoryParam`, so each gets
    its ids.
- **Screens built from `app_ui`:**
  - **User albums:** the user's name as the header, with a count, and the
    albums as tappable rows.
  - **Album photos:** a grid of thumbnails that adds columns as the screen
    widens.
  - **Photo:** the full picture and its title.
  - Every screen has loading, failure with "Try again", and empty states,
    plus pull-to-refresh.
- **Domain and data:** `AlbumRepository.getPhoto(id)` for the photo page.
- **Translations** for every new string.
- **Tests,** to the flutter-standards bar:
  - the generic bloc and its view;
  - each bloc, including the ownership checks;
  - each View, in each state and for taps;
  - the deep links;
  - the cached image, with a fake cache;
  - the cache limits.

## Out of scope

- Two panes on tablets. The pages are the same on phones and tablets, and
  the grid uses the extra width.
- The user's posts and todos (the next tasks).
- Paging photos: an album always has 50.

## Choices Claude made (Alex's to change)

- **A generic `LoadBloc<T>`,** because the three new screens all load one
  thing, show it, and refresh it. One tested base class instead of three
  copies (open for new screens, closed for changes).
- **The app bar shows the page type** ("Albums", "Photos", "Photo"), and
  the content shows the name or title. The app bar can then show while the
  page loads.
- **The full photo uses the cache too.** Its 600 px picture is cached like
  the thumbnails.

## Found while checking

- **On the iPhone simulator, tappable thumbnails didn't fill their tiles.**
  They sat at their own 150-point size in a corner. The cause was the
  `Stack` that adds the ripple: a plain `Stack` loosens its child's size.
  It now uses `StackFit.passthrough`. A test checks that the picture gets
  its box's exact size, and it fails without the fix. The web build hid
  the bug, because the browser draws images differently.
- **The disk cache works on a device.** On the iPhone simulator, the
  thumbnails are saved as files in the app's
  `Library/Caches/app_ui_images/`. After relaunching the app and reopening
  the album, the folder was unchanged: the same files with the same times,
  so nothing was downloaded again.

## Done when

- `dart run melos run ci` passes, at 70% coverage or more.
- In the web build, the thumbnails load, a reload shows them again from the
  cache, and the pages work at phone and tablet widths.
- The AI review has run on the PR, and Alex has decided every finding.

## Agent plan

1. `app_ui`: cached `AppNetworkImage` with `onTap`, `AppImageCache` limits,
   tests and DESIGN.md.
2. `domain` and data: `getPhoto`.
3. The app:
   - `LoadBloc<T>` and `LoadStateView<T>`;
   - the albums journey: blocs, injector, screens and widgets;
   - the routes, and tapping a user.
4. Tests, the full CI, a browser check, then ask Alex before committing.
