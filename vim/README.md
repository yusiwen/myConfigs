VIM Installation
================

1. Install vim:

`sudo apt-get install vim`

2. Install vundle

`git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/vundle`

3. Link vimrc to ~/.vimrc

`ln -sf ~/git/myConfigs/vim/vimrc ~/.vimrc`

4. Install plugins:

   Launch `vim` and run `:PluginInstall`

   To install from command line: `vim +PluginInstall +qall`

