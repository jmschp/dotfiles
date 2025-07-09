###### Complete hidden paths
# setopt globdots

###### Alias
alias aliasg='alias | grep'
alias cur="cursor"
alias gsweep='git branch --merged $(git_main_branch) | grep -v "$(git_main_branch)$" | xargs git branch -d && git remote prune origin'
alias myip="curl https://ipinfo.io/json" # or /ip for plain-text ip
alias speedtest="curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -"

###### Set PATH
path=("$ASDF_DATA_DIR/shims" $path)
path=("/opt/homebrew/opt/coreutils/libexec/gnubin" $path)
path=("/opt/homebrew/opt/grep/libexec/gnubin" $path)
path=("/opt/homebrew/opt/make/libexec/gnubin" $path)
# path=("/opt/homebrew/opt/llvm/bin" $path)
# path=("./bin" $path)
# path=("/Users/Shared/DBngin/mysql/5.7.23/bin" $path)

###### Ngrok completions
if command -v /opt/homebrew/bin/ngrok &>/dev/null; then
  eval "$(/opt/homebrew/bin/ngrok completion)"
fi
