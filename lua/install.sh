#!/usr/bin/env bash

function _install_lua() { # {{{
  if [ "$OS" = 'Linux' ]; then
    if [ "$DISTRO" = 'Ubuntu' ] || [ "$DISTRO" = 'Debian' ]; then
      if ! check_command lua; then
        gum spin --show-error --title "Installing lua..." -- \
          bash -c "$SUDO env NEEDRESTART_MODE=a DEBIAN_FRONTEND=noninteractive apt-get -qq install -y lua5.3 liblua5.3-dev"
      fi
    elif [ "$DISTRO" = 'CentOS' ]; then
      # TODO: fix repo, need further checks
      $SUDO yum install -y lua53u
    fi

    # LuaRocks
    if ! check_command luarocks; then
      if [ "$DISTRO" = 'Ubuntu' ] || [ "$DISTRO" = 'Debian' ]; then
        gum spin --show-error --title "Installing liblua5.3-dev..." -- \
          bash -c "$SUDO env NEEDRESTART_MODE=a DEBIAN_FRONTEND=noninteractive apt-get -qq install -y liblua5.3-dev"
      fi
      wget https://luarocks.org/releases/luarocks-3.9.1.tar.gz -O /tmp/luarocks-3.9.1.tar.gz
      tar zxpf /tmp/luarocks-3.9.1.tar.gz -C /tmp
      pushd /tmp/luarocks-3.9.1 || exit
      gum spin --show-error --title "Building luarocks-3.9.1..." -- \
        bash -c "./configure && make && $SUDO make install"
      popd || exit
      rm -f /tmp/luarocks-3.9.1.tar.gz
      rm -rf /tmp/luarocks-3.9.1
    fi
  elif [ "$OS" = 'Darwin' ]; then
    brew install luarocks
  fi

} # }}}