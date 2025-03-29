#!/usr/bin/env bash

function _install_ctags() { #{{{
  if [ "$OS" = 'Linux' ]; then
    if [ "$DISTRO" = 'Ubuntu' ] || [ "$DISTRO" = 'Debian' ]; then
      set +e
      PACKAGE=$(dpkg -l | grep exuberant-ctags | cut -d ' ' -f 3 | grep -c ^exuberant-ctags$)
      set -e
      if [ "$PACKAGE" -eq 1 ]; then
        echo -e "${COLOR}Finding exuberant-ctags, it's very old, uninstalling it..${NC}"
        $SUDO apt purge exuberant-ctags
      fi
      $SUDO env NEEDRESTART_MODE=a apt-get install -y autoconf pkg-config
    elif [ "$DISTRO" = 'CentOS' ]; then
      if [ "$OS_VERSION" = '"7"' ]; then
        $SUDO yum install -y pkgconfig autoconf automake python36-docutils libseccomp-devel jansson-devel libyaml-devel libxml2-devel
      else
        $SUDO yum install -y pkgconfig autoconf automake python3-docutils libseccomp-devel jansson-devel libyaml-devel libxml2-devel
      fi
    fi

    if [ ! -d ~/git/universal-ctags ]; then
      mkdir -p ~/git
      if ! check_command git; then
        install_git
      fi
      pushd ~/git
      git clone https://github.com/universal-ctags/ctags.git universal-ctags
      cd ~/git/universal-ctags
      ./autogen.sh
      ./configure --prefix=/usr/local
      make -j4
      $SUDO make install
      popd && popd
    fi
  elif [ "$OS" = 'Darwin' ]; then
    brew install --HEAD universal-ctags/universal-ctags/universal-ctags
  fi
} # }}}