VIM Installation
================

## References

- [rafi/vim-config](https://github.com/rafi/vim-config)
- [xero/dotfiles](https://github.com/xero/dotfiles)

## Prerequisites

- Lua, Pypthon, Python3, Ruby, Perl
- If don't have Ruby installed,
  [yaml2json](https://github.com/SoftwearDevelopment/large-yaml2json-json2yaml)
  shoudl be installed, or use PyYAML: `pip3 install --user --upgrade PyYAML`
- Linters:
  - Node.js based linters:

    ```
    npm -g install jshint jsxhint jsonlint stylelint sass-lint
    npm -g install raml-cop markdownlint-cli write-good
    ```

  - Python based linters:

    ```
    pip install --user pycodestyle pyflakes flake8 vim-vint proselint yamllint
    ```

- ag (The Silver Searcher): [ggreer/the_silver_searcher](https://github.com/ggreer/the_silver_searcher)
- `cscope`, `exuberant ctags`

## Installation

1. Install vim & neovim:

  ```text
  # Add this PPA if you want to install latest vim release on Ubuntu earlier than 17.04
  $ sudo add-apt-repository ppa:jonathonf/vim
  $ sudo apt-get install vim-gtk

  # Insall NeoVim latest stable
  $ sudo add-apt-repository ppa:neovim-ppa/stable
  $ sudo apt-get insall neovim
  ```

2. Link setting files to ~/.vim

  ```text
  $ mkdir -p ~/.vim
  $ ln -sf ~/git/myConfigs/vim/vimrc ~/.vim/vimrc
  $ ln -sf ~/git/myConfigs/vim/colors ~/.vim/colors
  $ ln -sf ~/git/myConfigs/vim/ftplugin ~/.vim/ftplugin
  $ ln -sf ~/git/myConfigs/vim/plugin ~/.vim/plugin
  $ ln -sf ~/git/myConfigs/vim/snippets ~/.vim/snippets
  $ ln -sf ~/git/myConfigs/vim/plugins.yaml ~/.vim/plugins.yaml
  $ ln -sf ~/git/myConfigs/vim/init.vim ~/.vim/init.vim
  $ ln -sf ~/git/myConfigs/vim/vimrc.denite ~/.vim/vimrc.denite
  $ ln -sf ~/git/myConfigs/vim/vimrc.denite.menu ~/.vim/vimrc.denite.menu
  $ ln -sf ~/git/myConfigs/vim/vimrc.deoplete ~/.vim/vimrc.deoplete
  $ ln -sf ~/git/myConfigs/vim/vimrc.filetype ~/.vim/vimrc.filetype
  $ ln -sf ~/git/myConfigs/vim/vimrc.goyo ~/.vim/vimrc.goyo
  $ ln -sf ~/git/myConfigs/vim/vimrc.mappings ~/.vim/vimrc.mappings
  $ ln -sf ~/git/myConfigs/vim/vimrc.neocomplete ~/.vim/vimrc.neocomplete
  $ ln -sf ~/git/myConfigs/vim/vimrc.neovim ~/.vim/vimrc.neovim
  $ ln -sf ~/git/myConfigs/vim/vimrc.nerdtree ~/.vim/vimrc.nerdtree
  $ ln -sf ~/git/myConfigs/vim/vimrc.theme ~/.vim/vimrc.theme

  $ ln -sf ~/git/myConfigs/vim/themes/vimrc.theme.sourcerer ~/.vim/vimrc.colortheme

  $ ln -sf ~/.vim ~/.config/nvim
  ```

## Installation on Windows

1. Prerequisites

  - [Lua](http://luabinaries.sourceforge.net/download.html)
  - [Python](https://www.python.org/downloads/)
  - [Python3](https://www.python.org/downloads/)
  - [Ruby](http://rubyinstaller.org/downloads/)

  Make sure their executables are in `%PATH%`.

2. Vim files

  Make directory `vimfiles` in `%USERPROFILE%`. **NOTE**: `%USERPROFILE%` must be all english characters and no spaces.

  Copy `vimrc`, `vimrc.airline`, `vimrc.gitgutter`, `vimrc.neocomplete`, `vimrc.unite` to `%USERPROFILE%\vimfiles`.

  Copy `vimrc.theme.NAME` to `%USERPROFILE%\vimfiles\vimrc.theme`, which `NAME` is the theme you choose.

  Copy folder `colors` and `snippets` to `%USERPROFILE%\vimfiles`.

  Make directory `swap` in `%USERPROFILE%\vimfiles`.

3. Git

  On Windows, [Git-for-Windows](https://github.com/git-for-windows/git) uses MSYS2, and its x64 version will cause an internal error when reading the windows environment which is bigger than 32KB. See [this issue](https://github.com/Alexpux/MSYS2-packages/issues/25) and [this issue](https://github.com/git-for-windows/git/issues/942).

  So, on Windows, if you want to run gVim with Git, install x86 version Git-for-windows instead.

4. NeoBundle

  In `%USERPROFILE%\vimfiles`, run:

  ```shell
  git clone git@github.com:Shougo/neobundle.vim.git ~/.vim/bundle/neobundle.vim
  ```

5. Start gVim and install plugins

6. Compile vimproc.vim binary

  To build with Visual Studio, you must install Windows SDK and run from VS command prompt.

  If you use MSVC 11 or later, you need to specify where the Win32.mak file is, e.g.:

  ```shell
  $ nmake -f make_msvc.mak nodebug=1 "SDK_INCLUDE_DIR=C:\Program Files (x86)\Microsoft SDKs\Windows\v7.1A\Include"
  ```

  The architecture will be automatically detected, but you can also specify the architecture explicitly. E.g.:

  ```shell
  32bit: nmake -f make_msvc.mak nodebug=1 CPU=i386
  64bit: nmake -f make_msvc.mak nodebug=1 CPU=AMD64
  ```
