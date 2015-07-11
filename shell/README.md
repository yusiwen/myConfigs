Shell Scripts
=============

##Install oh-my-zsh

1. Install `zsh`

```sh
$ sudo apt-get install zsh
```

2. Install `oh-my-zsh`

```sh
$ ln -sf $HOME/myConfigs/shell/oh-my-zsh $HOME/.oh-my-zsh
$ ln -sf $HOME/myConfigs/shell/zshrc $HOME/.zshrc
```

4. Set zsh as default shell:

```sh
$ chsh -s /bin/zsh
```

5. Logoff and login again

6. Install [`ls--`](https://github.com/yusiwen/ls--)

```sh
$ git clone https://github.com/yusiwen/ls--
$ cd ls-- && cp ls++.conf $HOME/.ls++.conf
$ sudo cp ls++ /usr/local/bin/ls++
```

