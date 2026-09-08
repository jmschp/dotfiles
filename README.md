# Dotfiles

[![Test dotfiles](https://github.com/jmschp/dotfiles/actions/workflows/github-actions.yml/badge.svg)](https://github.com/jmschp/dotfiles/actions/workflows/github-actions.yml)

My macOS setup, installed with a single `make`. Config files are symlinked into place with [GNU Stow](https://www.gnu.org/software/stow/) and follow the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/latest/), so the home directory stays clean: everything lives under `~/.config`, `~/.local/share`, `~/.local/state` and `~/.cache`, with `~/.zshenv` as the only file directly in `$HOME`.

## What gets installed

- **Homebrew** with formulae from `homebrew/Brewfile` and GUI apps from `homebrew/Caskfile`
- **Zsh** with [Oh My Zsh](https://ohmyz.sh/), a custom `robbyrussell` theme, `zsh-autosuggestions` and `zsh-syntax-highlighting`
- **asdf** with the latest Node LTS, Python 3 and Ruby 3, plus a default gem set (`ruby-lsp`, `rubocop`, ...)
- **Rust** via `rustup`
- **Git** config with GPG-signed commits, Cursor as diff/merge tool and a global ignore file
- **AWS CLI** profiles, with credentials prompted for during install
- **GPG** keys restored from a backup you point to during install
- **Default applications** per file extension, via [duti](https://github.com/moretension/duti)
- **ngrok**, **irb** and **npm** configs

## Installation

### 1. Update macOS and install the CLI tools

On a fresh macOS install, open Terminal and run:

```zsh
softwareupdate -i -a
```

Restart if asked, then install the Xcode command line tools (needed for `git` and Homebrew):

```zsh
xcode-select --install
```

### 2. Clone the repo

```zsh
git clone https://github.com/jmschp/dotfiles.git ~/code/dotfiles && cd ~/code/dotfiles
```

### 3. Run the Makefile

```zsh
make
```

This asks for your password once and keeps `sudo` alive for the whole run. Along the way it prompts for AWS access keys and the path to a GPG key backup. When it finishes, open a new terminal so the new `.zshenv` and Oh My Zsh are loaded.

### 4. Apply the macOS preferences

```zsh
make macos
```

Sets the computer name and a set of System Settings defaults (Dock, Finder, keyboard repeat, Mission Control, Calendar, ...). Some changes only apply after logging out or restarting.

## Make targets

Every step of the install is its own target, so you can rerun just one:

| Target | What it does |
| --- | --- |
| `make` | Full install (`all`) |
| `make stow` | Symlink `dot-files/` into `$HOME` again after editing or adding a config file |
| `make brew-formulae` / `make brew-casks` | Install from the Brewfile / Caskfile |
| `make ohmyzsh`, `make ohmyzsh-plugins` | Install Oh My Zsh and the two custom plugins |
| `make asdf` | Add asdf plugins and install Node, Python and Ruby |
| `make duti` | Reapply default applications from `.duti` |
| `make aws-credentials` | Configure AWS profiles (prompts for keys) |
| `make gpg-keys` | Set up `GNUPGHOME` and import a key backup |
| `make macos` | Run `macos.sh` |
| `make test-all` | Verify the install (symlinks, asdf versions, AWS credentials, GPG permissions) |

## Repository layout

```
dot-files/            Stow package; `dot-` prefix becomes `.` in $HOME
  dot-zshenv          XDG variables and per-tool env; copied to ~/.zshenv first, then stowed
  dot-config/         becomes ~/.config
    zsh/              .zshrc (Oh My Zsh, plugins, theme) and .zlogin (aliases, PATH)
    git/              config and global ignore
    asdf/ aws/ irb/ ngrok/ npm/
ohmyzsh-custom/       Stow package targeted at $ZDOTDIR/ohmyzsh/custom (theme)
homebrew/             Brewfile (formulae) and Caskfile (GUI apps)
.duti                 file extension -> default app mappings
macos.sh              `defaults write` settings, grouped by System Settings pane
Makefile              the installer
```

## Secrets

Some tracked files contain values that should not end up in git history, such as the ngrok auth token and AWS account ids. Each of those values has a `# gitignoreSecret` comment on the line above it, and a git clean filter (defined in `dot-files/dot-config/git/config`, enabled for the whole repo by `.gitattributes`) replaces the value on the following line with `[REDACTED]` on commit. The working tree keeps the real value.

```ini
[profile example]
# gitignoreSecret
sso_account_id = [REDACTED]
```

The marker is a full comment line rather than a trailing comment because INI files, like the AWS config, do not support inline comments. To protect a new value, add the marker line directly above it. The filter is only active once the git config has been stowed, so do not commit those files from a fresh checkout before running `make stow`.

After a fresh install, fill in the `[REDACTED]` values in `~/.config/aws/config` and `~/.config/ngrok/ngrok.yml` by hand.

## Testing

Every push runs the full install on a `macos-latest` GitHub Actions runner, then `make test-all`. Interactive steps (sudo, GPG import) and casks are skipped when `CI` is set, and AWS keys come from fake environment variables.

## Credits

Based on the dotfiles of [Lars Kappert](https://github.com/webpro/dotfiles) and [Mathias Bynens](https://github.com/mathiasbynens/dotfiles). Thank you for your awesome repos.
