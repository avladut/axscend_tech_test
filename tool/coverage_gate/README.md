# coverage_gate

Fails CI when a workspace package covers less than the minimum share of its
lines (70% in this repo).

```bash
dart run melos run check:test       # every package's tests, writing coverage/lcov.info
dart run coverage_gate --min 70     # the table, and exit code 1 if a package is below
```

- **Packages:** read from the `workspace:` list in the root `pubspec.yaml`, so
  a new package can't be missed.
- **What counts:** each package's own `lib/` files. Dependencies, tests and
  generated files (`*.g.dart`, `*.freezed.dart`, `app_localizations*`) don't.
- **Results:**
  - ✅ at or above the minimum;
  - ❌ below it, or with code but nothing covered (no tests);
  - ⏭️ no code yet (only `library`, `import`, `export` and `part` lines).
- **On GitHub,** the table also goes on the run's summary page, and a failure
  becomes an error annotation.
- **Known limit:** a file that no test imports isn't in the coverage report,
  so it isn't counted. A file that is imported but never run counts at 0%.
