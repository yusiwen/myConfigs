VIM Installation
================

1. Install vim:

	```text
	sudo apt-get install vim-gtk
	```

  As for windows, check out [kybu Windows build](https://bitbucket.org/kybu/vim-for-windows-single-drop), it supports `ruby`, `python`, `perl`, `lua`, etc.

  As for the latest build, try `ppa:pkg-vim/vim-daily`.

1. Install vundle

	```text
	git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/vundle
	```

1. Link vimrc to ~/.vimrc

	```text
	ln -sf ~/git/myConfigs/vim/vimrc ~/.vimrc
	```

1. Install plugins:

	 Launch `vim` and run `:PluginInstall`

	 To install from command line: `vim +PluginInstall +qall`

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
