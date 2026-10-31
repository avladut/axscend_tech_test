# Task 01: AI review bot

- **Status:** DRAFT. Claude drafted it at Alex's request; Alex edits and
  approves it before any work starts.
- **Branch:** `task/01-ai-review`
- **Timebox:** 2 hours. If the bot isn't posting comments by then, merge what
  works (CI stays green) and move on to the app.

## How this prompt was made

Claude asked: "Should I draft the task 01 prompt (the AI review bot) for you
to edit?" Alex answered, verbatim:

> Yes, draft it

## Context

- Claude Code writes the code. A second model, of a different family, reviews
  every pull request into `main`: Qwen3.8-Flash-Next, on Alex's self-hosted
  model server. It exposes an OpenAI-compatible API behind a per-project key.
- The review is **advisory**. It never blocks a merge; Alex decides what to
  apply and records why the rest was rejected.
- The repo is public, so the server's address and key never appear in it.

## Goal

Every PR into `main` gets one review comment from the self-hosted model, and
that comment is updated on every new push.

## Must

### The tool: `tool/ai_review/`

- A pure Dart command-line package, added to the workspace so Melos analyzes
  and tests it with everything else. The app never depends on it.
- Small parts, injected through constructors:
  - `DiffSource`: git diff of the PR against its merge base.
  - `ReviewModel`: the OpenAI-compatible chat client.
  - `ReviewParser`: turns the model's answer into findings.
  - `ReviewPublisher`: one implementation posts to GitHub, another prints to
    the console.
  - `ReviewService`: wires the parts together.
- **Diff:** include Dart, YAML and Markdown. Exclude `pubspec.lock`, generated
  files (`*.g.dart`, generated l10n) and the `android/`, `ios/` and `web/`
  folders.
- **Large diffs:** cap the size sent to the model. When over the cap, review
  the biggest files first and list what was skipped.
- **The reviewer's instructions** live in `tool/ai_review/prompts/system.md`,
  committed and readable. They cover:
  - correctness;
  - the package rules in CLAUDE.md;
  - flutter-standards (layers, tokens, typed routes, error handling);
  - missing tests;
  - security.

  The reviewer comments only on changed lines, and says when it's unsure.
- **Model output:** JSON with `summary` and up to 10 `findings`. Each finding
  has `severity` (blocker, major, minor or nit), `file`, `line`, `title`,
  `detail` and an optional `suggestion`.
  - Validate it.
  - If the JSON is invalid, post the raw text with a warning instead of
    failing.
- **Calling the model:** stream the response, because the server's tunnel cuts
  off requests at about 100 seconds. Use low temperature, an overall timeout,
  and one retry.
- **The comment:**
  - One sticky comment, found by a hidden marker and edited in place.
  - Shows the model name, the commit it reviewed, and how long it took.
  - Ends with a line saying it's advisory.
- **Local mode:** `--print` writes the review to the terminal instead of
  GitHub, so Alex can run it on his Mac before pushing.

### The workflow: `.github/workflows/ai-review.yml`

- **Trigger:** `pull_request` into `main` (opened, synchronize, reopened,
  ready for review), skipping draft PRs.
  - Never use `pull_request_target`.
  - It isn't a required check.
- **Permissions:** `contents: read` and `pull-requests: write` only.
- **Fork PRs:** skip them, since they get no secrets. The job ends green with
  a notice saying it was skipped.
- **Config:**
  - Secrets: `AI_REVIEW_BASE_URL` and `AI_REVIEW_API_KEY`.
  - Repository variable: `AI_REVIEW_MODEL`.
  - Never print any of them.
- **Hardening:**
  - Pin actions to commit SHAs, as in `ci.yml`.
  - Pass PR data to the tool through environment variables, never by
    interpolating it into shell commands.
  - Cancel the run that's out of date when a PR gets a new push.
- **If the model server is down or times out,** post "AI review unavailable"
  and end green.

### Safety

- Treat the diff as untrusted data. The model gets no tools, and its output
  only ever becomes a comment.
- Neutralise `@mentions` in the model's output, so a review can't ping anyone.
- The bot only comments. It never approves, requests changes or merges.

### Tests

Unit tests with fakes, plus `MockClient` from `package:http` for the client:

- diff filtering and the size cap;
- prompt building;
- parsing: valid, invalid, extra fields, and more than 10 findings;
- streaming response parsing;
- comment formatting and finding the sticky comment;
- the service's failure paths: server down, bad JSON, empty diff.

## Out of scope

- Comments on individual lines (a possible v2).
- Blocking merges on the review.
- Auto-fixing findings.
- Running the review as a git hook.

## Setup that needs Alex's yes (Claude asks at the time)

1. **Key:** create a `pr-review` key on the model server, restricted to the
   flash model only.
2. **Secrets:** store the key and the base URL as GitHub Actions secrets, using
   a command that reads the key from its file, so nothing goes through the
   clipboard.

## Done when

- `dart run melos run ci` passes, including the new package's tests.
- This task's own PR gets a review comment from the bot.
- A second push to it updates that comment instead of adding a new one.
- With the server unreachable, the job ends green with the "unavailable"
  comment.
- `--print` works on Alex's Mac.
- The README says how the review works and that it's advisory.

## Open choices (Alex: decide, then delete this section)

- **Language:** Dart (shows the skill the test is about) or Python (quicker to
  write). This draft assumes Dart.
- **Findings cap:** is 10 per review right?
- **Story models:** if a story model is loaded on the server when a review
  runs, flash gets swapped back in and the story ends. Accept that for this
  sprint, or have the tool wait and retry?

## Agent plan

*(Claude fills this in once the prompt is approved.)*
