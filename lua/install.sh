#!/usr/bin/env bash

function _install_lua() { # {{{
  if [ "$OS" = 'Linux' ]; then
    if [ "$DISTRO" = 'Ubuntu' ] || [ "$DISTRO" = 'Debian' ]; then
      if ! check_command lua; then
        $SUDO env NEEDRESTART_MODE=a apt-get install -y lua5.3 liblua5.3-dev
      fi
    elif [ "$DISTRO" = 'CentOS' ]; then
      # TODO: fix repo, need further checks
      $SUDO yum install -y lua53u
    fi

    # LuaRocks
    if ! check_command luarocks; then
      $SUDO env NEEDRESTART_MODE=a apt-get install -y liblua5.3-dev
      wget https://luarocks.org/releases/luarocks-3.9.1.tar.gz -O /tmp/luarocks-3.9.1.tar.gz
      tar zxpf /tmp/luarocks-3.9.1.tar.gz -C /tmp
      pushd /tmp/luarocks-3.9.1 || exit
      ./configure && make && sudo make install
      popd || exit
      rm -f /tmp/luarocks-3.9.1.tar.gz
      rm -rf /tmp/luarocks-3.9.1
    fi
  fi

} # }}}