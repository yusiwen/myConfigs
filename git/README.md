# GIT

Git configuration scripts.

## Editor

```sh
git config --global core.editor "vim"
```

Or set the GIT_EDITOR, VISUAL, or EDITOR environment variables.

```sh
export GIT_EDITOR=vim
export VISUAL=vim
export EDITOR=vim
```

## Mergetool

Using `vimdiff` as git's Mergetool, see [this post](http://www.rosipov.com/blog/use-vimdiff-as-git-mergetool/) for more details.

```sh
git config merge.tool vimdiff
git config merge.conflictstyle diff3
git config mergetool.prompt false
```

or

```sh
git config --global merge.tool vimdiff
git config --global merge.conflictstyle diff3
git config --global mergetool.prompt false
```

## Proxy

1. Using shadowsocks-qt5 as SOCKS5 proxy:

    ```sh
    git config --global http.proxy 'socks5://127.0.0.1:1088'
    git config --global https.proxy 'socks5://127.0.0.1:1088'
    ```

1. Set shadowsocks-qt5 as proxy for SSH protocol:

    In `~/.ssh/config` file, add following settings

    ```text
    Host github.com
      User git
      ProxyCommand nc -x 127.0.0.1:1088 %h %p
      ### For Git Bash under windows:
      #ProxyCommand connect -S 127.0.0.1:1088 %h %p

    Host bitbucket.org
      User git
      ProxyCommand nc -x 127.0.0.1:1088 %h %p
      ### For Git Bash under windows:
      #ProxyCommand connect -S 127.0.0.1:1088 %h %p
    ```

    or use `core.gitProxy` setting (recommanded for global proxying):

    ```sh
    git config --global core.gitproxy ~/myConfigs/git/gitproxy
    ```
