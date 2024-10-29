# XDG Base Directory Specification
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_DATA_DIRS="/usr/local/share/:/usr/share/:/opt/homebrew/share"
export XDG_RUNTIME_DIR="$HOME/.local/runtime"

# Bundler XDG Base Directory
export BUNDLE_USER_CACHE="$XDG_CACHE_HOME/bundle"
export BUNDLE_USER_CONFIG="$XDG_CONFIG_HOME/bundle/config"
export BUNDLE_USER_PLUGIN="$XDG_DATA_HOME/bundle/plugins"

# ASDF XDG Base Directory
export ASDF_CONFIG_FILE="$XDG_CONFIG_HOME/asdf/.asdfrc"
export ASDF_DATA_DIR="$XDG_DATA_HOME/asdf"
export ASDF_GEM_DEFAULT_PACKAGES_FILE="$XDG_CONFIG_HOME/asdf/.default-gems"
export ASDF_NODEJS_AUTO_ENABLE_COREPACK="true"

# AWS CLI XDG Base Directory
export AWS_CONFIG_FILE="$XDG_CONFIG_HOME/aws/config"
export AWS_DATA_PATH="$XDG_DATA_HOME/aws"
export AWS_CLI_HISTORY_FILE="$XDG_DATA_HOME/aws/history"
export AWS_CREDENTIALS_FILE="$XDG_DATA_HOME/aws/credentials"
# export AWS_WEB_IDENTITY_TOKEN_FILE="$XDG_DATA_HOME/aws/token"
export AWS_SHARED_CREDENTIALS_FILE="$AWS_CREDENTIALS_FILE"

# Zsh XDG Base Directory
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export HISTFILE="$XDG_STATE_HOME/zsh/zsh_history"
export SHELL_SESSION_DIR="$XDG_STATE_HOME/zsh/sessions"

export EDITOR="cursor --wait"
export RUBY_CONFIGURE_OPTS="--enable-yjit"
export THOR_MERGE="cursor --wait --merge"
export THOR_DIFF="cursor --wait --diff"

# Git debugging
# export GIT_CURL_VERBOSE=/Users/a0830202/git.log
# export GIT_TRACE=/Users/a0830202/git.log
# export GIT_TRACE_PACK_ACCESS=/Users/a0830202/git.log
# export GIT_TRACE_PACKET=/Users/a0830202/git.log
# export GIT_TRACE_PERFORMANCE=/Users/a0830202/git.log
# export GIT_TRACE_SETUP=/Users/a0830202/git.log
