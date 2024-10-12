#!/usr/bin/env fish

function check_command
  if type -q "$argv[1]"
    true
  else
    false
  end
end

# Github {{{
function get_latest_release
  if test -z "$argv[1]"
    return
  end
  curl --silent "https://api.github.com/repos/$argv[1]/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
end
#}}}

# Git {{{
# https://polothy.github.io/post/2019-08-19-fzf-git-checkout/
function _fzf_git_branch
  git rev-parse HEAD >/dev/null 2>&1 || return

  git branch --color=always --all --sort=-committerdate |
    grep -v HEAD |
    fzf --height 50% --ansi --no-multi --preview-window right:65% \
      --preview 'git log -n 50 --color=always --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed "s/.* //" <<< {})' |
    sed 's/^\*\?\s\+//'      
end

function _fzf_git_checkout
  git rev-parse HEAD >/dev/null 2>&1 || return

  set -l current_branch $(git branch --show-current)

  if test -n "$(git status -s)"
    read -P 'The working directory is dirty, stash before checkout? [YES|no]: ' -l yn

    switch $yn
      case "" yes YES Yes y Y
        git stash -u
    end 
  end

  set -l branch $(_fzf_git_branch)
  if test -z "$branch"
    echo "No branch selected."
    return
  end
  
  read -P "Checkout specific commit? [yes|NO]: " -l yn

  set -l get_commit 0
  switch $yn
    case yes YES Yes y Y
      set -l get_commit 1
  end

  set -l commit ""
  if test $get_commit = 1
    set -l commit $(git log "$branch" --color=always --date=short --pretty="format:%C(auto)%cd %h%d %s" | fzf | cut -d' ' -f 2)
  end 

  if test -z "$commit"
    set -l commit "$branch"
  end

  if test "$commit" = "$current_branch"
    return
  end

  # If branch name starts with 'remotes/' then it is a remote branch. By
  # using --track and a remote branch name, it is the same as:
  # git checkout -b branchName --track origin/branchName
  if string match 'remotes/*' $commit
    git checkout --track $commit
  else
    git checkout $commit
  end
end

# https://gist.github.com/junegunn/f4fca918e937e6bf5bad
function _fzf_git_diff
  set -l PREVIEW_PAGER "less --tabs=4 -Rc"
  set -l REVISION "$argv[1]"

  if string match -q '.' "$REVISION"
    set REVISION 'HEAD'
  end

  # Don't just diff the selected file alone, get related files first using
  # '--name-status -R' in order to include moves and renames in the diff.
  # See for reference: https://stackoverflow.com/q/71268388/3018229
  set -l PREVIEW_COMMAND 'git diff --color=always '$REVISION' -- \
		$(echo $(git diff --name-status -R '$argv' | grep {}) | cut -d" " -f 2-) \
		| '$PREVIEW_PAGER

  git diff --submodule --word-diff --name-only "$argv" |
    fzf --exit-0 --preview "$PREVIEW_COMMAND" \
      --preview-window=top:85%
end
# }}}