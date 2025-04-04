#!/usr/bin/env bash

function check_python3_version() { # {{{
  local PYTHON_VERSION
  PYTHON_VERSION=$(python3 -c 'import sys; version=sys.version_info[:3]; print("{0}.{1}.{2}".format(*version))')
  echo -e "${COLOR}Detect Python3 version: $PYTHON_VERSION${NC}"
} # }}}

function _install_miniconda3() { # {{{
  if ! check_command conda; then
    if [ -d /opt/miniconda3 ]; then
      $SUDO mv /opt/miniconda3 /opt/miniconda3.old
    fi
    $SUDO mkdir -p /opt/miniconda3
    wget "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-${OS_ARCH}.sh" -O /tmp/miniconda.sh
    $SUDO bash /tmp/miniconda.sh -b -u -p /opt/miniconda3
  fi
} # }}}

function _install_python() { # {{{
  if [ "$OS" = 'Linux' ]; then

    if ! check_command python3; then
      if [ "$DISTRO" = 'Ubuntu' ] || [ "$DISTRO" = 'Debian' ]; then
        gum spin --show-error --title "Installing python3..." -- \
          bash -c "$SUDO env NEEDRESTART_MODE=a DEBIAN_FRONTEND=noninteractive apt-get -qq install -y python3"
      elif [ "$DISTRO" = 'CentOS' ]; then
        local target_version
        if [ "$OS_VERSION" = '7' ]; then
          target_version='el7'
        elif [ "$OS_VERSION" = '8' ]; then
          target_version='el8'
        else
          echo -e "${COLOR}OS version ${COLOR1}$OS_VERSION${COLOR} not supported yet${NC}"
          exit 1
        fi
        $SUDO yum upgrade ca-certificates
        curl -L "https://share.yusiwen.cn/public/python/python3.8.18-$target_version.tar.gz" -o "/tmp/python3.8.18.tar.gz"
        $SUDO tar -xzf "/tmp/python3.8.18.tar.gz" -C /usr/local/ --strip-components=1
        rm -f "/tmp/python3.8.18.tar.gz"
      else
        echo -e "${COLOR}Distro ${COLOR1}$DISTRO${COLOR} not supported yet${NC}"
        return
      fi
    fi

    check_python3_version

    if ! check_command pip3; then
      echo -e "${COLOR}Installing ${COLOR1}pip3${COLOR}...${NC}"
      if [ "$DISTRO" = 'Ubuntu' ] || [ "$DISTRO" = 'Debian' ]; then
        gum spin --show-error --title "Installing python3-pip..." -- \
          bash -c "$SUDO env NEEDRESTART_MODE=a DEBIAN_FRONTEND=noninteractive apt-get -qq install -y python3-pip"
        $SUDO update-alternatives --install /usr/bin/python python /usr/bin/python3 20
      elif [ "$DISTRO" = 'Manjaro' ]; then
        yay -S python-pip
      fi
    fi

    if ! check_command pipx; then
      echo -e "${COLOR}Installing ${COLOR1}pipx${COLOR}...${NC}"
      if [ "$DISTRO" = 'Ubuntu' ] || [ "$DISTRO" = 'Debian' ]; then
        gum spin --show-error --title "Installing pipx..." -- \
          bash -c "$SUDO env NEEDRESTART_MODE=a DEBIAN_FRONTEND=noninteractive apt-get -qq install -y pipx"
      else
        python3 -m pip install --user pipx
      fi
    fi

    if [ -n "$MIRRORS" ] && [ "$MIRRORS" -eq 1 ]; then
      mkdir -p "$HOME"/.pip
      if [ -d "$HOME"/myConfigs ]; then
        check_link "$HOME"/myConfigs/python/pip.conf "$HOME"/.pip/pip.conf
      else
        # Using aliyun as mirror
        {
          echo '[global]'
          echo 'index-url = https://mirrors.aliyun.com/pypi/simple/'
          echo ''
          echo '[install]'
          echo 'trusted-host=mirrors.aliyun.com'
        } >>"$HOME"/.pip/pip.conf
      fi
    fi

    # Install utilities
    pipx install pip_search bpytop

    # Install Miniconda3
    _install_miniconda3
    
  elif [ "$OS" = 'Darwin' ]; then
    if ! check_command brew; then
      init_env
    fi

    # Homebrew's python has pip included
    brew install python

    mkdir -p "$HOME"/.config/pip
    echo "[global]" >"$HOME"/.config/pip/pip.conf
    echo "index-url = https://mirrors.ustc.edu.cn/pypi/web/simple" >>"$HOME"/.config/pip/pip.conf

    if ! check_command pipx; then
      echo -e "${COLOR}Installing ${COLOR1}pipx${COLOR}...${NC}"
      brew install pipx
    fi

    pipx install --user pip_search bpytop
  elif [ "$OS" = 'Windows_NT' ]; then
    echo -e "${COLOR}Please install Pyhton runtime manually or from Microsoft Store.${NC}"
    echo -e "${COLOR}Please install Conda environment manually from:${NC}"
    echo -e "\thttps://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe?file=Miniconda3-latest-Windows-x86_64.exe"
    echo -e "\thttps://www.anaconda.com/download/"
  else
    echo -e "${COLOR}OS not supported${NC}"
    return
  fi
} # }}}