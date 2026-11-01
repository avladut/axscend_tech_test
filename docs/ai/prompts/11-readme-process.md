# Task 11: The process in the README

- **Status:** approved by Alex on 2026-11-01 (see below)
- **Branch:** `task/11-readme-process`

## Alex's prompt (verbatim)

After PR #10 merged, Alex wrote:

> add in the readme details about the process. the claude model used, the
> reviewer model (qwen flash next) and the mr approval process

## Goal

A reader of the README understands, from it alone:

- who did what: Alex, Claude and the reviewer model;
- which models were used;
- how a task goes from Alex's prompt to a commit on `main`.

## Must

- **The models:**
  - Claude Opus 5.5 (`claude-opus-5-5`) in Claude Code, as the author;
  - Qwen3.8-Flash-Next (`qwen38-flash`), self-hosted, as the reviewer.
- **The process, step by step:** prompt record, branch, build, PR and its
  checks, the AI review, "discuss first" replies, Alex's decision, and the
  squash merge.
- **What `main` enforces,** checked against the live branch protection on
  2026-11-01:
  - pull requests only, enforced for admins;
  - required checks `checks` and `tests`, up to date with `main`;
  - every conversation resolved;
  - linear history and squash merges only;
  - no force-push or deletion.

  An approving review is not required (0). The README says Alex merges; it
  doesn't claim an approval rule that isn't there.
- **The record so far,** counted from the PR threads:
  - 36 Qwen findings across PRs #1 to #10;
  - Claude agreed with about 4 in 10, fully or in part; the rest it
    declined, with reasons;
  - Alex decided every one.

  The verdicts were classified from the reply text, so the README gives a
  rounded share, not an exact split.
- **The README stays in Alex's voice** ("I", "my server"), like the rest of
  it.

## Choices Claude made (Alex's to change)

- **Two stale lines fixed while there:**
  - the status line now mentions albums and photos;
  - the structure list says "blocs", not "cubits".
- **The reviewer server's hardware** isn't described. "My own server" is
  enough, and the rest is Alex's to add if he wants.

## Done when

- `dart run melos run ci` passes (the README isn't checked, but nothing else
  changes).
- The AI review has run on the PR, and Alex has decided every finding.

## Agent plan

1. Check the facts: branch protection, the commit trailers, how the
   reviewer model is named, and the review threads.
2. Rewrite "How it's built" in the README, and fix the two stale lines.
3. Ask Alex before committing.
