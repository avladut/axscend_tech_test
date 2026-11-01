# Task 05: Design system (`app_ui`)

- **Status:** approved by Alex on 2026-11-01 (see below)
- **Branch:** `task/05-design-system`

## Alex's prompts (verbatim)

After PR #4 merged, Alex wrote:

> merged. Now next step. After data. Implement the presentation layer. The UI
> elements and design language reusable in a separate package, easy to
> customise. Make the UI modular, easy to reuse and change, with a consistent
> design language and theme. Use Injector for state management, blocs for
> business logic and gorouter for routing

## How Claude split it (Alex's to change)

The presentation layer is too big for one PR the AI review can read in full.
Splitting `domain` and the data package worked well, so Claude does the same
here:

- **Task 05 (this one):** the design system in `packages/app_ui`: the design
  language, the theme and the reusable widgets. It knows nothing about the
  domain.
- **Next tasks:** the app itself, built from `app_ui`: the get_it injectors,
  cubits for the logic, go_router typed routes, the screens, translations and
  the phone and tablet layouts.

## Goal

One package that decides how the app looks. A rebrand is a new `AppBrand`,
and restyling a component is one edit in `app_ui`. No screen needs touching
for either.

## Must

- **The flow from flutter-standards:** `AppBrand` → tokens → `AppTheme` →
  `App*` components → screens. Each layer only reads from the one above.
- **`AppBrand`:** the name, a seed colour and the semantic colours. Material
  3 builds the full light and dark palettes from the seed.
- **Tokens:** spacing, insets, radii, sizes, breakpoints, plus an `AppColors`
  theme extension for what `ColorScheme` lacks (success, warning, muted
  text). Read them through `context.appColors`, `context.colors`,
  `context.textStyles` and `context.windowSize`.
- **`AppTheme.light` and `AppTheme.dark`:** a complete Material 3
  `ThemeData` with every component theme the app uses, so even raw Material
  widgets match.
- **Components,** only the ones this app needs, each wrapping the real
  Material widget. Variants are enums or named constructors, never raw
  colours or sizes:
  - layout: `AppPage`, `AppListDetailLayout` (two panes on tablets),
    `AppAdaptiveNavigation` (a bottom bar on phones, a rail on tablets);
  - content: `AppCard`, `AppListTile`, `AppAvatar`, `AppSectionHeader`,
    `AppInfoRow`, `AppTag`, `AppCheckRow`, `AppNetworkImage`,
    `AppProgressRing`;
  - controls: `AppSearchField`, `AppChoiceChips`, `AppSortButton`;
  - feedback: `AppStatusView` (loading, empty, error with retry).
- **No text of its own:** every label comes in through a parameter, so the
  app can translate it.
- **`DESIGN.md`:** the brand, principles, tokens, every component with when
  to use it, and do's and don'ts.
- **Tests:** a widget test per component (renders, callbacks fire,
  variants), and theme and token tests. The 70% coverage minimum applies.

## Out of scope

- The app's screens, routes, injectors and translations (the next tasks).
- A gallery app. flutter-standards asks for one, but the screens will show
  every component; a gallery can come later if there's time.

## Choices Claude made (Alex's to change)

- **A slim `app_ui` instead of the whole template.** flutter-standards'
  template is Aspire's kit: about 100 components and 17,000 lines. This app
  needs about 17 components. Copying the rest would be dead code that the
  review couldn't read either. The structure and names follow the template,
  so it reads the same.
- **Linted with the repo's very_good_analysis,** not the template's
  `flutter_lints`, so the whole workspace has one standard.
- **Dark mode included.** It's nearly free with a seed colour.

## Done when

- `dart run melos run ci` passes, `app_ui` included, at 70% or more.
- The AI review has run on the PR, and Alex has decided every finding.

## Agent plan

1. Brand, tokens, theme and the `BuildContext` accessors.
2. The components, each with its widget test.
3. `DESIGN.md` and README, then the full CI, then ask Alex before
   committing.
