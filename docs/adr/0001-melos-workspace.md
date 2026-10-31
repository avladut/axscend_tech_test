# 0001: Melos workspace with separate domain and data packages

- **Date:** 2026-10-31
- **Status:** accepted
- **Decided by:** Alex

## Context

- The brief asks for clean OO/SOLID code and clear data relations.
- We also want the backend to be easy to swap, and to show monorepo tooling.
- Alex's house standards keep everything in the app's `lib/journeys/`, with
  `packages/app_ui` as the only package. Other code becomes a package only when
  two apps share it. This project has one app, so splitting it is a deliberate
  exception.

## Decision

A [pub workspace](https://dart.dev/tools/pub/workspaces) (one dependency
resolution, one `pubspec.lock`), driven by Melos 8, whose configuration lives
in the root `pubspec.yaml`:

| Package | Kind | May depend on |
|---|---|---|
| `apps/axscend_tech_test` | Flutter app | all three packages (data only in the injector) |
| `packages/app_ui` | Flutter | none of ours |
| `packages/domain` | pure Dart | none of ours |
| `packages/jsonplaceholder_data` | pure Dart | `domain` |

Screens, cubits, routing and dependency injection stay in the app's journeys,
as the house standards say.

## Consequences

- **Good:** the boundaries are enforced by the pubspecs. `domain` can't import
  Flutter or http, and `app_ui` can't import the domain.
- **Good:** swapping the backend means adding a sibling package such as
  `supabase_data` and changing one line in the app's injector.
- **Good:** the pure Dart packages test with plain `dart test`, which is fast.
- **Cost:** four pubspecs and some boilerplate for a small app.
- **Cost:** JSON is parsed into data-layer types and mapped to domain models,
  even where the shapes match one to one.

## Alternatives considered

- **One package with `lib/journeys/`** (the house standard). It's simpler, but
  the boundaries would hold only by convention.
- **A package per feature.** Too fine-grained for six related resources.
- **The older `melos.yaml` setup** with `pubspec_overrides.yaml` files. Melos 7
  replaced it with pub workspaces.
