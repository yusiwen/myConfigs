VIM Installation
================

## Prerequisites

`cscope`, `exuberant ctags`, `lua`, `ag`, `python`, `python3`, `ruby`, `perl`

## Installation

1. Install vim:

	```text
	$ sudo apt-get install vim-gtk
	```

	As for windows, check out [kybu Windows build](https://bitbucket.org/kybu/vim-for-windows-single-drop), it supports `Ruby`, `Python`, `Perl`, `Lua`, etc. Or [tuxproject](http://tuxproject.de/projects/vim) , supports both x86 (32-bit) and x64 (64-bit) architectures, compiled with Xpm and DirectX support, provides "huge" feature set and scripting interfaces for `Tcl`, `Python` 2, `Python` 3, `Ruby`, `Lua`, `Racket`, and `Perl`.

	As for Mac, using `brew install vim macvim ctags cscope lua`.

	As for the latest build, try `ppa:pkg-vim/vim-daily`.

1. Install Vundle or NeoBundle

	```text
	$ git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
	```

	or

	```text
	$ git clone https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
	```

1. Link vimrc to ~/.vimrc

	```text
	$ ln -sf ~/git/myConfigs/vim/vimrc ~/.vimrc
	```

1. Install plugins:

	Launch `vim` and run `:PluginInstall`(Vundle) or `:NeoBundleInstall`(NeoBundle)

	To install from command line: `vim +PluginInstall +qall` or `vim +NeoBundleInstall +qall`

1. About 'lucius.vim' theme of 'vim-airline.vim'

    The latest 'lucius' theme has wrong colors, use my fork 'yusiwen/vim-airline-themes' instead.

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
