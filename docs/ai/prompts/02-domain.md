# Task 02: Domain

- **Status:** approved by Alex on 2026-11-01
- **Branch:** `task/02-domain`

## Alex's prompts (verbatim)

Claude asked: "Shall I draft the task 02 prompt for the app, for your
approval?" Alex answered:

> Yes, draft it

Claude's first draft covered the whole data layer in one task. Claude then
suggested giving `domain` its own PR: it is small enough for the AI review to
read all of it, and Alex approves the contracts before anything implements
them. Alex answered:

> Yes, split it

The JSONPlaceholder package becomes task 03, with its own prompt.

Alex approved the domain-only draft without changes:

> create the domain layer covered by unit tests

He didn't comment on the open choices below, so they are Claude's defaults
and still his to change.

## Context

- The app shows JSONPlaceholder's related data: users, with their albums
  (and photos), posts (and comments) and todos.
- The brief grades OO/SOLID code and data relations, among other things.
- ADR 0001 gives `domain` the models, the repository contracts and the typed
  failures, in pure Dart. Task 03 implements the contracts over the API, and
  the app's screens will only ever see `domain` types.

## Goal

The contracts every later task builds on: what a user, post, comment, album,
photo and todo is, how to ask for them and their relations, and what can go
wrong.

## Must

### Models

Immutable and `Equatable`, with every field the API returns, in Dart types:

| Model | Fields |
|---|---|
| `User` | `id`, `name`, `username`, `email`, `phone`, `website`, `address`, `company` |
| `Address` | `street`, `suite`, `city`, `zipcode`, `geo` |
| `Geo` | `lat`, `lng` (as `double`) |
| `Company` | `name`, `catchPhrase`, `bs` |
| `Post` | `id`, `userId`, `title`, `body` |
| `Comment` | `id`, `postId`, `name`, `email`, `body` |
| `Album` | `id`, `userId`, `title` |
| `Photo` | `id`, `albumId`, `title`, `url`, `thumbnailUrl` (as `Uri`) |
| `Todo` | `id`, `userId`, `title`, `completed` |

### Repository contracts

One per area, so a screen depends only on what it uses (interface
segregation):

```dart
abstract interface class UserRepository {
  Future<List<User>> getUsers({bool refresh = false});
  Future<User> getUser(int id, {bool refresh = false});
}

abstract interface class PostRepository {
  Future<List<Post>> getPosts({int? userId, bool refresh = false});
  Future<Post> getPost(int id, {bool refresh = false});
  Future<List<Comment>> getComments(int postId, {bool refresh = false});
}

abstract interface class AlbumRepository {
  Future<List<Album>> getAlbums({int? userId, bool refresh = false});
  Future<Album> getAlbum(int id, {bool refresh = false});
  Future<List<Photo>> getPhotos(int albumId, {bool refresh = false});
}

abstract interface class TodoRepository {
  Future<List<Todo>> getTodos({int? userId, bool refresh = false});
}
```

- `userId` omitted means everything, for the screens that search across all
  users.
- `refresh: true` asks for fresh data, skipping any cache (pull-to-refresh).
- Each contract documents which failures it throws.

### Failures

One sealed exception type, with a case for each thing the UI must tell apart:

- **offline:** no connection, or a timeout;
- **not found;**
- **server error,** with the status code;
- **unexpected data:** the backend's answer didn't match the model.

Each carries an optional technical detail for logs. No user-facing text: the
app turns each case into a translated message, and a `switch` over the sealed
type makes the compiler check that every case is handled.

### Package rules

- No Flutter, no http, no JSON, no other workspace package.
- One barrel file exports the models, contracts and failures.

### Tests

Plain `dart test`:

- equality for every model, including the nested ones;
- the failure cases: their type, status code and detail.

## Out of scope

- The JSONPlaceholder implementation (task 03) and anything in the app.
- Sorting and filtering (a later task).
- Writing data. The API accepts writes but never keeps them, so the app is
  read-only.

## Choices Claude made in this draft (Alex's to change)

- **Comments and photos have no repository of their own.** They're only ever
  read through their post or album, so `PostRepository` and `AlbumRepository`
  serve them.
- **`refresh` is part of the contract.** It's the only way for a screen to ask
  for fresh data without knowing a cache exists.
- **No `copyWith` on the models,** even though flutter-standards lists it.
  Nothing in a read-only app changes a model, so it would be dead code.
- **`equatable` in `domain`.** It's a third-party pure Dart package, which
  ADR 0001 allows.

## Done when

- `dart run melos run ci` passes, with the new tests.
- The package rules in CLAUDE.md still hold.
- The AI review has run on the PR, and Alex has decided every finding.

## Agent plan

1. Once Alex approves, commit this draft and then the approved version, so
   the history shows the difference.
2. Add `equatable`, and `test` as a dev dependency, with `dart pub add`.
3. Write the failures, the models and the contracts, then the tests.
4. Run `dart run melos run ci`, then ask Alex before committing and pushing.
