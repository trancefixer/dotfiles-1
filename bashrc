function gs {
  git status -sb "$@"
}

function adjust_ps1 {
  perl -pe 's{(\\\$)([^\$]+?)$}{ $1 $2}s'
}

function render_ps1 {
  local ec="$?"
  
  export PS1_VAR=

  if [[ -n "${AWS_VAULT:-}" ]]; then
    if [[ -n "${AWS_VAULT_EXPIRATION:-}" ]]; then
      PS1_VAR="${AWS_VAULT} $(( $(date -d "${AWS_VAULT_EXPIRATION:-}" +%s) - $(date +%s) ))"
    else
      PS1_VAR="${AWS_VAULT}"
    fi
  fi

  if [[ -n "${TMUX_PANE:-}" ]]; then
    PS1_VAR="${TMUX_PANE}${PS1_VAR:+ ${PS1_VAR}}"
  fi

  echo
  powerline-go -error "$ec" --colorize-hostname -cwd-mode plain -mode flat -newline \
    -priority root,cwd,user,host,ssh,perms,git-branch,exit,cwd-path,git-status \
    -modules user,host,ssh,cwd,perms,gitlite,load,exit${PS1_VAR:+,shell-var --shell-var PS1_VAR} \
    -theme "$_CHM_HOME/themes/default.json"
}

function update_ps1 {
  PS1="$(render_ps1 | adjust_ps1)"
}

if tty >/dev/null; then
  if type -P powerline-go >/dev/null; then
    PROMPT_COMMAND="update_ps1"
  fi
fi
