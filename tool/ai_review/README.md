# ai_review

Reviews this repository's pull requests with a self-hosted, OpenAI-compatible
model (Qwen3.8-Flash-Next on Alex's server). Dev tooling only: the app never
depends on it.

## How a review works

1. `.github/workflows/ai-review.yml` runs `dart run ai_review` on every push to
   a PR into `main`.
2. The tool diffs the PR against its merge base. On later pushes it diffs only
   the commits since the last reviewed one, so findings aren't repeated.
   Lockfiles, generated files and platform folders are left out.
3. **A large PR is reviewed in parts:** up to 60,000 characters of diff per
   model call (`--max-diff-chars`), at most 4 calls (`--max-batches`). App code
   goes first, then config, tests and docs, so if anything still doesn't fit,
   it's the least important files. One call stays well inside the Cloudflare
   tunnel's ~100 s limit for an answer to start.
4. Each diff line is sent with its line number, together with the reviewer
   instructions in [`prompts/system.md`](prompts/system.md). Each part's prompt
   also lists the files reviewed in other parts, for context. The answer is
   streamed back and constrained to a JSON schema when the server supports it.
5. The answers become one GitHub review (`event: COMMENT`): findings merged,
   sorted by severity and capped at 10. **Every finding is its own thread**, on
   its line when it can be, else on its file. If one part gets no answer, the
   rest is still posted, and that part's files are named as not reviewed.
6. Alex replies to each thread (accept, or ask for a change) and resolves it.
   Branch protection only allows the merge once every thread is resolved. The
   bot never approves, blocks or merges.

**The bot is never silent.** Every run leaves something on the PR:

- the review, titled "no findings" when there's nothing to raise;
- "nothing to review" when only files it skips changed;
- "already reviewed" when the commit already has a review;
- "unavailable" when the model server is down, with the job still green;
- "not configured" when the secrets are missing.

PRs from forks get no secrets and are skipped, with a notice in the job.

## Design

Small parts behind interfaces, wired by constructor injection in
`lib/src/cli.dart`:

| Part | Job |
|---|---|
| `DiffSource` / `GitDiffSource` | What changed (`git diff`, merge base, ancestry) |
| `DiffFilter` | What is worth reviewing, in which order, packed into parts |
| `PromptBuilder` | The two messages for the model |
| `ReviewModel` / `OpenAiCompatibleModel` | Streaming chat call, retry, timeout |
| `ReviewParser` | Lenient JSON → findings, capped and sorted by severity; merges the parts |
| `CommentPlanner` | Line, file or "general" thread for each finding |
| `ReviewFormatter` + `TextSafety` | Markdown, with `@mentions` and fake markers neutralised |
| `ReviewPublisher` / `GitHubPublisher` / `ConsolePublisher` | Post to the PR, or print |
| `ReviewService` | Runs the steps in order |

## Run it locally

Set `AI_REVIEW_BASE_URL`, and either `AI_REVIEW_API_KEY` or
`AI_REVIEW_API_KEY_FILE` (a file that holds only the key). Then, from the repo
root, with your branch committed:

```bash
dart run ai_review --print
```

`--print` reviews the whole branch against `origin/main` and prints the
result instead of posting it. `dart run ai_review --help` lists the options.

## Configuration on GitHub

| Name | Kind | What |
|---|---|---|
| `AI_REVIEW_BASE_URL` | secret | The model server's OpenAI-compatible base URL |
| `AI_REVIEW_API_KEY` | secret | A key for this project only, limited to one model |
| `AI_REVIEW_MODEL` | variable (optional) | Defaults to `qwen38-flash` |

Without the secrets, the job ends green with a "not configured" notice.
