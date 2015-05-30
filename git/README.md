GIT
===

Git configuration scripts.

# Editor

```
git config --global core.editor "vim"
```

Or set the GIT_EDITOR, VISUAL, or EDITOR environment variables.

```
export GIT_EDITOR=vim
export VISUAL=vim
export EDITOR=vim
```

# Proxy

Using shadowsocks-qt5 as SOCKS5 proxy:

```text
$ git config --global http.proxy 'socks5://127.0.0.1:1088'
$ git config --global https.proxy 'socks5://127.0.0.1:1088'
```
