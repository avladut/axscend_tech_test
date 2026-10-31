# Task 01: AI review bot

- **Status:** approved by Alex on 2026-10-31. He added requirements and
  corrections afterwards (see "Alex's prompts"), and Claude updated the task
  to match each one.
- **Branch:** `task/01-ai-review`

## Alex's prompts (verbatim)

Claude asked: "Should I draft the task 01 prompt (the AI review bot) for you
to edit?" Alex answered:

> Yes, draft it

Alex then asked two questions off the record, about how the review works and
whether it could expose an API key. After that he approved the draft and added
a requirement:

> okay. Back on the record. Write and test reviewer tool, then commit it. I
> will inspect the MR reviews personally before approving them, any comment
> needs to have a human reviewer accepting it or asking for changes (me)

Alex didn't comment on the draft's open choices, so Claude went with its own
defaults: Dart, at most 10 findings, and accepting that a review may swap out
a story model on the server. They are Alex's to change.

After the PR was opened, Alex turned on the app's Auto-fix, which wakes
Claude on CI failures and new review comments. He set this condition:

> turn on auto fix but the final decision is mine, I need to see the issues
> discussed

CLAUDE.md now spells out what that means. Claude discusses each finding in
its thread and changes code only after Alex decides.

Before merging, Alex asked:

> I want the commits squashed, one commit per mr/problem solved

The repo now allows only "Squash and merge". The PR title becomes the commit
title, and the commit messages, `Co-Authored-By` lines included, become its
body. The PR itself keeps the step-by-step commits, such as draft → approved
prompt.

Alex then corrected the draft. He quoted a line Claude had written into it
and replied:

> > - **Timebox:** 2 hours. If the bot isn't posting comments by then, merge
> >   what works (CI stays green) and move on to the app.
>
> I never asked or agreed to this rule. I decide the commits. If the review
> bot  has no comments, it should mention it

and added:

> mention my change in the logs

The timebox came from Claude's own planning notes, not from Alex, and should
never have read like an agreed rule. What changed:

- The timebox is removed. Alex decides what gets committed and merged.
- The sentence about the open choices (above) now says plainly that Alex
  didn't choose them.
- The bot is never silent. Every run leaves a visible note on the PR, even
  when it has nothing to comment on (see "The review on GitHub").

## Context

- Claude Code writes the code. A second model, of a different family, reviews
  every pull request into `main`: Qwen3.8-Flash-Next, on Alex's self-hosted
  model server. It exposes an OpenAI-compatible API behind a per-project key.
- The review is **advisory**. It never blocks a merge or approves anything.
  **Every finding needs a human decision from Alex** before the PR can merge.
- The repo is public, so the server's address and key never appear in it.

## Goal

Every PR into `main` gets a review from the self-hosted model. Each finding
is a separate conversation that Alex accepts or rejects.

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
- **The review on GitHub** (changed for Alex's requirement):
  - Each run posts one GitHub PR review with `event: COMMENT`. Its body holds
    the summary, the model name, the commit reviewed and how long it took.
  - **Every finding is its own review thread:** on the line when the line is
    in the diff, otherwise on the file. Findings without a valid file go on
    the first reviewed file, marked "General".
  - Branch protection requires every conversation to be resolved before
    merging. Alex replies to each thread (accept or ask for a change) and
    resolves it.
  - **Later pushes are reviewed incrementally:** only the commits since the
    last reviewed one, so earlier findings aren't repeated. After a force-push
    or rebase, it falls back to the full PR.
  - The body ends with a line saying the bot is advisory and Alex decides.
  - **It is never silent** (Alex's correction). Every run posts one of these:
    - "no findings";
    - "nothing to review" (only files it skips changed);
    - "already reviewed";
    - "unavailable";
    - "not configured".
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
  - With no secrets set, the job ends green with a notice.
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
- Neutralise `@mentions` and HTML comments in the model's output, so a review
  can't ping anyone or fake the tool's hidden markers.
- **Only Alex resolves threads, approves or merges.** The bot never does, and
  neither does Claude, even though Claude works with Alex's GitHub access.
  This rule goes in CLAUDE.md.

### Tests

Unit tests with fakes, plus `MockClient` from `package:http` for the client:

- diff parsing and filtering, and the size cap;
- prompt building;
- parsing: valid, invalid, extra fields, and more than 10 findings;
- streaming response parsing, retry, and the server being down;
- where each comment is placed (line, file or general);
- formatting and the safety filters;
- GitHub publishing, including the fallback when GitHub rejects a line
  comment;
- the service: incremental review, full review, nothing new, empty diff, and
  the server being down;
- one real-git test of the diff source in a temporary repo.

## Out of scope

- Blocking merges on the review.
- Auto-fixing findings.
- Running the review as a git hook.

## Setup that needs Alex's yes (Claude asks at the time)

1. **Key:** create a `pr-review` key on the model server, restricted to the
   flash model only.
2. **Secrets:** store the key and the base URL as GitHub Actions secrets, using
   a command that reads the key from its file, so nothing goes through the
   clipboard.
3. **Branch protection:** turn on "require conversation resolution" for
   `main`.

## Done when

- `dart run melos run ci` passes, including the new package's tests.
- This task's own PR gets a review from the bot, with one thread per finding.
- A second push gets reviewed incrementally, without repeating findings.
- With the server unreachable, the job ends green with an "unavailable"
  review.
- `--print` works on Alex's Mac.
- Every run leaves a note on the PR, even when there's nothing to comment on.
- The README says how the review works and that Alex decides.

## Agent plan

1. Commit the unedited draft, then this approved version, so the history shows
   the difference.
2. Build `tool/ai_review` bottom-up:
   - the diff parser and filter;
   - the model client;
   - the parser and the prompt builder;
   - comment placement and formatting;
   - the publishers;
   - the service and the command-line entry point.

   Add tests for each part as it's written.
3. Write the reviewer instructions (`prompts/system.md`). Each diff line is
   sent with its line number, so the model doesn't have to count lines.
4. Add `ai-review.yml`, plus README and CLAUDE.md updates.
5. Run an end-to-end `--print` check against a local fake server, because the
   real key doesn't exist yet. Then run `dart run melos run ci` and commit.
6. Stop, and ask Alex about the three setup steps and about pushing the
   branch.
