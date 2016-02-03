Evironment Initialization Guide on Mac
======================================

##Homebrew

Install Homebrew:

  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

Then, install `vim`, `cscope`, `ctags`, `git`, `lua`, `macvim`, `node`, `openssl`, `vim` using `brew install XXX` command.

##iTerm2

Download latest iTerm2 from [official site](https://www.iterm2.com)

###Italic fonts support

See this [post](https://alexpearce.me/2014/05/italics-in-iterm2-vim-tmux/). There are two approaches: adding a new terminfo file for iTerm2, or edit .vimrc for `t_ZH` (This approach is mentioned in a [reponse](https://alexpearce.me/2014/05/italics-in-iterm2-vim-tmux/#comment-2322371354) by Sitaktif).

