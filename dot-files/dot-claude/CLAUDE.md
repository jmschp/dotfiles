# Personal preferences (all projects)

## Git and GitHub

- Open every PR as a draft (`gh pr create --draft`). I mark it ready for review myself; never run `gh pr ready` unless asked.
- After acting on a review comment, reply in that comment's thread (`gh api repos/<o>/<r>/pulls/<n>/comments/<id>/replies`), naming the commit and what changed (or why not). A top-level PR comment is not a substitute.
- One issue per plan and per PR, kept small. If two issues are coupled, order them as stacked PRs instead of merging them into one.
- Stage explicit paths. Never `git add -A` or `git add .`.
- IMPORTANT: commit or push only after a real green result. Gate on the result itself (e.g. `0 failures`, exit status via `PIPESTATUS`), never on a grep that also matches a failing summary. Keep edit scripts that can abort midway in a separate command from the commit.
- Don't commit generated files (schema dumps, lockfiles, API docs) that changed only as a side effect of running tools; revert them unless the branch actually caused the change.

## Code style

- Use the linter's full line length. Don't wrap a signature, call, object literal or one-statement arrow body that fits on one line.
- Prefer minimal, uniform interfaces: no new class or service for a few lines with a single caller, no redundant fields that duplicate information already returned elsewhere, one helper per case rather than special-case variants.
- Wrap third-party SDKs (error reporting, analytics, feature flags, payments) behind one app-owned module in the app's own vocabulary. It is the only importer of the vendor package (enforce with a lint rule), takes plain arguments (no vendor types), and specs mock it.
- Error responses carry a human-readable message; include a field-level errors map only when there are real field-level errors. Never wrap a plain message into a fake `base` error.

## Ruby on Rails

- Migrations change schema only. Backfills go in a separate, batched, resumable task. Type changes and destructive changes (drop, rename) ship as multi-deploy rollouts: stop using or add the column, backfill, then cut over.
- Declare both sides of every association and set `inverse_of` on both, polymorphic included. Choose `dependent:` deliberately. Soft-delete gems still run destroy callbacks, so they are no reason to skip it.
- Prefer request specs over controller specs.
- Don't reference autoloaded constants at file-load time in files that rake tasks require; they load before autoloading.

## Vue / Nuxt

- Don't fire un-awaited fetches at the top level of `<script setup>`; put them in `onMounted` or use the framework's data-fetching composable.
- In Nuxt tests, mock auto-imports with `mockNuxtImport`; `vi.stubGlobal` doesn't intercept them.

## Verification

- An empty output is not a clean result. Before reporting "no errors" from lint, type-check or tests, confirm the tool actually ran (non-zero file count, known errors still reported).
- When a codebase has pre-existing lint or type errors, compare per-file counts against the main branch instead of expecting zero.
- Before saying something recurred or is missing, prove it: check the build or commit the event came from, and check whether existing alerting or tooling already covers it.

## Shell

- Parallel Bash calls share one working directory. When working across repos or worktrees, start every command with `cd /absolute/path &&`.
- zsh: unquoted paths containing `[...]` (e.g. Nuxt `[slug]` routes) abort the whole command with "no matches found", and unquoted variables are not word-split. Quote paths and pipe lists through `xargs`.

## Environment

- I run Claude Code in iTerm2 with its Claude Code integration (Session Status, Claude Code Workgroup). I launch `claude` from the repo or worktree I'm working in. Don't give tmux advice.
- Worktrees: I often create the worktree for an issue myself. Check `git worktree list` before proposing a new one. Never symlink `node_modules` between worktrees; run a real install.
