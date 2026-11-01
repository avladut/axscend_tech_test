# Task 03: Data layer

- **Status:** approved by Alex on 2026-11-01 (see below)
- **Branch:** `task/03-data-layer`

## Alex's prompts (verbatim)

After PR #2's review, Alex wrote:

> good. go to the third step. the data layer. implement it

He asked for the implementation straight away, with no separate draft. The
requirements below are the JSONPlaceholder half of the first task 02 draft,
which Alex saw before the task was split. The decisions Claude made while
building it are listed under "Choices".

## Context

- Task 02 defined the `domain` contracts: models, four repositories and the
  sealed `DataFailure`.
- The brief: data is fetched dynamically over the web, may be cached on the
  device, and must not be hard-coded.
- ADR 0001: `jsonplaceholder_data` depends on `domain` only. JSON is parsed
  into data-layer types and mapped to domain models.

## Goal

The four `domain` repositories, implemented over
`https://jsonplaceholder.typicode.com`, with an in-memory cache and every
failure typed.

## Must

- **HTTP client:** one small class over `package:http`.
  - The base URL comes through the constructor, defaulting to
    `https://jsonplaceholder.typicode.com`.
  - It has a request timeout.
  - Every network error, HTTP status and JSON problem becomes the matching
    `DataFailure`. No `http` or `FormatException` reaches the caller.
- **DTOs:** hand-written `fromJson` for each resource, mirroring the API's
  JSON exactly, each with a `toDomain()` mapping. JSON never leaves the
  package.
- **Repositories:** one per `domain` contract. Relations use the API's
  nested routes (`/users/1/posts`, `/posts/1/comments`, `/albums/1/photos`,
  `/users/1/todos`).
- **Cache:** a decorator around the client, so the repositories don't know it
  exists:
  - repeated requests in a session are answered from memory;
  - `refresh: true` fetches again;
  - when the network fails, the last good answer for that request is used;
  - the store is behind an interface, so the app can later plug in one that
    survives restarts.
- **Exports:** the repositories, the client and the cache, but no DTOs and
  nothing that exposes JSON.

## Tests

Plain `dart test`, with `MockClient` from `package:http`:

- DTO parsing for every resource, from fixtures copied from real API
  responses, including a missing field and a wrongly typed field;
- the client: success, 404, 500, no connection, timeout and invalid JSON,
  each becoming the right failure;
- each repository calls the right path and returns domain models;
- the cache: a hit, a forced refresh, and the fallback when offline.

## Out of scope

- Anything in the app (task 04 wires this in).
- A cache that survives restarts.
- Sorting and filtering.

## Choices Claude made (Alex's to change)

- **A `JsonPlaceholderBackend` facade** builds the client, the cache and the
  four repositories. The app's injector creates it once, so swapping the
  backend really is one line.
- **The cache falls back on offline and server errors only.** "Not found" and
  bad data are real answers, and serving old data would hide them.
- **No expiry.** JSONPlaceholder never changes, and a session-long memory
  cache plus pull-to-refresh is enough. Expiry belongs with a persistent
  store.
- **DTOs keep the API's types.** For example, `lat` and `lng` arrive as
  strings and become `double` in `toDomain()`, and a value that doesn't parse
  is an `UnexpectedDataFailure`.
- **A last-resort catch in the client.** `package:http` wraps socket and HTTP
  errors in `ClientException`, but a TLS failure would get through, so any
  other `Exception` also counts as offline. `Error`s still crash, because
  they are bugs.

## Done when

- `dart run melos run ci` passes, with the new tests.
- The package rules in CLAUDE.md still hold.
- The AI review has run on the PR, and Alex has decided every finding.

## Agent plan

1. Fetch a few real items from each endpoint once, and save them as test
   fixtures.
2. Build the client, the DTOs, the repositories, the cache and the facade,
   each with its tests.
3. Run `dart run melos run ci`, then ask Alex before committing and pushing.
4. Before the PR, rebase onto `main` once PR #2 is merged, so this PR shows
   only the data layer.
