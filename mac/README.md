# Evironment Initialization Guide on Mac

## Homebrew

Install Homebrew:

```sh
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Then, install `vim`, `cscope`, `ctags`, `git`, `lua`, `macvim`, `node`, `openssl`, `vim` using `brew install XXX` command.

### Mirror for homebrew formula

Using 清华大学开源软件镜像站's homebrew formula mirror:

```sh
git -C "$(brew --repo)" remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git
git -C "$(brew --repo homebrew/core)" remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git
git -C "$(brew --repo homebrew/cask)" remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-cask.git
brew update
```

Rollback:

```sh
git -C "$(brew --repo)" remote set-url origin https://github.com/Homebrew/brew.git
git -C "$(brew --repo homebrew/core)" remote set-url origin https://github.com/Homebrew/homebrew-core.git
git -C "$(brew --repo homebrew/cask)" remote set-url origin https://github.com/Homebrew/homebrew-cask.git
brew update
```

### Mirror for homebrew-bottles

Temporary usage:

```sh
export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles
```

Long-term usage:

```sh
echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles' >> ~/.bash_profile
source ~/.bash_profile
```

## iTerm2

Download latest iTerm2 from [official site](https://www.iterm2.com)

### Italic fonts support

See this [post](https://alexpearce.me/2014/05/italics-in-iterm2-vim-tmux/). There are two approaches: adding a new terminfo file for iTerm2, or edit .vimrc for `t_ZH` (This approach is mentioned in a [reponse](https://alexpearce.me/2014/05/italics-in-iterm2-vim-tmux/#comment-2322371354) by Sitaktif).
