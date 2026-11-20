# Personal preferences (all projects)

These are my defaults for every project. A project's own CLAUDE.md, rules and skills win where they differ. Language-specific defaults live in `~/.claude/rules/` and load when matching files are touched.

## Git and GitHub

- Open every PR as a draft, assigned to me (`gh pr create --draft --assignee @me`; `gh pr edit <n> --add-assignee @me` if it was opened without). Check `gh pr view <n> --json assignees` after opening. I mark it ready for review myself; never run `gh pr ready` unless asked.
- Every human review comment gets a reply, naming the commit and what changed (or why not). Inline comments: reply in the thread (`gh api repos/<o>/<r>/pulls/<n>/comments/<id>/replies`); a top-level PR comment is not a substitute. A review's summary body, including a "nothing to fix" review, can't take a threaded reply: answer it with a PR comment that quotes it. After each review round, check `pulls/<n>/comments`, `pulls/<n>/reviews` and `issues/<n>/comments` for every PR in the stack. Bot reviews with nothing to act on need no reply.
- One issue per plan and per PR, kept small. A ticket that implies several PRs becomes an umbrella parent with one sub-issue per PR. If two issues are coupled, order them as stacked PRs instead of merging them into one.
- Search the issue tracker before creating an issue: I often pre-create sibling tickets. Name the branch after the found issue's branch name from the start; renaming a branch later closes its open PR.
- An analysis, proposal or implementation plan I ask for is delivered as an issue in the project's tracker (the project's CLAUDE.md names the project and status). In plan mode, state this deliverable at the top of the plan and create the issue right after approval.
- Dependent PRs are stacked with the `gh stack` extension (`gh stack push --remote origin`). Open stack PRs with `gh stack submit --auto`, never `gh pr create --base <branch>`. After every push or submit, set upstream tracking on each stack branch that has none (`git branch --set-upstream-to=origin/<branch> <branch>`, then check `git status -sb`); gh-stack pushes without `-u`.
- Each review change is one commit on that PR's branch. Push every commit as soon as it is verified green, restacking the layers above first; never hold commits for a "review finished" signal unless I ask for that in the moment. A rebase ends with an immediate push (local = remote), then verification on CI rather than a local full suite.
- Stage explicit paths. Never `git add -A` or `git add .`.
- IMPORTANT: commit or push only after a real green result. Gate on the result itself (e.g. `0 failures`, exit status via `PIPESTATUS`), never on a grep that also matches a failing summary. Keep edit scripts that can abort midway in a separate command from the commit. A `git commit -F - <<'EOF'` heredoc ends the `&&` chain: lines after `EOF` run even when the gate failed, so build the message into a variable and use `-m "$MSG"` inside the chain, or run follow-ups in a second command that first checks `git log -1 --format=%s`. Never cite a SHA that does not exist yet.
- Don't commit generated files (schema dumps, lockfiles, API docs) that changed only as a side effect of running tools; revert them unless the branch actually caused the change.

## Code style

- Use the linter's full line length. Don't wrap a signature, call, object literal or one-statement arrow body that fits on one line.
- Prefer minimal, uniform interfaces: no new class or service for a few lines with a single caller, no redundant fields that duplicate information already returned elsewhere, one helper per case rather than special-case variants.
- Wrap third-party SDKs (error reporting, analytics, feature flags, payments) behind one app-owned module in the app's own vocabulary. It is the only importer of the vendor package (enforce with a lint rule), takes plain arguments (no vendor types), and specs mock it.
- Error responses carry a human-readable message; include a field-level errors map only when there are real field-level errors. Never wrap a plain message into a fake `base` error.
- No exception subclasses for control flow, least of all outside `StandardError`; use signals the code already carries (`errors`, a `completed` flag). Before acting on a review suggestion to redesign a base class, count the real call sites that hit the problem; if there are none, keep the local fix and document the trap.

## Verification

- An empty output is not a clean result. Before reporting "no errors" from lint, type-check or tests, confirm the tool actually ran (non-zero file count, known errors still reported).
- When a codebase has pre-existing lint or type errors, compare per-file counts against the main branch instead of expecting zero.
- A plan that wraps or extends a framework mechanism (transactions, callbacks, jobs, …) reads the current official docs for it first, cites what they add in a short "what the docs add" section, and checks each point against the installed version.
- Before saying something recurred or is missing, prove it: confirm the fix commit is in the deployed build, check the build or commit the event came from, and check whether existing alerting or tooling already covers it.
- Pair a zero-result log or error search with a control query on a path known to be busy, so an empty result means "no matches" and not "wrong query".

## Shell and macOS

- Parallel Bash calls share one working directory. When working across repos or worktrees, start every command with `cd /absolute/path &&`.
- zsh: unquoted paths containing `[...]` (e.g. Nuxt `[slug]` routes) abort the whole command with "no matches found", and unquoted variables are not word-split. Quote paths and pipe lists through `xargs`.
- Run every long process I start (builds, test suites, servers, Playwright runs, background jobs) under `caffeinate -i …` (or `caffeinate -i -w <pid>` for one already running). Background processes hold no power assertion, so the Mac idle-sleeps mid-run otherwise.
- Never print tokens or secrets, and never pass expanded token values in command arguments.

## Environment

- I run Claude Code in iTerm2 with its Claude Code integration (Session Status, Claude Code Workgroup). I launch `claude` from the repo or worktree I'm working in. Don't give tmux advice.
- Feature work happens in worktrees under `<repo>_worktrees/<name>` beside the main checkout, never nested inside it; the main checkout stays on the default branch. I usually create the worktree myself, named after the issue's branch name. Check `git worktree list` before proposing a new one.
- One worktree per piece of work, not per branch or sub-issue. When an issue splits into sub-issues whose PRs become a `gh stack`, every layer stays in the worktree the work started in: `gh stack add <branch>` creates the next layer there, and `gh stack up` / `down` / `checkout <branch>` move between layers. A new worktree is only for unrelated work, or when I ask for one. Never symlink `node_modules` between worktrees; run a real install.
- A new worktree receives the untracked files listed in the main checkout's `.worktreeinclude` (gitignore syntax), copied by my global `post-checkout` hook. It never overwrites and does nothing with `--no-checkout`. Each worktree's `CLAUDE.local.md` starts as a copy of the main checkout's and then diverges.

@~/.config/mise/conf.d/legalnature/guidance/legalnature.md
