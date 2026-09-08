# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal macOS dotfiles for bootstrapping a new machine. There is no application code: the "build" is `make`, which installs Homebrew, symlinks config files into `$HOME` with GNU Stow, and sets up zsh, asdf, Rust, AWS profiles and GPG keys. Everything is XDG Base Directory oriented (`~/.config`, `~/.local/share`, `~/.local/state`, `~/.cache`); nothing except `~/.zshenv` is meant to live directly in `$HOME`.

## Commands

```zsh
make                 # full install (the `all` target); prompts for sudo, AWS keys and a GPG backup path
make macos           # apply macOS `defaults` from macos.sh (separate from `all`, needs a restart afterwards)
make test-all        # CI assertions: symlinks exist, ~/.tool-versions, AWS credentials file, GNUPGHOME perms
make test-stow       # just check the Stow symlinks
make stow            # re-link dot-files/ into $HOME after adding/renaming a config file
make brew-formulae   # brew bundle --file=homebrew/Brewfile
make brew-casks      # brew bundle --file=homebrew/Caskfile (skipped in CI)
```

Individual targets (`asdf-ruby`, `duti`, `gpg-keys`, `aws-credentials-legado`, ...) can be run alone. The Makefile uses `SHELL:=/bin/zsh` and relies on `XDG_*`, `ZDOTDIR` and `GNUPGHOME` already being exported, so run it from a shell that has sourced `dot-files/dot-zshenv` (CI copies it to `~/.zshenv` first; `make xdg_specs` does the same).

CI (`.github/workflows/github-actions.yml`) runs `make` then `make test-all` on `macos-latest` on every push. Targets check `ifndef CI` to skip interactive or already-done steps (sudo keep-alive, Homebrew install, casks, GPG import). When adding a target that prompts or needs a GUI, guard it the same way and add a matching `test-*` assertion.

## Layout and how the pieces connect

- `dot-files/` is the single Stow package. Stow is run with `--dotfiles`, so `dot-zshenv` becomes `~/.zshenv` and `dot-config/` becomes `~/.config/`. Files below `dot-config/` keep their literal names (`.zshrc`, `.zlogin` are already dotted). `--no-folding` means every file is linked individually and `--adopt` pulls pre-existing files in `$HOME` back into the repo, which will show up as a diff. When you add a config file here, also add a `test -L` line to `test-stow`.
- `dot-files/dot-zshenv` is the root of the whole setup. It exports the XDG dirs and relocates every tool (asdf, AWS, Bundler, GnuPG, npm, Rust, irb, zsh history) into them. It is copied, not stowed, by `make xdg_specs` because `ZDOTDIR` must be set before Stow runs; `make stow` then replaces the copy with a symlink.
- Zsh loads from `$ZDOTDIR` (`~/.config/zsh`): `.zshrc` is the Oh My Zsh config (plugins list, theme `robbyrussell-custom`), `.zlogin` holds aliases and PATH additions (asdf shims, `./bin`). Oh My Zsh itself is installed into `$ZDOTDIR/ohmyzsh`; `ohmyzsh-custom/` is a second Stow package targeted at `$ZDOTDIR/ohmyzsh/custom` (currently only the prompt theme).
- `homebrew/Brewfile` (formulae and taps) and `homebrew/Caskfile` (GUI apps) are separate so CI can install formulae without casks.
- `.duti` maps file extensions to default apps. The bundle id `com.todesktop.230313mzl4w4u92` is Cursor.
- `macos.sh` is a standalone `defaults write` script, grouped by System Settings pane.
- asdf manages Node, Python and Ruby; versions are written to `~/.tool-versions` at install time (latest LTS / latest 3.x), not pinned in the repo. `dot-config/asdf/default-gems` lists gems auto-installed with every Ruby.

## Secret redaction filter (important)

`.gitattributes` applies a `gitignoreSecret` clean filter to every file. The filter is defined in `dot-files/dot-config/git/config`. When a line consists only of the comment `# gitignoreSecret`, the filter replaces the value on the **next** line (everything after the first `=` or `:`) with `[REDACTED]` at commit time, while the working tree keeps the real value. This is how `ngrok.yml` (auth token) and `aws/config` (account ids) are tracked.

- The marker is a full comment line above the value, never a trailing comment. INI files such as the AWS config do not support inline comments, so a trailing marker becomes part of the value and breaks the tool.
- Never remove a `# gitignoreSecret` line or copy the value below it elsewhere. To protect a new value, add the marker line directly above it. Do not put secrets in ordinary comments either; only the line after a marker is redacted.
- Only genuinely sensitive values are marked. Regions and SSO session names are not, so the config works on a fresh machine without editing.
- The filter only exists once the stowed git config is active. On a fresh checkout before `make stow`, committing would write real values into history. `git status` may also show these files as modified until the filter is configured; that is expected, not a real change.
- `git show HEAD:<file>` is the way to confirm what is actually committed.

## Conventions

- Commit messages follow `feat: ...` style; changes land via PRs to `main`.
- Shell scripts are zsh unless invoking a remote installer that requires bash. `shfmt` is in the Brewfile for formatting.
- User-specific values (name, GPG key id, hostname `jmschp-macbook`, AWS profile names `arqshoah`, `legado`, `legalnature-*`) are intentional and hardcoded; do not generalise them.
