# Task 06: Review large PRs in parts

- **Status:** approved by Alex on 2026-11-01 (see below)
- **Branch:** `task/06-review-batches`

## Alex's prompts (verbatim)

The AI review of PR #5 skipped 22 files because the PR was over the bot's
size limit. Alex asked:

> whar's the issue with the review bot? can it be changed to review larger
> mr's?

Claude explained the limit. The bot sends the model at most 60,000
characters of diff. The model's context isn't the problem, since it has about
131k tokens per request. The real ceiling is the Cloudflare tunnel, which cuts
a request when no answer has started within about 100 seconds. The model
reads about 500 tokens a second, so a much bigger single prompt would get
close to that cut-off. Claude proposed reviewing big PRs in parts, with app
code first. Alex answered:

> Yes, add batching

The app itself, planned as task 06, becomes task 07.

## Goal

A PR of any size this project produces gets every reviewable file reviewed,
and every model call stays well inside the tunnel's limit.

## Must

- **Parts:** the diff is packed into parts of up to 60,000 characters each,
  at most 4 (`--max-batches`), so about 240,000 characters in all. Each part is
  one model call.
- **App code first:** files are ordered by kind, then by size: app code, then
  config (YAML), then tests, then docs. If something still doesn't fit, the
  least important files are the ones left out.
- **Context:** each part's prompt lists all the PR's files and says which are
  reviewed in other parts, so the model knows what else changed.
- **One review:** the parts' findings are merged, sorted by severity and
  capped at 10, as before. The summary has one paragraph per part. The review
  body says how many parts there were.
- **If one part fails** (model down, timeout), the others are still posted,
  and that part's files are listed as not reviewed. Only when every part fails
  is it "AI review unavailable", as before.
- A small PR works exactly as before: one part, one call.

## Out of scope

- Reviewing parts in parallel. They run one after another, to leave the box's
  other slot free for Rick.
- Raising the 60,000-character limit per call.

## Choices Claude made (Alex's to change)

- **4 parts at most:** about 5 minutes of model time on a big PR, well inside
  the job's 15-minute timeout.
- **Still 10 findings in total,** not 10 per part, because every finding needs
  Alex's decision.
- **A failed part keeps the commit marked as reviewed.** Its files are named
  in the review, so earlier findings aren't repeated on the next push.

## Done when

- `dart run melos run ci` passes, with tests for packing, ordering, the
  prompts, merging and a failed part.
- A live run against the real model reviews a PR that used to be cut short.
  Checked: PR #5's branch, which had 22 files skipped, was reviewed in 2 parts
  (30 and 6 files) in 97 s, with nothing skipped.
- The AI review has run on the PR, and Alex has decided every finding.
