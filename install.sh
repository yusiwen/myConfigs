#!/usr/bin/env bash

# ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗        ███████╗██╗  ██╗
# ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║        ██╔════╝██║  ██║
# ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║        ███████╗███████║
# ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║        ╚════██║██╔══██║
# ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗██╗███████║██║  ██║
# ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝╚══════╝╚═╝  ╚═╝
#
# Installation script for my tools & environments
# http://git.io/vtVXR
# yusiwen@gmail.com

# Global variables {{{
COLOR='\033[1;34m'  # Highlighted white
COLOR1='\033[1;32m' # Highligted green
COLOR2='\033[1;33m' # Highligted yellow
NC='\033[0m'

OS=$(uname)
OS_ARCH=$(uname -m)
ARCH=
if [ "$OS_ARCH" = 'x86_64' ]; then
  ARCH='amd64'
elif [ "$OS_ARCH" = 'aarch64' ]; then
  ARCH='arm64'
else
  ARCH=
fi
CODENAME=
OS_NAME=
OS_VERSION=
MIRRORS=0
DISTRO=

if [ -n "$WINDIR" ]; then
  OS='Windows_NT'
  tmp_str=$(cmd //C ver)
  tmp_str="${tmp_str//[$'\t\r\n']/}"
  OS_NAME=$(echo $tmp_str | cut -d '[' -f1)
  OS_VERSION=$(echo $tmp_str | cut -d ' ' -f4 | cut -d ']' -f1)
  DISTRO=$(uname)
else
  if [ -e /etc/os-release ]; then
    ID=$(grep "^ID=" /etc/os-release | cut -d'=' -f2)
    ID_LIKE=$(awk -F= '/^ID_LIKE/{print $2}' /etc/os-release | xargs | cut -d ' ' -f1)
    if [ "$ID" = 'ubuntu' ] || [ "$ID_LIKE" = 'ubuntu' ]; then
      DISTRO='Ubuntu'
      CODENAME=$(grep "^UBUNTU_CODENAME" /etc/os-release | cut -d'=' -f2)
    elif [ "ID" = 'Deepin' ]; then
      DISTRO='Deepin'
      CODENAME='buster'
    else
      DISTRO=$(awk -F= '/^NAME/{print $2}' /etc/os-release | xargs | cut -d ' ' -f1)
    fi
    OS_NAME=$(awk -F= '/^NAME/{print $2}' /etc/os-release | xargs | cut -d ' ' -f1)
    OS_VERSION=$(grep "^VERSION_ID" /etc/os-release | cut -d'=' -f2)
  else
    DISTRO=$OS
  fi
fi
echo -e "${COLOR}Operating System: ${COLOR1}$OS${COLOR} found...${NC}"
echo -e "${COLOR}Distribution: ${COLOR1}$DISTRO ($OS_NAME $OS_VERSION)${COLOR} found...${NC}"

SUDO=
if [ "$OS" = 'Linux' ]; then
  if [ $EUID -ne 0 ]; then
    SUDO=sudo
  fi
fi
# }}}

set -e
set -o pipefail

function make_link() { # {{{
  local target=("$1") linkname=("$2")
  ln -sfnv "$target" "$linkname"
}
# }}}

function check_link() { # {{{
  if [ -z "$1" ] || [ -z "$2" ]; then
    return
  fi

  local target=("$1") linkname=("$2")
  echo -e "${COLOR}Checking link ${COLOR1}'${linkname}'${COLOR} to ${COLOR1}'${target}'${COLOR}...${NC}"
  if [ ! -e "${linkname}" ]; then
    make_link ${target} ${linkname}
  else
    if [ -L "${linkname}" ]; then
      if [ $(readlink -f ${linkname}) = $(readlink -f ${target}) ]; then
        echo -e "${COLOR}Link ${COLOR1}'${linkname}'${COLOR} to ${COLOR1}'${target}'${COLOR} already exists${NC}"
        return
      else
        make_link ${target} ${linkname}
        return
      fi
    else
      mv ${linkname} ${linkname}.backup
      make_link ${target} ${linkname}
    fi
  fi
} # }}}

function get_latest_release_from_github() { # {{{
  # Thanks to: https://gist.github.com/lukechilds/a83e1d7127b78fef38c2914c4ececc3c
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
} # }}}

# Initialize apt and install prerequisite packages
function init_env() { # {{{
  if [ "$OS" = 'Linux' ]; then
    if [ "$DISTRO" = 'Ubuntu' ] || [ "$DISTRO" = 'Debian' ]; then
      if [ -n "$MIRRORS" ] && [ "$MIRRORS" -eq 1 ]; then
        echo -e "${COLOR}Setting Ubuntu apt source to aliyun...${NC}"
        $SUDO cp /etc/apt/sources.list /etc/apt/sources.list.backup
        if [ "$OS_ARCH" = 'aarch64' ]; then
          $SUDO sed -i "s/ports\.ubuntu\.com/mirrors\.ustc\.edu\.cn/g" /etc/apt/sources.list
        else
          $SUDO sed -i "s/^deb http:\/\/.*archive\.ubuntu\.com/deb http:\/\/mirrors\.aliyun\.com/g" /etc/apt/sources.list
        fi

        if ls /etc/apt/sources.list.d/*.list 1>/dev/null 2>&1; then
          $SUDO sed -i "s/http:\/\/ppa\.launchpad\.net/https:\/\/launchpad\.proxy\.ustclug\.org/g" /etc/apt/sources.list.d/*.list
        fi
      fi

      $SUDO apt update
      $SUDO apt install -y curl lua5.3 perl cpanminus silversearcher-ag p7zip-full gdebi-core \
                           iotop net-tools iftop nethogs nload sysstat apt-transport-https jq \
                           tmux byobu htop atop software-properties-common \
                           build-essential ethtool cifs-utils nfs-common libfuse2 pigz
      # Check if ubuntu version is newer than 20.04
      if [ -n "$(echo ${OS_VERSION} | awk '$1 >= 20.04 { print "ok"; }')" ]; then
        $SUDO apt install -y bat
      else
        echo -e "${COLOR}Installing batcat from DEB pacakge...${NC}"
        BATCAT_DOWNLOAD_URL="https://share.yusiwen.cn/public/bat_0.22.1_amd64.deb"
        if [ "$OS_ARCH" = 'aarch64' ]; then
          BATCAT_DOWNLOAD_URL="https://share.yusiwen.cn/public/bat_0.22.1_arm64.deb"
        fi
        wget "${BATCAT_DOWNLOAD_URL}" -O /tmp/batcat.deb
        $SUDO dpkg --install /tmp/batcat.deb
      fi
    elif [ "$DISTRO" = 'Manjaro' ]; then
      yay -S base-devel the_silver_searcher tmux byobu bat
    elif [ "$DISTRO" = 'CentOS' ]; then
      if [ "$OS_VERSION" = '"7"' ]; then
        $SUDO yum --enablerepo=epel -y \
                  install fuse-sshfs net-tools telnet ftp lftp libaio \
                  libaio-devel bc man lsof wget tmux byobu
      else
        $SUDO yum config-manager --set-enabled PowerTools
        $SUDO yum install -y epel-release
        $SUDO yum update -y
        $SUDO yum install -y fuse-sshfs net-tools telnet ftp lftp libaio libaio-devel bc man lsof wget tmux
      fi
    fi
    install_rust
    install_git
    fetch_myConfigs
    install_ruby
    install_python
    # Install gittyleaks after python is initialized 
    pip3 install gittyleaks
    install_sdkman
    install_golang
  elif [ "$OS" = 'Darwin' ]; then
    if ! type brew >/dev/null 2>&1; then
      echo -e "${COLOR}Installing ${COLOR1}HomeBrew${COLOR}...${NC}"
      # On MacOS ruby is pre-installed already
      /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
    install_rust
  elif [ "$OS" = 'Windows_NT' ]; then
    echo -e "${COLOR}Please install Chocolatey (https://chocolatey.org/install), then executes:${NC}"
    echo -e "${COLOR}choco install bat delta${NC}"

    # exa is currently not supported on Windows, see: https://github.com/ogham/exa/issues/32
    # echo -e "${COLOR}Please install Rust (https://forge.rust-lang.org/infra/other-installation-methods.html), then executes:${NC}"
    # echo -e "${COLOR}cargo install exa${NC}"
  fi
} # }}}

# Universal Ctags
function install_universal_ctags() { # {{{
  if [ "$OS" = 'Linux' ]; then
    if [ "$DISTRO" = 'Ubuntu' ] || [ "$DISTRO" = 'Debian' ]; then
      set +e
      PACKAGE=$(dpkg -l | grep exuberant-ctags | cut -d ' ' -f 3 | grep -c ^exuberant-ctags$)
      set -e
      if [ "$PACKAGE" -eq 1 ]; then
        echo -e "${COLOR}Finding exuberant-ctags, it's very old, uninstalling it..${NC}"
        $SUDO apt purge exuberant-ctags
      fi
      $SUDO apt install -y autoconf pkg-config
    elif [ "$DISTRO" = 'CentOS' ]; then
      if [ "$OS_VERSION" = '"7"' ]; then
        $SUDO yum install -y pkgconfig autoconf automake python36-docutils libseccomp-devel jansson-devel libyaml-devel libxml2-devel
      else
        $SUDO yum install -y pkgconfig autoconf automake python3-docutils libseccomp-devel jansson-devel libyaml-devel libxml2-devel
      fi
    fi

    if [ ! -d ~/git/universal-ctags ]; then
      mkdir -p ~/git
      if ! type git >/dev/null 2>&1; then
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

# Git
function install_git() { # {{{
  if [ "$OS" = 'Linux' ]; then
    if [ "$DISTRO" = 'Ubuntu' ] || [ "$DISTRO" = 'Debian' ]; then
      # install git if not exist
      if ! type git >/dev/null 2>&1; then
        if [ "$DISTRO" = 'Ubuntu' ]; then
          GIT_PPA=/etc/apt/sources.list.d/git-core-ubuntu-ppa-$CODENAME.list
          if [ ! -e "$GIT_PPA" ]; then
            echo -e "${COLOR}Add ${COLOR1}git-core${COLOR} ppa...${NC}"
            $SUDO apt-add-repository -y ppa:git-core/ppa

            if [ ! -z "$MIRRORS" ] && [ "$MIRRORS" -eq 1 ]; then
              # Replace official launchpad address with reverse proxy from USTC
              $SUDO sed -i "s/http:\/\/ppa\.launchpad\.net/https:\/\/launchpad\.proxy\.ustclug\.org/g" "$GIT_PPA"
            fi

            echo -e "${COLOR}Add ${COLOR1}git-core${COLOR} ppa...OK${NC}"
            $SUDO apt update
            $SUDO apt upgrade -y
          else
            echo -e "${COLOR1}ppa:git-core/ppa${COLOR} was found.${NC}"
          fi
        fi
        echo -e "${COLOR}Installing ${COLOR1}git-core${COLOR}...${NC}"
        $SUDO apt install -y git
        echo -e "${COLOR}Installing ${COLOR1}git-core${COLOR}...OK${NC}"
      else
        echo -e "${COLOR1}git${COLOR} was found.${NC}"
      fi

      if ! type tig >/dev/null 2>&1; then
        echo -e "${COLOR}Installing ${COLOR1}tig${COLOR}...${NC}"
        $SUDO apt install -y tig
        echo -e "${COLOR}Installing ${COLOR1}tig${COLOR}...OK${NC}"
      else
        echo -e "${COLOR1}tig${COLOR} was found.${NC}"
      fi
    elif [ "$DISTRO" = 'Manjaro' ]; then
      # Manjaro has git installed already
      if ! type tig >/dev/null 2>&1; then
        echo -e "${COLOR}Installing ${COLOR1}tig${COLOR}...${NC}"
        yay -S tig
        echo -e "${COLOR}Installing ${COLOR1}tig${COLOR}...OK${NC}"
      else
        echo -e "${COLOR1}tig${COLOR} was found.${NC}"
      fi
    elif [ "$DISTRO" = 'CentOS' ]; then
      if [ "$OS_VERSION" = '"7"' ]; then
        PACKAGE=$(yum list installed | grep -c ^ius-release.noarch)
        if [ "$PACKAGE" = 0 ]; then
          $SUDO yum -y install https://centos7.iuscommunity.org/ius-release.rpm
        fi

        $SUDO yum -y install git2u-all
      else
        $SUDO yum -y install git
      fi
    else
      echo -e "${COLOR}Distro ${COLOR1}$DISTRO${COLOR} not supported yet${NC}"
      return
    fi
  elif [ "$OS" = 'Darwin' ]; then
    brew install git
  elif [ "$OS" = 'Windows_NT' ]; then
    if ! type git >/dev/null 2>&1; then
      echo -e "${COLOR}Please download git-for-windows from https://git-scm.com/ and install it manually${NC}"
      return
    fi
  else
    echo -e "${COLOR}OS not supported${NC}"
    return
  fi

  echo -e "${COLOR}Configuring...${NC}"
  echo -e "${COLOR}Setting 'user.email' to 'yusiwen@gmail.com'${NC}"
  git config --global user.email "yusiwen@gmail.com"

  echo -e "${COLOR}Setting 'user.name' to 'Siwen Yu'${NC}"
  git config --global user.name "Siwen Yu"

  echo -e "${COLOR}Setting line feed behavior...${NC}"
  if [ "$OS" = "Windows_NT" ]; then
    # On Windows, commit with LF and checkout with CRLF
    git config --global core.autocrlf true
  else
    # On Linux or Mac, commit with LF and no change on checkout
    git config --global core.autocrlf input
  fi
  # Turn on warning on convert EOL failure
  git config --global core.safecrlf warn

  echo -e "${COLOR}Setting misc...${NC}"
  git config --global core.editor vim
  if [ "$OS" = 'Windows_NT' ]; then
    if [ ! -z "$APP_HOME" ]; then
      git config --global core.editor "$APP_HOME/GitExtensions/GitExtensions.exe fileeditor"
    fi
  fi
  git config --global pull.rebase true
  git config --global fetch.prune true
  git config --global merge.tool vimdiff
  git config --global merge.conflictstyle diff3
  git config --global mergetool.prompt false
  git config --global diff.colorMoved zebra

  if type delta >/dev/null 2>&1; then
    git config --global core.pager "delta --line-numbers"
    git config --global interactive.diffFilter "delta --color-only --line-numbers"
    git config --global delta.navigate true
    git config --global delta.features decorations
    git config --global delta.interactive.keep-plus-minus-markers false
    git config --global delta.decorations.commit-decoration-style "blue ol"
    git config --global delta.decorations.commit-style raw
    git config --global delta.decorations.file-style omit
    git config --global delta.decorations.hunk-header-decoration-style "blue box"
    git config --global delta.decorations.hunk-header-file-style red
    git config --global delta.decorations.hunk-header-line-number-style "#067a00"
    git config --global delta.decorations.hunk-header-style "file line-number syntax"
  elif type diff-so-fancy >/dev/null 2>&1; then
    git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
  fi

  if [ "$OS" = 'Linux' ]; then
    git config --global credential.helper store
  fi

  if [ -e "$HOME"/.ssh/id_rsa.pub ]; then
    echo -e "${COLOR1}.ssh/id_rsa.pub${COLOR} was found, please add it to GitHub, BitBucket, GitLab and Gitea${NC}"
    cat "$HOME"/.ssh/id_rsa.pub
  else
    echo -e "${COLOR1}.ssh/id_rsa.pub${COLOR} was not found, generating it now...${NC}"
    ssh-keygen
    echo -e "${COLOR}Please add it to GitHub, BitBucket, Gitlab and Gitea${NC}"
    cat "$HOME"/.ssh/id_rsa.pub
  fi

  echo -e "${COLOR}You need 'commitizen', 'cz-customizable' to run git commit conventions, run './install.sh node' to setup.${NC}"
} # }}}

function install_ruby() { # {{{
  if [ "$OS" = 'Linux' ]; then
    if [ "$DISTRO" = 'Ubuntu' ] || [ "$DISTRO" = 'Debian' ]; then
      if ! type ruby >/dev/null 2>&1; then
        echo -e "${COLOR}Installing ${COLOR1}Ruby${COLOR}...${NC}"
        $SUDO apt install -y ruby-full curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev libffi-dev
        echo -e "${COLOR}Installing ${COLOR1}Ruby${COLOR}...OK${NC}"
      else
        echo -e "${COLOR1}ruby${COLOR} was found.${NC}"
        set +e
        PACKAGE=$(dpkg -l | grep -c ruby-full)
        set -e
        if [ "$PACKAGE" -eq 0 ]; then
          echo -e "${COLOR}Installing ${COLOR1}ruby-full${COLOR}...${NC}"
          $SUDO apt install -y ruby-full
        fi
      fi
    elif [ "$DISTRO" = 'Manjaro' ]; then
      if ! type ruby >/dev/null 2>&1; then
        echo -e "${COLOR}Installing ${COLOR1}Ruby${COLOR}...${NC}"
        yay -S ruby
        echo -e "${COLOR}Installing ${COLOR1}Ruby${COLOR}...OK${NC}"
      else
        echo -e "${COLOR1}ruby${COLOR} was found.${NC}"
      fi
    else
      echo -e "${COLOR}Distro ${COLOR1}$DISTRO${COLOR} not supported yet${NC}"
      return
    fi
  elif [ "$OS" = 'Darwin' ]; then
    if ! type ruby >/dev/null 2>&1; then
      brew install ruby
    else
      echo -e "${COLOR1}ruby${COLOR} was found.${NC}"
    fi
  else
    echo -e "${COLOR}OS not supported${NC}"
    return
  fi

  echo -e "${COLOR}Replace official repo with Ruby-China mirror...${NC}"
  gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/
  gem sources -l
  echo -e "${COLOR}Replace official repo with Ruby-China mirror...OK${NC}"

  PATH="$(ruby -e 'puts Gem.user_dir')/bin:$PATH"
  export PATH
  if ! type bundle >/dev/null 2>&1; then
    echo -e "${COLOR}Installing bundler...${NC}"
    gem install --user-install bundler
    echo -e "${COLOR}Installing bundler...OK${NC}"
  else
    echo -e "${COLOR1}bundler${COLOR} was found.${NC}"
  fi

  echo -e "${COLOR}Configurate bundler to use Ruby-China mirror...${NC}"
  bundle config mirror.https://rubygems.org https://gems.ruby-china.com
  echo -e "${COLOR}Configurate bundler to use Ruby-China mirror...OK${NC}"
} # }}}

# Initialize myConfigs repo
function fetch_myConfigs() { # {{{
  if ! type git >/dev/null 2>&1; then
    install_git
  fi

  mkdir -p "$HOME"/git
  if [ -d "$HOME"/git/myConfigs ]; then
    echo -e "${COLOR1}git/myConfigs${COLOR} already exists.${NC}"
  else
    echo -e "${COLOR}Fetch myConfigs...${NC}"
    git clone https://github.com/yusiwen/myConfigs.git "$HOME"/git/myConfigs
    git -C "$HOME"/git/myConfigs submodule update --init
  fi
  ln -sfnv "$HOME"/git/myConfigs "$HOME"/myConfigs

  if [ "$OS" = 'Linux' ] || [ "$OS" = 'Darwin' ]; then
    mkdir -p "$HOME"/.ssh
    if [ -n "$MIRRORS" ] && [ "$MIRRORS" -eq 1 ]; then
      ln -sfnv "$HOME"/myConfigs/git/ssh_config.mirror "$HOME"/.ssh/config
    else
      ln -sfnv "$HOME"/myConfigs/git/ssh_config "$HOME"/.ssh/config
    fi

    mkdir -p "$HOME"/.local/bin
    ln -sfnv "$HOME"/myConfigs/git/git-migrate "$HOME"/.local/bin/git-migrate
    ln -sfnv "$HOME"/myConfigs/git/git-new-workdir "$HOME"/.local/bin/git-new-workdir
    ln -sfnv "$HOME"/myConfigs/git/repos.sh "$HOME"/.local/bin/repos
  fi
} # }}}

function check_python3_version() { # {{{
  local PYTHON_VERSION=$(python3 -c 'import sys; version=sys.version_info[:3]; print("{0}.{1}.{2}".format(*version))')
  echo -e "${COLOR}Detect Python3 version: $PYTHON_VERSION${NC}"

  if [ -z "$(pip3 list | grep packaging)" ]; then
    pip3 install --user packaging
  fi

  local PYTHON_VERSION_COMPARE=$(python3 -c "from packaging import version; print(version.parse('"$PYTHON_VERSION"') > version.parse('3.6'))")

  if [ "$PYTHON_VERSION_COMPARE" != 'True' ]; then
    echo -e "${COLOR2}WARN${COLOR}Python3 version: ${COLOR1}$PYTHON_VERSION${COLOR} is too old, need latest package${NC}"
  fi
} # }}}

function install_python() { # {{{
  if [ "$OS" = 'Linux' ]; then

    # Check python2
    if ! type python2 &>/dev/null; then
      if [ "$DISTRO" = 'Ubuntu' ] || [ "$DISTRO" = 'Debian' ]; then
        $SUDO apt-get install -y python2
      elif [ "$DISTRO" = 'Manjaro' ]; then
        echo -e "${COLOR}python2 is not officially supported by ${COLOR1}$DISTRO${COLOR}...skip${NC}"
      elif [ "$DISTRO" = 'CentOS' ]; then
        echo 'TODO: python2 on CentOS'
      else
        echo -e "${COLOR}Distro ${COLOR1}$DISTRO${COLOR} not supported yet${NC}"
        return
      fi
    fi

    if ! type python3 &>/dev/null; then
      if [ "$DISTRO" = 'Ubuntu' ] || [ "$DISTRO" = 'Debian' ]; then
        $SUDO apt-get install -y python3
      elif [ "$DISTRO" = 'CentOS' ]; then
        if [ "$OS_VERSION" = '"7"' ]; then
          PACKAGE=$(yum list installed | grep -c ^ius-release.noarch)
          if [ "$PACKAGE" = 0 ]; then
            $SUDO yum -y install https://centos7.iuscommunity.org/ius-release.rpm
          fi

          $SUDO yum update -y
          $SUDO yum install -y python36u python36u-pip python2-pip
          $SUDO ln -snv /usr/bin/python3.6 /usr/bin/python3
          $SUDO ln -snv /usr/bin/pip3.6 /usr/bin/pip3
        else
          $SUDO yum install python2 python3
        fi
      else
        echo -e "${COLOR}Distro ${COLOR1}$DISTRO${COLOR} not supported yet${NC}"
        return
      fi
    fi

    if ! type pip2 >/dev/null 2>&1; then
      echo -e "${COLOR}Installing ${COLOR1}pip2${COLOR}...${NC}"
      if [ "$DISTRO" = 'Ubuntu' ] || [ "$DISTRO" = 'Debian' ]; then
        curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output /tmp/get-pip2.py
        $SUDO python2 /tmp/get-pip2.py
      elif [ "$DISTRO" = 'Manjaro' ]; then
        echo -e "${COLOR}python2-pip is not officially supported by ${COLOR1}$DISTRO${COLOR}...skip${NC}"
      fi
    fi

    if ! type pip3 >/dev/null 2>&1; then
      echo -e "${COLOR}Installing ${COLOR1}pip3${COLOR}...${NC}"
      if [ "$DISTRO" = 'Ubuntu' ] || [ "$DISTRO" = 'Debian' ]; then
        $SUDO apt install -y python3-pip
        $SUDO update-alternatives --install /usr/bin/python python /usr/bin/python3 20
      elif [ "$DISTRO" = 'Manjaro' ]; then
        yay -S python-pip
      fi
    fi

    check_python3_version

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

    if ! type virtualenv >/dev/null 2>&1; then
      echo -e "${COLOR}Installing ${COLOR1}virtualenv${COLOR}...${NC}"
      if type pip2 >/dev/null 2>&1; then
        pip2 install --user virtualenv
      fi
      if type pip3 >/dev/null 2>&1; then
        pip3 install --user virtualenv
      fi
    fi
  elif [ "$OS" = 'Darwin' ]; then
    if ! type brew >/dev/null 2>&1; then
      init_env
    fi

    # Homebrew's python has pip included
    brew install python

    mkdir -p "$HOME"/.config/pip
    echo "[global]" >"$HOME"/.config/pip/pip.conf
    echo "index-url = https://mirrors.ustc.edu.cn/pypi/web/simple" >>"$HOME"/.config/pip/pip.conf

    pip install --user virtualenv
    pip3 install --user virtualenv
  else
    echo -e "${COLOR}OS not supported${NC}"
    return
  fi
} # }}}

function install_node() { # {{{
  if [ ! -d "$HOME"/myConfigs ]; then
    fetch_myConfigs
  fi

  if [ -z "$N_PREFIX" ]; then
    echo -e "${COLOR}Installing ${COLOR1}tj/n ${COLOR}...${NC}"
    export N_PREFIX="$HOME/.n"
    curl -sL "https://bit.ly/n-install" | bash -s -- -n -y lts
    export PATH="$PATH:$N_PREFIX/bin"
  else
    echo -e "${COLOR}Found ${COLOR1}tj/n${COLOR} in ${COLOR1}\"$N_PREFIX\"${COLOR}...skip${NC}"
  fi

  if [ ! -e "$HOME"/.npmrc ]; then
    cp "$HOME"/myConfigs/node.js/npmrc "$HOME"/.npmrc
  fi

  if ! type npm &>/dev/null; then
    nvm install stable
  fi

  echo -e "${COLOR1}Installing yarn, eslint...${NC}"
  npm install -g yarn eslint npm-check npm-check-updates nrm
  # Install cli tools for git commit conventions
  echo -e "${COLOR1}Installing conventional-changelog-cli, Commitizen, cz-customizable, standard-version...${NC}"
  npm install -g conventional-changelog-cli commitizen cz-customizable standard-version diff-so-fancy

  if type git >/dev/null 2>&1; then
    git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
  fi
} # }}}

function install_zsh() { # {{{
  CONFIG_SHELL="$HOME"/myConfigs/shell
  if [ ! -d "$CONFIG_SHELL" ]; then
    fetch_myConfigs
  fi

  # Make sure submodules are fetched or updated
  git -C "$HOME/myConfigs" submodule update --init

  if [ "$OS" = 'Linux' ]; then
    if [ ! "$SHELL" = "/usr/bin/zsh" ]; then
      echo -e "${COLOR}Current SHELL is not ${COLOR1}Zsh${NC}"
      if [ ! -e /usr/bin/zsh ]; then
        echo -e "${COLOR}Installing ${COLOR1}Zsh${COLOR}...${NC}"
        if [ "$DISTRO" = 'Ubuntu' ] || [ "$DISTRO" = 'Debian' ]; then
          $SUDO apt install -y zsh
        elif [ "$DISTRO" = 'CentOS' ]; then
          $SUDO yum install -y zsh
          echo '/usr/bin/zsh' | $SUDO tee -a /etc/shells
        fi
      fi
      echo -e "${COLOR}Change SHELL to ${COLOR1}Zsh${COLOR}, take effect on next login${NC}"
      chsh -s /usr/bin/zsh
    fi
  elif [ "$OS" = 'Darwin' ]; then
    if [ ! "$SHELL" = "/usr/local/bin/zsh" ]; then
      echo -e "${COLOR}Current SHELL is not latest ${COLOR1}Zsh${NC}"
      if [ ! -e /usr/local/bin/zsh ]; then
        echo -e "${COLOR}Installing ${COLOR1}Zsh${COLOR}...${NC}"
        brew install zsh
        echo -e "${COLOR}Change SHELL to ${COLOR1}Zsh${COLOR}, take effect on next login${NC}"
        chsh -s /usr/local/bin/zsh
      fi
    fi
  fi

  # Install oh-my-zsh
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    git clone https://github.com/ohmyzsh/ohmyzsh.git $HOME/.oh-my-zsh
  fi

  check_link "$CONFIG_SHELL"/bashrc "$HOME"/.bashrc
  check_link "$CONFIG_SHELL"/bash_aliases "$HOME"/.bash_aliases
  check_link "$CONFIG_SHELL"/bash_profile "$HOME"/.bash_profile
  check_link "$CONFIG_SHELL"/profile "$HOME"/.profile
  check_link "$CONFIG_SHELL"/zshrc "$HOME"/.zshrc

  if [ ! -d "$HOME"/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
    echo -e "${COLOR}Installing ${COLOR1}zsh-autosuggestions${COLOR}...${NC}"
    git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    echo -e "${COLOR}Installing ${COLOR1}zsh-autosuggestions${COLOR}...OK${NC}"
  else
    echo -e "${COLOR}Found ${COLOR1}zsh-autosuggestions${COLOR}...skip${NC}"
  fi

  if [ ! -d "$HOME"/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
    echo -e "${COLOR}Installing ${COLOR1}zsh-syntax-highlighting${COLOR}...${NC}"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    echo -e "${COLOR}Installing ${COLOR1}zsh-syntax-highlighting${COLOR}...OK${NC}"
  else
    echo -e "${COLOR}Found ${COLOR1}zsh-syntax-highlighting${COLOR}...skip${NC}"
  fi

  if [ ! -d "$HOME"/.oh-my-zsh/custom/plugins/zsh-nvm ]; then
    echo -e "${COLOR}Installing ${COLOR1}zsh-nvm${COLOR}...${NC}"
    git clone https://github.com/lukechilds/zsh-nvm $HOME/.oh-my-zsh/custom/plugins/zsh-nvm
    echo -e "${COLOR}Installing ${COLOR1}zsh-nvm${COLOR}...OK${NC}"
  else
    echo -e "${COLOR}Found ${COLOR1}zsh-nvm${COLOR}...skip${NC}"
  fi

  if [ ! -d "$HOME"/.oh-my-zsh/custom/plugins/fzf-zsh-plugin ]; then
    echo -e "${COLOR}Installing ${COLOR1}fzf-zsh-plugin${COLOR}...${NC}"
    git clone https://github.com/unixorn/fzf-zsh-plugin.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-zsh-plugin
    echo -e "${COLOR}Installing ${COLOR1}fzf-zsh-plugin${COLOR}...OK${NC}"
  else
    echo -e "${COLOR}Found ${COLOR1}fzf-zsh-plugin${COLOR}...skip${NC}"
  fi
} # }}}

function install_vim() { # {{{
  CONFIG_VIM="$HOME"/myConfigs/vim

  if [ ! -d "$CONFIG_VIM" ]; then
    fetch_myConfigs
  fi

  if [ "$OS" = 'Linux' ]; then
    if [ "$DISTRO" = 'Ubuntu' ] || [ "$DISTRO" = 'Debian' ]; then

      if ! type nvim >/dev/null 2>&1; then
        echo -e "${COLOR1}NeoVim${COLOR} is not found.${NC}"
        # Install VIM_PACKAGE
        echo -e "${COLOR}Install ${COLOR1}NeoVim${COLOR}...${NC}"

        if [ "$DISTRO" = 'Ubuntu' ]; then
          NVIM_PPA=/etc/apt/sources.list.d/neovim-ppa-ubuntu-unstable-$CODENAME.list
          if [ ! -e "$NVIM_PPA" ]; then
            echo -e "${COLOR}No latest NeoVim ppa found, adding ${COLOR1}ppa:neovim-ppa/unstable${COLOR}...${NC}"
            $SUDO add-apt-repository -y ppa:neovim-ppa/unstable

            if [ ! -z "$MIRRORS" ] && [ "$MIRRORS" -eq 1 ]; then
              $SUDO sed -i "s/http:\/\/ppa\.launchpad\.net/https:\/\/launchpad\.proxy\.ustclug\.org/g" "$NVIM_PPA"
            fi
            $SUDO apt update
          else
            echo -e "${COLOR1}ppa:neovim-ppa/unstable${COLOR} was found${NC}"
          fi
        fi

        $SUDO apt install -y neovim
      else
        echo -e "${COLOR1}NeoVim${COLOR} is found at '$(which nvim)'${NC}"
      fi

      echo -e "${COLOR}Install supplementary tools...${NC}"
      $SUDO apt install -y silversearcher-ag cscope astyle lua5.3 perl
    elif [ "$DISTRO" = 'Manjaro' ]; then
      if ! type nvim >/dev/null 2>&1; then
        yay -S neovim
      fi
    elif [ "$DISTRO" = 'CentOS' ]; then
      if ! type nvim >/dev/null 2>&1; then
        set +e
        PACKAGE=$(yum list installed | grep -c ^wget.x86_64)
        set -e
        if [ "$PACKAGE" = 0 ]; then
          echo -e "${COLOR}No ${COLOR1}wget${COLOR} found, install it...${NC}"
          $SUDO yum install -y wget
        fi

        set +e
        PACKAGE=$(yum list installed | grep -c ^fuse-sshfs.x86_64)
        set -e
        if [ "$PACKAGE" = 0 ]; then
          echo -e "${COLOR}No ${COLOR1}fuse-sshfs${COLOR} found, install it...${NC}"
          $SUDO yum install -y fuse-sshfs
        fi

        echo -e "${COLOR}Get latest ${COLOR1}NeoVim${COLOR} AppImage from GitHub repo...${NC}"
        wget "https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage" -P "$HOME"/.local/bin
        ln -sfnv "$HOME"/.local/bin/nvim.appimage "$HOME"/.local/bin/nvim
      fi
    fi
  elif [ "$OS" = 'Darwin' ]; then
    echo -e "${COLOR}Install development branch of Neovim...${NC}"
    brew install --HEAD neovim
    echo -e "${COLOR}Install supplementary tools...${NC}"
    brew install the_silver_searcher cscope astyle
  elif [ "$OS" = 'Windows_NT' ]; then
    if ! type nvim >/dev/null 2>&1; then
      echo -e "${COLOR}Please make sure neovim is installed.${NC}"
      return
    fi
  else
    echo -e "${COLOR}Unknown OS, please make sure neovim is installed.${NC}"
    return
  fi

  XDGSpaceDir="${XDG_CONFIG_HOME:-${HOME}/.}${XDG_CONFIG_HOME:+/}SpaceVim"
  XDGSpaceDDir="${XDG_CONFIG_HOME:-${HOME}/.}${XDG_CONFIG_HOME:+/}SpaceVim.d"
  curl -sLf https://spacevim.org/install.sh | bash -s -- --no-fonts
  mkdir -p "$XDGSpaceDDir"
  ln -snvf "$CONFIG_VIM"/SpaceVim/init.toml "$XDGSpaceDDir"/init.toml

  echo -e "${COLOR}Install python3 dependencies...${NC}"
  if ! type ruby >/dev/null 2>&1; then
    install_python
  fi
  pip3 install pynvim

  echo -e "${COLOR}Install ruby dependencies...${NC}"
  if ! type ruby >/dev/null 2>&1; then
    install_ruby
  fi
  if [ -z "$GEM_HOME" ]; then
    GEM_HOME=$(ruby -e 'puts Gem.user_dir')
    export GEM_HOME
    export GEM_PATH=$GEM_HOME
  fi
  gem install neovim

  echo -e "${COLOR}Install node.js dependencies...${NC}"
  if ! type node >/dev/null 2>&1; then
    install_node
  fi
  npm install -g neovim
  
} #}}}

function install_rxvt() { # {{{
  if [ "$OS" = 'Linux' ]; then
    if [ ! -d "$HOME"/myConfigs ]; then
      fetch_myConfigs
    fi

    if [ -e "$HOME"/.Xresources ]; then
      cp "$HOME"/.Xresources "$HOME"/.Xresources.backup
    fi
    ln -sfnv "$HOME"/myConfigs/X11/Xresources "$HOME"/.Xresources
    "$HOME"/myConfigs/change_font.sh
    "$HOME"/myConfigs/change_theme.sh
    xrdb -load "$HOME"/.Xresources

    if [ "$DISTRO" = 'Ubuntu' ]; then
      if ! type rxvt >/dev/null 2>&1; then
        echo -e "${COLOR}Installing ${COLOR1}rxvt-unicode-256color${COLOR}...${NC}"
        $SUDO apt install -y rxvt-unicode-256color
      fi
    fi
  else
    echo -e "${COLOR1}rxvt-unicode-256color${COLOR} will only be installed on Linux.${NC}"
  fi
} # }}}

function install_docker() { # {{{
  if [ "$OS" = 'Linux' ]; then
    if [ "$DISTRO" = 'Ubuntu' ]; then
      echo -e "${COLOR}Ubuntu is found, checking ${COLOR1}docker${COLOR}...${NC}"
      if ! type docker >/dev/null 2>&1; then
        echo -e "${COLOR1}docker${COLOR} is not found, installing...${NC}"
        echo -e "${COLOR}Installing prerequisite packages...${NC}"
        $SUDO apt-get -y install apt-transport-https ca-certificates curl software-properties-common
        
        if [ ! -e /etc/apt/trusted.gpg.d/aliyun-docker-ce.gpg ]; then
          echo -e "${COLOR}Add mirrors.aliyun.com/docker-ce public key...${NC}"
          curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | gpg --dearmor > aliyun-docker-ce.gpg
          sudo install -D -o root -m 644 aliyun-docker-ce.gpg /etc/apt/trusted.gpg.d/aliyun-docker-ce.gpg
          rm -f aliyun-docker-ce.gpg
        fi

        if ! grep -q "aliyun.com/docker-ce" /etc/apt/sources.list.d/*.list; then
          echo -e "${COLOR}Add mirrors.aliyun.com/docker-ce apt source...${NC}"
          if [ "$OS_ARCH" = 'aarch64' ]; then # for Raspberry Pi
            $SUDO add-apt-repository "deb [arch=arm64] http://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release   -cs) stable"
          else
            $SUDO add-apt-repository "deb [arch=amd64] http://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release   -cs) stable"
          fi
          $SUDO apt-get -y update
        fi
        
        echo -e "${COLOR}Installing docker-ce...${NC}"
        $SUDO apt-get -y install docker-ce

        echo -e "${COLOR}Add user ${COLOR1}${USER}${COLOR} to group 'docker'...${NC}"
        $SUDO usermod -aG docker $USER
      else
        echo -e "${COLOR1}$(docker -v)${COLOR} is found...${NC}"
      fi

      if [ ! -e /etc/docker/daemon.json ]; then
        $SUDO cp "$HOME"/myConfigs/docker/daemon.json /etc/docker/daemon.json
      fi

      if [ ! -z "$MIRRORS" ] && [ "$MIRRORS" -eq 1 ]; then
        if [ ! -e /etc/systemd/system/docker.service.d ]; then
          $SUDO mkdir -p /etc/systemd/system/docker.service.d
          $SUDO cp "$HOME"/myConfigs/docker/proxy.conf /etc/systemd/system/docker.service.d/proxy.conf
        fi
      fi
    fi

    echo -e "${COLOR}Please install ${COLOR1}docker-compose${COLOR} by ${COLOR1}'pip3 install docker-compose'${NC}"
  else
    echo -e "${COLOR}Unsupported on this OS.${NC}"
  fi
} # }}}

function install_containerd-rootless() { # {{{
  if [ "$OS" = 'Linux' ]; then
    if ! type containerd >/dev/null 2>&1; then
      wget "https://github.com/containerd/containerd/releases/download/v1.6.15/cri-containerd-1.6.15-linux-amd64.tar.gz" -O /tmp/cri-containerd.tar.gz
      $SUDO tar xvzf /tmp/cri-containerd.tar.gz -C /
      containerd config default | sudo tee /etc/containerd/config.toml >/dev/null
    fi

    # Install CNI plugins
    if [ ! -d /opt/cni/bin ]; then
      local CNI_VERSION
      CNI_VERSION="v1.2.0"
      $SUDO mkdir -p /opt/cni/bin
      $SUDO mkdir -p /etc/cni/net.d
      wget "https://github.com/containernetworking/plugins/releases/download/$CNI_VERSION/cni-plugins-linux-amd64-$CNI_VERSION.tgz" -O /tmp/cni-plugins-linux-amd64-$CNI_VERSION.tgz
      $SUDO tar -zxvf "/tmp/cni-plugins-linux-amd64-$CNI_VERSION.tgz" -C /opt/cni/bin/
      rm -f "/tmp/cni-plugins-linux-amd64-$CNI_VERSION.tgz"
    fi

    # Install CNI tools
    if ! type cnitool >/dev/null 2>&1; then
      if ! type go >/dev/null 2>&1; then
        install_golang
        export GOROOT="$HOME"/.local/go
        export GOPATH=$HOME/.gopackages
      fi
      go install github.com/containernetworking/cni/cnitool@latest
    fi

    # Install nerdctl
    if ! type nerdctl >/dev/null 2>&1; then
      # TODO: check $ARCH
      wget "https://github.com/containerd/nerdctl/releases/download/v1.1.0/nerdctl-1.1.0-linux-amd64.tar.gz" -O /tmp/nerdctl.tar.gz
      $SUDO tar xvzf /tmp/nerdctl.tar.gz /usr/local/bin
      rm /tmp/nerdctl.tar.gz
    fi

    # {{{ Rootless containers
    if ! type newuidmap >/dev/null 2>&1; then
      # TODO: check $DISTRO
      $SUDO apt install uidmap
    fi

    if ! type slirp4netns >/dev/null 2>&1; then
      # TODO: check $DISTRO
      $SUDO apt install slirp4netns
    fi

    if ! type rootlesskit >/dev/null 2>&1; then
      # TODO: check $ARCH
      wget "https://github.com/rootless-containers/rootlesskit/releases/download/v1.1.0/rootlesskit-x86_64.tar.gz" -O /tmp/rootlesskit.tar.gz
      $SUDO tar xvzf /tmp/rootlesskit.tar.gz -C /usr/local/bin
    fi

    if ! type containerd-rootless.sh >/dev/null 2>&1; then
      $SUDO wget "https://raw.githubusercontent.com/containerd/nerdctl/main/extras/rootless/containerd-rootless.sh" -O /usr/local/bin/containerd-rootless.sh
      $SUDO chmod +x /usr/local/bin/containerd-rootless.sh
    fi

    if ! type containerd-rootless-setuptool.sh >/dev/null 2>&1; then
      $SUDO wget "https://raw.githubusercontent.com/containerd/nerdctl/main/extras/rootless/containerd-rootless-setuptool.sh" -O /usr/local/bin/containerd-rootless-setuptool.sh
      $SUDO chmod +x /usr/local/bin/containerd-rootless-setuptool.sh
    fi
    # }}}
    /usr/local/bin/containerd-rootless-setuptool.sh install
  else
    echo -e "${COLOR}Unsupported on this OS.${NC}"
  fi
}
# }}}

function install_llvm() { # {{{
  if [ "$OS" = 'Linux' ]; then
    if [ "$DISTRO" = 'Ubuntu' ]; then
      $SUDO apt install -y llvm clang clang-format clang-tidy clang-tools lldb lld
    elif [ "$DISTRO" = 'CentOS' ]; then
      set +e
      PACKAGE=$(yum list installed | grep -c ^centos-release-scl)
      set -e
      if [ "$PACKAGE" -eq 0 ]; then
        $SUDO yum install -y centos-release-scl
      fi

      $SUDO yum install -y devtoolset-7 llvm-toolset-7 llvm-toolset-7-clang-analyzer llvm-toolset-7-clang-tools-extra llvm-toolset-7-git-clang-format
    fi
  else
    echo -e "${COLOR}OS not supported.${NC}"
  fi
} # }}}

function install_mysql() { # {{{
  if [ "$OS" = 'Linux' ]; then
    if [ "$DISTRO" = 'Ubuntu' ]; then
      echo 'Not implemented yet, waiting for my update'
    elif [ "$DISTRO" = 'CentOS' ]; then
      set +e
      PACKAGE=$(yum list installed | grep -c ^mysql57-community-release)
      set -e
      if [ "$PACKAGE" -eq 0 ]; then
        echo -e "${COLOR}Add repo ${COLOR1}mysql57-community-release${COLOR}...${NC}"
        $SUDO yum install -y https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
        echo -e "${COLOR}Add repo ${COLOR1}mysql57-community-release${COLOR}...OK${NC}"
      fi

      $SUDO yum install -y mysql-community-server
      echo -e "${COLOR}Open port for mysql server in firewalld...${NC}"
      $SUDO firewall-cmd --zone=public --add-service=mysql --permanent
      $SUDO firewall-cmd --reload
      echo -e "${COLOR}Open port for mysql server in firewalld...OK${NC}"
      echo -e "${COLOR}Your temporary root password will be in ${COLOR1}/var/log/mysqld.log${COLOR} when you start mysqld for the first time${NC}"
      echo -e "${COLOR}Please login with this temporary password, and change it immediately using:${NC}"
      echo -e "${COLOR1}ALTER USER 'root'@'localhost' IDENTIFIED BY '<new-password>'${NC}"
      echo -e "${COLOR}And add this configurations in ${COLOR1}/etc/my.cnf${COLOR} for better encoding process${NC}"
      printf "#----------\n[client]\ndefault-character-set=utf8\n\n[mysqld]\ndefault-storage-engine=INNODB\ncharacter-set-server=utf8\ncollation-server=utf8_general_ci\ncollation-server=utf8_bin\ncollation-server=utf8_unicode_ci\n#----------\n"
    fi
  else
    echo -e "${COLOR}OS not supported.${NC}"
  fi
} # }}}

function install_samba() { # {{{
  if [ "$OS" = 'Linux' ]; then
    if [ "$DISTRO" = 'Ubuntu' ]; then
      $SUDO apt install -y samba samba-common
      $SUDO cp "$HOME"/git/myConfigs/samba/smb.conf /etc/samba/smb.conf
      $SUDO smbpasswd -a yusiwen
      $SUDO systemctl restart smbd
      $SUDO systemctl enable smbd
    fi
  fi
} # }}}

function install_rust() { # {{{
  if [ "$OS" = 'Linux' ]; then
    if ! type rustc >/dev/null 2>&1; then
      echo -e "${COLOR}Installing ${COLOR1}Rust${COLOR} using official script...${NC}"
      curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
      source "$HOME/.cargo/env"
    else
      echo -e "${COLOR}${COLOR1}$(rustc --version)${COLOR} is found.${NC}"
    fi

    if ! type exa >/dev/null 2>&1; then
      echo -e "${COLOR}Installing ${COLOR1}exa${COLOR}...${NC}"
      cargo install exa
    else
      echo -e "${COLOR}${COLOR1}exa${COLOR} is found.${NC}"
    fi

    if ! type delta >/dev/null 2>&1; then
      echo -e "${COLOR}Installing ${COLOR1}git-delta${COLOR}...${NC}"
      cargo install git-delta
    else
      echo -e "${COLOR}${COLOR1}git-delta${COLOR} is found.${NC}"
    fi

    if ! type rg >/dev/null 2>&1; then
      echo -e "${COLOR}Installing ${COLOR1}ripgrep${COLOR}...${NC}"
      cargo install ripgrep
    else
      echo -e "${COLOR}${COLOR1}ripgrep${COLOR} is found.${NC}"
    fi
  fi
} # }}}

function install_golang() { # {{{
  if [ "$OS" = 'Linux' ]; then
    if [ -z "$ARCH" ]; then
      echo -e "${COLOR2}Unknown archetecture ${COLOR1}$ARCH${NC}"
      exit 1
    fi

    local version="$1"
    if [ -z "$version" ]; then
      # Get latest stable from official site
      version=$(curl -L "https://golang.org/VERSION?m=text")
      echo -e "${COLOR}The latest stable version is ${COLOR1}$version${COLOR}${NC}"
    elif ! (echo "$version" | grep -Eq ^go); then
      version="go$version"
    fi
    local installation_path="$HOME"/.local
    local target_path="$installation_path/$version.linux-$ARCH"

    echo -e "${COLOR}Downloading ${COLOR1}$version.linux-$ARCH.tar.gz${COLOR}${NC}"
    wget -P "$installation_path" "https://dl.google.com/go/$version.linux-$ARCH.tar.gz"

    mkdir -p "$target_path"
    tar xvvzf "$installation_path/$version.linux-$ARCH.tar.gz" -C "$target_path" --strip-components 1
    ln -sfnv "$target_path" "$installation_path"/go
    rm -rf "$installation_path/$version.linux-$ARCH.tar.gz"

    echo -e "${COLOR1}$version.linux-$ARCH${COLOR} is installed, re-login to take effect${NC}"
  fi
}
# }}}

function install_helm() { # {{{
  if [ "$OS" = 'Linux' ]; then
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
  fi
} # }}}

function install_sdkman() { # {{{
  # https://sdkman.io/install
  curl -s "https://get.sdkman.io" | bash
  source "$HOME/.sdkman/bin/sdkman-init.sh"
} # }}}

function init_byobu() { # {{{
  if [ "$OS" = 'Linux' ]; then
    if [ ! -d ~/.tmux/plugins/tpm ]; then
      git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    fi
    ln -snfv $HOME/git/myConfigs/tmux/tmux.conf ~/.tmux.conf
    byobu-enable
  
    # Enable mouse by default
    if [ -e $HOME/.config/byobu/profile.tmux ]; then
      cat << EOF | tee -a $HOME/.config/byobu/profile.tmux
# Enable mouse support including scrolling
set -sg mouse on
set -sg escape-time 50
EOF
    fi
  fi
} # }}}

function init_ansible() { # {{{
  if ! type pip3 >/dev/null 2>&1; then
    install_python
  fi

  pip3 install ansible
} # }}}

function print_info() { # {{{
  echo -e "\nUsage:\n${COLOR}install.sh [init|git|myConfigs|node|python|ruby|rxvt|vim|zsh|llvm|docker|containerd-rootless|mysql|samba|ctags|rust|sdkman|byobu]${NC}"
} # }}}

case $1 in
init) init_env ;;
git) install_git ;;
ruby) install_ruby ;;
myConfigs) fetch_myConfigs ;;
python) install_python ;;
node) install_node ;;
zsh) install_zsh ;;
vim) install_vim ;;
rxvt) install_rxvt ;;
llvm) install_llvm ;;
docker) install_docker ;;
containerd-rootless) install_containerd-rootless ;;
mysql) install_mysql ;;
samba) install_samba ;;
ctags) install_universal_ctags ;;
rust) install_rust ;;
golang)
  shift
  install_golang "$@" ;;
helm) install_helm ;;
sdkman) install_sdkman ;;
byobu) init_byobu ;;
ansible) init_ansible ;;
*) print_info ;;
esac

# vim: fdm=marker
