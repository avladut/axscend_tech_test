# Design language

`app_ui` is the single source of truth for how the app looks. Screens never
set a colour, font size, spacing or radius themselves: they use the tokens
and components here. Update this file in the same commit as any token or
component change.

```
AppBrand → tokens → AppTheme → App* components → screens
```

Each layer only reads from the one above it. A rebrand is a new `AppBrand`.
Restyling every card is one edit in `AppCard` or the card theme.

## 1. Brand

The app passes its brand once, to `AppTheme.light(brand)` and
`AppTheme.dark(brand)`.

| Field | What it decides |
|---|---|
| `name` | The product name in titles. |
| `seed` | Material 3 builds the whole light and dark palette from it: primary, containers, surfaces, outlines. |
| `success` | Done, complete (ticked todos, the progress ring). |
| `warning` | Pending, needs attention. |
| `fontFamily` | Null uses the platform font. |

## 2. Principles

- **Content first.** Quiet surfaces and outlines instead of shadows, so names,
  titles and photos carry the page.
- **4-point rhythm.** Every gap is an `AppSpacing` step.
- **One meaning, one colour.** Success is always the brand's `success`, and a
  tag's colour comes from its `AppTone`, never from a hex value.
- **Adaptive, not stretched.** Phones get one pane and a bottom bar. Tablets
  get a rail and two panes. Long text never runs wider than
  `AppSizes.maxContentWidth`.
- **Light and dark from the same brand.** Nothing is drawn for one brightness
  only.
- **Accessible by default.** Avatars are decorative, headers are marked as
  headers, done states and progress are announced, and icon buttons have
  tooltips.
- **No text of its own.** Every label comes in through a parameter, so the
  app translates it.

## 3. Tokens

Read them in widgets through `BuildContext`:

| Accessor | Gives |
|---|---|
| `context.colors` | The Material 3 `ColorScheme` built from the seed. |
| `context.appColors` | What `ColorScheme` lacks: `success`, `warning` (each with `on…` and `…Container`), and `muted` for secondary text. |
| `context.textStyles` | The Material 3 type scale (`titleMedium`, `bodyLarge`, …). |
| `context.windowSize` | `compact`, `medium` or `expanded`, from the window width. |

| Token | Values |
|---|---|
| `AppSpacing` | `xxs` 2, `xs` 4, `sm` 8, `md` 12, `lg` 16, `xl` 24, `xxl` 32 |
| `AppInsets` | `page` and `card` (16 all round), `listItem` (16 × 4), `section` (above a section header) |
| `AppRadius` | `sm` 8 (chips, tags), `md` 12 (cards, tiles, images), `lg` 16 (search field); each also as `borderSm`/`borderMd`/`borderLg` |
| `AppSizes` | icons 16/20/48, avatars 32/40/72, progress ring 48, `maxContentWidth` 720, `listPaneWidth` 360, `gridTileMinWidth` 140 |
| `AppBreakpoints` | `medium` from 600, `expanded` from 840 (Material 3 window classes) |
| `AppTone` | `neutral`, `brand`, `success`, `warning` |

## 4. Components

### Layout

| Component | Use it for |
|---|---|
| `AppAdaptiveNavigation` | The top-level destinations: a `NavigationBar` on phones, a `NavigationRail` from 600 wide. Needs 2+ `AppDestination`s. |
| `AppListDetailLayout` | A list and the item picked from it: side by side from 840 wide (with `emptyDetail` until something is picked), one at a time below. |
| `AppPage` | A page body: centred, at most `maxContentWidth`, with page padding. |

### Content

| Component | Use it for |
|---|---|
| `AppListTile` | A row in a list. A tappable row gets a chevron unless it has its own `trailing`; `selected` marks the row open in the detail pane. |
| `AppListTilePlaceholder` | Stands in for an `AppListTile` with an avatar and subtitle while its data loads, at the same height. Give it a `semanticLabel` ("Loading user"). Still, with no shimmer. |
| `AppCard` | One item that needs a surface: a post, a comment. Tappable with `onTap`. |
| `AppAvatar` | A person's initials (`sm`, `md`, `lg`). Same name, same colour. Decorative next to a name; give it a `semanticLabel` when it stands alone. |
| `AppSectionHeader` | The title of a group, with an optional count tag and action (such as a sort button). |
| `AppInfoRow` | A labelled value with an icon, such as an email. Tappable with `onTap`. |
| `AppTag` | A count or status in a pill. The `AppTone` sets the colours. |
| `AppCheckRow` | A todo: ticked, muted and struck through when done. Read-only. |
| `AppNetworkImage` | A photo from the web, with a placeholder while loading and a broken-image icon on failure. Always needs a `semanticLabel`. |
| `AppProgressRing` | How much is done (0 to 1), with the percentage inside. |

### Controls

| Component | Use it for |
|---|---|
| `AppSearchField` | Searching a list. The clear button shows once something is typed, and the field follows `value` when the app resets it. |
| `AppChoiceChips<T>` | Picking one filter out of a few, such as All, Done or Pending. |
| `AppSortButton<T>` | Picking a sort order from a menu, with the current one ticked. |

Both choice controls take `AppChoice(value:, label:)` options.

### Feedback

| Component | Use it for |
|---|---|
| `AppStatusView.loading` | While a screen's data loads. Its `title` ("Loading users…") is required, so screen readers announce it. |
| `AppStatusView.empty` | Nothing to show, such as no search results. |
| `AppStatusView.error` | Something went wrong, with an `actionLabel` and `onAction` when trying again could help. |

## 5. Do and don't

- **Do** add a variant (an enum value or a named constructor) when a screen
  needs a new look. **Don't** pass raw colours or sizes into a component.
- **Do** use `AppStatusView` for every loading, empty and error state, so
  they look and read the same everywhere.
- **Don't** put domain types (users, posts) in `app_ui`. Data comes in as
  plain values, and events go out through callbacks.
- **Don't** add endless animations other than the loading spinner. Tests rely
  on `pumpAndSettle` finishing.
- **Do** add a widget test with every new component. `app_ui` is held to
  the repo's 70% coverage minimum like every package.
