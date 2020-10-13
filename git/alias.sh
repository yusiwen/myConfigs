#!/bin/sh

# Set aliases for git
# See "Must Have Git Aliases: Advanced Examples" (http://durdn.com/blog/2012/11/22/must-have-git-aliases-advanced-examples/) for details

# {{{ Basic
git config --global alias.cp   'cherry-pick'
git config --global alias.st   'status --short --branch'
git config --global alias.cl   'clone'
git config --global alias.ci   'commit'
git config --global alias.co   'checkout'
git config --global alias.br   'branch'
git config --global alias.diff 'diff --word-diff'
git config --global alias.dc   'diff --cached'
# }}}

# {{{ Logs
# List commits in short form, with colors and branch/tag annotations
git config --global alias.ls 'log --pretty=format:"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate'
# List commits showing changed files is invoked
git config --global alias.ll 'log --pretty=format:"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --numstat'
# List commits showing changed files is invoked
git config --global alias.lnc 'log --pretty=format:"%h\\ %s\\ [%cn]"'
# List commits showing changed files is invoked
git config --global alias.lds 'log --pretty=format:"%C(yellow)%h\\ %ad%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --date=short'
# List commits showing changed files is invoked
git config --global alias.ld 'log --pretty=format:"%C(yellow)%h\\ %ad%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --date=relative'
# Report
git config --global alias.report 'log --format='%Cgreen%ci%Creset %s%Creset' --no-merges'
# Report CSV format
git config --global alias.report-csv 'log --format='\"%ci\",\"%s\"' --no-merges'
# }}}

# {{{ Diff
# You can see all the commits related to a file, with the diff of the changes
git config --global alias.fl 'log -u'
# Show modified files in last commit
git config --global alias.dl '!git ll -1'
# Show a diff last commit
git config --global alias.dlc 'diff --cached HEAD^'
# Show content (full diff) of a commit given a revision
git config --global alias.dr    '!f() { git diff "$1"^.."$1";  }; f'
git config --global alias.lc    '!f() { git ll "$1"^.."$1";  }; f'
git config --global alias.diffr '!f() { git diff "$1"^.."$1";  }; f'
# }}}

# {{{ Grep
# Find a file path in codebase
git config --global alias.f '!git ls-files | grep -i'
# Search/grep your entire codebase for a string
git config --global alias.gr 'grep -Ii'
# Grep from root folder
git config --global alias.gra '!f() { A=$(pwd) && TOPLEVEL=$(git rev-parse --show-toplevel) && cd $TOPLEVEL && git grep --full-name -In $1 | xargs -I{} echo $TOPLEVEL/{} && cd $A;  }; f'
# }}}

# {{{ Tag
# Show the last tag
git config --global alias.lt 'describe --tags --abbrev=0'
# }}}

# {{{ Merge
git config --global alias.ours   '!f() { git co --ours $@ && git add $@;  }; f'
git config --global alias.theirs '!f() { git co --theirs $@ && git add $@;  }; f'
# }}}

# {{{ Reset
git config --global alias.r   'reset'
git config --global alias.r1  'reset HEAD^'
git config --global alias.r2  'reset HEAD^^'
git config --global alias.rh  'reset --hard'
git config --global alias.rh1 'reset HEAD^ --hard'
git config --global alias.rh2 'reset HEAD^^ --hard'
# }}}

# {{{ Stash
git config --global alias.sl 'stash list'
git config --global alias.sa 'stash apply'
git config --global alias.ss 'stash save'
# }}}

# {{{ Meta
# List all your aliases
git config --global alias.la '!git config -l | grep alias | cut -c 7-'
# }}}
