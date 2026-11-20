---
name: dependency-updates
description: |
  Use this skill when a project's dependency versions need to move: one package or gem, a family released in lockstep, a section (devDependencies, the test group), or the whole manifest. The request may name a package ("sentry is way behind"), a group ("refresh the test tooling"), or a goal: get `npm outdated` / `bundle outdated` down to intentional holds, fix an audit advisory, or clear a deprecation warning a newer version fixes. If the project has its own update skill (`update-gems`, `update-packages`), use that instead; this is the method when there is none. Don't use it to add a dependency, upgrade the language runtime itself, or take a framework major on its own.
argument-hint: "[dev|prod] [start-unit]"
---

# Dependency updates

Update every direct dependency in manifest order, one unit at a time. A unit is one package, or a family that is released in lockstep and only resolves together. Each unit that changes the lockfile becomes its own commit: the changelogs reviewed, the fixes it needs and the evidence it works. One unit per commit keeps each change reviewable, bisectable and revertable; manifest order makes the run resumable from any unit.

Development and test dependencies come first, production dependencies after. Tooling never reaches a user; production dependencies change what ships and get the closer review. With one ticket per section they go in two PRs, the production one stacked on top so the low-risk half lands first; with a single ticket, one PR with the dev commits first.

Keep this in the main conversation rather than handing it to a subagent: several decisions belong to the user (see "Stop and ask"), and a dependency update is a production change.

## 1. Set up

1. **Ticket and branch.** Search the tracker for the run's tickets first; they are often pre-created, sometimes as a pair. Name each branch after its issue's branch name from an up-to-date default branch. With two tickets, build the stack with `gh stack init <dev-branch>` then `gh stack add <prod-branch>`. Check `git worktree list` and ask whether to work in the main checkout or a worktree.
2. **A clean working tree.** If the manifest, the lockfile or anything else has changes you didn't make, stop and ask; they may be the user's own experiment.
3. **Install what the lockfile says** (`npm ci`, `bundle install`). An install that drifted from the lockfile makes every later check test the wrong versions, silently.
4. **Baseline.** Run the project's checks on the untouched branch and keep the result; where there are pre-existing lint or type errors, every later check compares per file against this baseline. Note what `outdated` and `audit` report now, so the PR can say what this run fixed and what was already there. Read the holds: exact pins and the comments or notes that record why each one exists.

## 2. The per-unit loop

Repeat until nothing is left to move: with the dev section, then with the production section.

1. **Update one unit** within its current major (`npm install <pkg>@^<x.y.z>`, keeping `~` where the range had it; `bundle update <gem>`, with `--conservative` when the user asked for one or a few gems so shared dependencies stay put). Never take a new major or move an exact pin without asking. A peer or resolver conflict means another unit must move first, or an undeclared dependency the code imports must be declared in the same install; `--legacy-peer-deps` and `--force` are never the fix.
2. **Account for the lockdiff.** Installing a unit also moves whatever its new version needs. Every direct dependency that moved, every new or removed package and every major change of a transitive one needs a reason; summarise patch and minor transitive moves by count. When another direct dependency moved as a peer requirement, install it in the same commit so the manifest states what is installed.
3. **Review the changelogs** for every version between from and to, for each package in the unit and each transitive package that moved a major: its `CHANGELOG.md` (`gh api repos/<o>/<r>/contents/CHANGELOG.md --jq .content | base64 -d`; monorepos keep it under `packages/<name>/`), its GitHub releases, and the installed source when the notes are thin or disagree with the code. For each breaking or behaviour change, find our usage with `git grep` and decide whether it applies.
4. **Prove it.** Run the project's checks; for production dependencies also build. Many packages need more than the suite: exercise the feature that uses them.
5. **Fix in the same commit.** New lint problems, type errors, failing specs, API changes in our code, and notes that name a version this update made stale all belong to the update that caused them.
6. **Stop and ask** in the cases below, before committing.
7. **Commit** only after a green result: gate on the checks' exit status, not on grepping their output. Stage explicit paths (manifest, lockfile, fixed files). Revert anything the checks regenerated as a side effect.

### Commit message

```txt
build: update <package> <from> -> <to>

Also updates dependencies:

- <dep> <from> -> <to>

<What the changelogs say that matters to this app, why each breaking change does or doesn't
apply, what you changed, and what you checked. Then the verification result.>
```

- A family is one subject (`build: update tiptap packages 3.31.3 -> 3.32.0`), with the members listed in the body when their versions differ.
- When only the unit's dependencies moved, the subject is `build: update <package> <v> dependencies`, not a misleading `<v> -> <v>`.
- Leave "Also updates dependencies" out when only the unit moved.
- Every claim about our usage must come from a check you ran. A reviewer will trust it.

## 3. Stop and ask

These need a decision from the user, not just a careful commit.

- **A new major.** Read the migration guide, then say what it would take: the breaking changes that apply, the code to change, and whether it fits this PR or deserves its own ticket. Take it only on their go.
- **Anything pinned exactly.** An exact pin is a decision someone made; ask before moving it, and say what the new version brings.
- **A documented hold** this update touches or makes worth revisiting, for example when its stated blocker is gone.
- **A production dependency moved by a dev-section update**, or any moved package you can't explain. Transitive packages that build and app happen to share are the normal effect of an install: review their changelogs and say in the commit body that production shares them.
- **An install script or an engines/platform change** a package gains or raises.

### Holding a unit back

Hold it back in the manifest, not only in the PR description, or the next update silently takes the version you decided against. Revert the change, tighten the range to the narrowest one that excludes the bad versions (an exact version is the only way to hold a patch), record why and the tracking ticket where the project keeps such notes, install within the new range, and commit that like any other update.

## 4. Finish

1. **Nothing left behind.** Every remaining outdated entry is a pin, a hold, or a major you decided on; anything else was missed.
2. **Transitive refresh**, last and as its own commit (`build: refresh transitive dependencies`): `npm update` / `bundle update --all` once, review its lockdiff like any other, verify, commit. Run it once more: it must change nothing.
3. **The lockfile installs cleanly.** A clean install from the committed lockfile (`npm ci`, `bundle install`) succeeds and leaves `git status` clean. Then check that each commit's lockdiff contains only what its message names.
4. **Compare `audit`** against the baseline.
5. **PRs.** Stacked: `gh stack submit --auto`. Single: `gh pr create --draft --assignee @me`. The body carries the ticket link ("Stacked on #N" for a stacked PR), a table of unit, versions, notable moved dependencies and notes, a section per code change or major, "Held back" with reasons and tickets, and the verification results.
