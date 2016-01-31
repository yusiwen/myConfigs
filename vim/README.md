VIM Installation
================

##Prerequisites

`cscope`, `exuberant ctags`, `lua`, `ag`

1. Install vim:

	```text
	$ sudo apt-get install vim-gtk
	```

	As for windows, check out [kybu Windows build](https://bitbucket.org/kybu/vim-for-windows-single-drop), it supports `ruby`, `python`, `perl`, `lua`, etc.

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

1. Install vim-instant-markdown plugin

	- Required libraries: `ruby`, `xdg-utils`, `nodejs`

	- Add `Bundle 'vim-scripts/instant-markdown.vim'` in `.vimrc` to let `vundle` get this plugin

	- Get `instant-markdown-d` in npm:

		```text
		$ npm -g install instant-markdown-d
		```

	- Install ruby libraries:

		```text
		$ sudo gem install redcarpet pygments.rb
		```

1. Install lucius theme for airline

  [link](https://github.com/jonathanfilip/lucius/blob/master/vim-airline/lucius.vim)
