###### Alias
alias aliasg='alias | grep'
alias cur="cursor"
alias myip="curl https://ipinfo.io/json" # or /ip for plain-text ip
alias speedtest="curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -"
alias rcdg="bundle exec rdbg --nonstop --open -- ./bin/rails console"
alias rsdg="bundle exec rdbg --nonstop --open -- ./bin/rails server"
###### Alias

###### Functions
# Delete local branches already merged into the main branch, skipping any
# branch checked out in a worktree, then prune stale remote-tracking refs.
gsweep() {
  local main
  main=$(git_main_branch) || return 1

  local -a branches
  branches=(${(f)"$(
    git for-each-ref refs/heads --merged "$main" --format='%(refname:short) %(worktreepath)' \
      | awk -v main="$main" 'NF == 1 && $1 != main { print $1 }'
  )"})

  if (( $#branches )); then
    git branch -d "${branches[@]}"
  else
    echo "No merged branches to delete"
  fi
  echo
  git remote prune origin
}
###### Functions

###### PATH
path=("$ASDF_DATA_DIR/shims" $path)
# path=("/opt/homebrew/opt/coreutils/libexec/gnubin" $path)
# path=("/opt/homebrew/opt/grep/libexec/gnubin" $path)
# path=("/opt/homebrew/opt/make/libexec/gnubin" $path)
# path=("/opt/homebrew/opt/llvm/bin" $path)
path=("./bin" $path)
###### PATH

###### Ngrok completions
if command -v /opt/homebrew/bin/ngrok &>/dev/null; then
  eval "$(/opt/homebrew/bin/ngrok completion)"
fi
###### Ngrok completions
