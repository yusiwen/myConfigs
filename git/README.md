GIT
===

Git configuration scripts.

# Editor

```
$ git config --global core.editor "vim"
```

Or set the GIT_EDITOR, VISUAL, or EDITOR environment variables.

```
export GIT_EDITOR=vim
export VISUAL=vim
export EDITOR=vim
```

### Proxy

1. Using shadowsocks-qt5 as SOCKS5 proxy:

```text
$ git config --global http.proxy 'socks5://127.0.0.1:1088'
$ git config --global https.proxy 'socks5://127.0.0.1:1088'
```

2. Set shadowsocks-qt5 as proxy for SSH protocol:

In `~/.ssh/config` file, add following settings

```text
Host github.com
  User git
  ProxyCommand nc -x 127.0.0.1:1088 %h %p

Host bitbucket.org
  User git
  ProxyCommand nc -x 127.0.0.1:1088 %h %p
```
