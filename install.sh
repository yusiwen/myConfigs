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
DISTRO=
MIRRORS=0
USE_PROXY=0

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
    elif [ "$ID" = 'Deepin' ]; then
      DISTRO='Deepin'
      CODENAME='buster'
    else
      DISTRO=$(awk -F= '/^NAME/{print $2}' /etc/os-release | xargs | cut -d ' ' -f1)
    fi
    OS_NAME=$(awk -F= '/^NAME/{print $2}' /etc/os-release | xargs | cut -d ' ' -f1)
    OS_VERSION=$(grep "^VERSION_ID" /etc/os-release | xargs | cut -d'=' -f2)
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

OPT_PATH=/opt
# Mount /opt on Windows
if [ "$OS" = 'Windows_NT' ] && [ "$(uname -o)" = 'Msys' ] && [ ! -d "$OPT_PATH" ]; then
    OPT_WIN_PATH=
    if [ -d "/d/opt" ]; then
      OPT_WIN_PATH=D:/opt
    elif [ -d "/e/opt" ]; then
      OPT_WIN_PATH=E:/opt
    fi
    mkdir -p "$OPT_PATH"

    if [ -n "$OPT_WIN_PATH" ]; then
      echo "Mounting $OPT_WIN_PATH to $OPT_PATH ..."
      mount -fo binary,noacl,posix=0,user "$OPT_WIN_PATH" "$OPT_PATH"
    fi
fi

APP_HOME=$OPT_PATH/apps
# }}}

set -e
set -o pipefail

function show_sysinfo() {
  echo "OS=$OS"
  echo "OS_ARCH=$OS_ARCH"
  echo "ARCH=$ARCH"
  echo "CODENAME=$CODENAME"
  echo "OS_NAME=$OS_NAME"
  echo "OS_VERSION=$OS_VERSION"
  echo "DISTRO=$DISTRO"
  echo "MIRRORS=$MIRRORS"
}

function make_link() { # {{{
  local target="$1" linkname="$2"
  local link_path
  link_path=$(dirname "$linkname")
  if [ ! -d "$link_path" ]; then
    mkdir -p "$link_path"
  fi
  ln -sfnv "$target" "$linkname"
}
# }}}

function check_link() { # {{{
  if [ -z "$1" ] || [ -z "$2" ]; then
    return
  fi

  local target="$1" linkname="$2"
  echo -e "${COLOR}Checking link ${COLOR1}'${linkname}'${COLOR} to ${COLOR1}'${target}'${COLOR}...${NC}"
  if [ ! -e "${linkname}" ]; then
    make_link "${target}" "${linkname}"
  else
    if [ -L "${linkname}" ]; then
      if [ "$(readlink -f "${linkname}")" = "$(readlink -f "${target}")" ]; then
        echo -e "${COLOR}Link ${COLOR1}'${linkname}'${COLOR} to ${COLOR1}'${target}'${COLOR} already exists${NC}"
        return
      else
        make_link "${target}" "${linkname}"
        return
      fi
    else
      mv "${linkname}" "${linkname}.$(date '+%s')"
      make_link "${target}" "${linkname}"
    fi
  fi
} # }}}

function check_command() { # {{{
  if type "$1" >/dev/null 2>&1; then
    true
  else
    false
  fi
} # }}}

function get_latest_release_from_github() { # {{{
  local auth_config=()
  local username=''
  local password=''
  if check_command pass; then
    if [ -e "$HOME/.password-store/access_token@github.com" ]; then
      username=$(pass access_token@github.com/scrapy/username)
      password=$(pass access_token@github.com/scrapy/token)
      if [ -n "$username" ] && [ -n "$password" ]; then
        auth_config=("--user" "$username:$password")
      fi
    fi
  else
    if [ -e "$HOME"/.github_token_cfg ]; then
      username=$(awk -F "=" '/username/ {print $2}' "$HOME"/.github_token_cfg)
      password=$(awk -F "=" '/access_token/ {print $2}' "$HOME"/.github_token_cfg)
      if [ -n "$username" ] && [ -n "$password" ]; then
        auth_config=("--user" "$username:$password")
      fi
    fi
  fi

  if [ ${#auth_config[@]} -gt 0 ]; then
    # Thanks to: https://gist.github.com/lukechilds/a83e1d7127b78fef38c2914c4ececc3c
    curl "${auth_config[@]}" --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
      grep '"tag_name":' |                                            # Get tag line
      tr -d '\n\r' |                                                  # Remove newline
      sed -E 's/.*"([^"]+)".*/\1/' |                                  # Pluck JSON value
      sed 's/^v//g'                                                   # Remove leading 'v'
  else
    curl -i --silent "https://github.com/$1/releases/latest" |
      grep 'location: ' |
      tr -d '\n\r' |                                                  # Remove newline
      sed 's/.*releases\/tag\/\(.*\)/\1/' |
      sed 's/^v//g'                                                   # Remove leading 'v'
  fi
} # }}}

function vercomp() { # {{{
  local this_version=$1
  local available_version=$2

  if [[ "ok" == "$(echo | awk "(${available_version} > ${this_version}) { print \"ok\"; }")" ]]; then
    echo 1
  elif [[ "ok" == "$(echo | awk "(${available_version} == ${this_version}) { print \"ok\"; }")" ]]; then
    echo 0
  else
    echo 2
  fi
} # }}}

function enable_FUSE() { # {{{
  if [ "$OS" = 'Linux' ]; then
    if [ "$DISTRO" = 'Ubuntu' ] || [ "$DISTRO" = 'Debian' ]; then
      $SUDO add-apt-repository -y universe
      $SUDO env NEEDRESTART_MODE=a apt-get install libfuse2
    elif [ "$DISTRO" = 'CentOS' ]; then
      if [ "$OS_VERSION" = '"7"' ]; then
        $SUDO yum --enablerepo=epel -y install fuse-sshfs # install from EPEL
      else
        $SUDO yum install -y epel-release
        $SUDO yum update -y
        $SUDO yum install -y fuse-sshfs
      fi
      $SUDO usermod -a -G fuse "$(whoami)"
    fi
  fi
} # }}}

# Initialize apt and install prerequisite packages
function init_env() { # {{{
  local minimal=0
  if [ "$1" = '-m' ]; then
    minimal=1
  elif [ "$1" = '-b' ]; then
    minimal=2
  fi

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

      $SUDO apt-get update
      local pkg_pstack=()
      if [ "$ARCH" = 'amd64' ] && [ "$DISTRO" = 'Ubuntu' ]; then
        pkg_pstack=( pstack ltrace )
      else
        pkg_pstack=()
      fi
      
      local pkg_core=( gdebi-core software-properties-common apt-transport-https )
      local pkg_zip=( p7zip-full pigz zip unzip )
      local pkg_network=( curl wget net-tools iputils-ping iputils-arping hping3 nmap ethtool )
      local pkg_build=( build-essential cmake "${pkg_pstack[@]}" )
      local pkg_fs=( cifs-utils nfs-common )
      local pkg_monitor=( htop atop btop iotop iftop nethogs nload sysstat )
      local pkg_misc=( tmux byobu jq pass ncdu silversearcher-ag shellcheck command-not-found )

      if [ $minimal -eq 1 ]; then
        $SUDO env NEEDRESTART_MODE=a apt-get install -y \
          "${pkg_core[@]}" \
          "${pkg_zip[@]}" \
          "${pkg_network[@]}" \
          "${pkg_fs[@]}" \
          "${pkg_monitor[@]}" \
          "${pkg_misc[@]}"
      else
        $SUDO env NEEDRESTART_MODE=a apt-get install -y \
          "${pkg_core[@]}" \
          "${pkg_zip[@]}" \
          "${pkg_network[@]}" \
          "${pkg_fs[@]}" \
          "${pkg_monitor[@]}" \
          "${pkg_misc[@]}" \
          "${pkg_build[@]}"
      fi
    elif [ "$DISTRO" = 'Manjaro' ]; then
      yay -S base-devel the_silver_searcher tmux byobu
    elif [ "$DISTRO" = 'CentOS' ]; then
      if [ "$OS_VERSION" = '"7"' ]; then
        $SUDO yum --enablerepo=epel -y \
          install net-tools telnet ftp lftp libaio \
          libaio-devel bc man lsof wget tmux byobu
      else
        $SUDO yum config-manager --set-enabled PowerTools
        $SUDO yum install -y epel-release
        $SUDO yum update -y
        $SUDO yum install -y net-tools telnet ftp lftp libaio libaio-devel bc man lsof wget tmux
      fi
    fi
    
    enable_FUSE

    if [ $minimal -eq 1 ] || [ $minimal -eq 2 ]; then
      install_git
      fetch_myConfigs
    else
      install_perl
      install_lua
      install_rust
      install_git
      fetch_myConfigs
      install_ruby
      install_python
      # Install gittyleaks after python is initialized
      pipx install gittyleaks
      install_golang
    fi
  elif [ "$OS" = 'Darwin' ]; then
    if ! check_command brew; then
      echo -e "${COLOR}Installing ${COLOR1}HomeBrew${COLOR}...${NC}"
      # On MacOS ruby is pre-installed already
      /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
    install_rust
  elif [ "$OS" = 'Windows_NT' ]; then
    echo -e "${COLOR}Please install Chocolatey (https://chocolatey.org/install), then executes:${NC}"
    echo -e "${COLOR}choco install delta${NC}"

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

# Git
function install_git() { # {{{
  source $HOME/myConfigs/git/install.sh
  _install_git 
} # }}}

function install_ruby() { # {{{
  if [ "$OS" = 'Linux' ]; then
    if [ "$DISTRO" = 'Ubuntu' ] || [ "$DISTRO" = 'Debian' ]; then
      if ! check_command ruby; then
        echo -e "${COLOR}Installing ${COLOR1}Ruby${COLOR}...${NC}"
        $SUDO env NEEDRESTART_MODE=a apt-get install -y ruby-full curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev libffi-dev
        echo -e "${COLOR}Installing ${COLOR1}Ruby${COLOR}...OK${NC}"
      else
        echo -e "${COLOR1}ruby${COLOR} was found.${NC}"
        set +e
        PACKAGE=$(dpkg -l | grep -c ruby-full)
        set -e
        if [ "$PACKAGE" -eq 0 ]; then
          echo -e "${COLOR}Installing ${COLOR1}ruby-full${COLOR}...${NC}"
          $SUDO env NEEDRESTART_MODE=a apt-get install -y ruby-full
        fi
      fi
    elif [ "$DISTRO" = 'Manjaro' ]; then
      if ! check_command ruby; then
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
    if ! check_command ruby; then
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
  if ! check_command bundle; then
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
  if ! check_command git; then
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
    ln -sfnv "$HOME"/myConfigs/ssh/config "$HOME"/.ssh/config
    mkdir -p "$HOME"/.local/bin
    ln -sfnv "$HOME"/myConfigs/git/git-migrate "$HOME"/.local/bin/git-migrate
    ln -sfnv "$HOME"/myConfigs/git/git-new-workdir "$HOME"/.local/bin/git-new-workdir
    ln -sfnv "$HOME"/myConfigs/git/repos.sh "$HOME"/.local/bin/repos
  fi
} # }}}

function install_python() { # {{{
  source $HOME/myConfigs/python/install.sh
  _install_python 
} # }}}

function install_node() { # {{{
  if [ ! -d "$HOME"/myConfigs ]; then
    fetch_myConfigs
  fi

  if [ "$OS" = 'Windows_NT' ]; then
    echo -e "${COLOR}Pleasae installing ${COLOR1}nvm-windows${COLOR} manually${NC}"
  else
    if [ -z "$N_PREFIX" ]; then
      echo -e "${COLOR}Installing ${COLOR1}tj/n ${COLOR}...${NC}"
      export N_PREFIX="$HOME/.n"
      curl -L "https://bit.ly/n-install" | bash -s -- -n -y lts
      export PATH="$PATH:$N_PREFIX/bin"

      n stable
    else
      echo -e "${COLOR}Found ${COLOR1}tj/n${COLOR} in ${COLOR1}\"$N_PREFIX\"${COLOR}...skip${NC}"
      if ! check_command npm; then
        n stable
      fi
    fi
  fi

  echo -e "${COLOR1}Installing yarn, eslint...${NC}"
  npm install -g yarn eslint npm-check npm-check-updates nrm pnpm
  # Install cli tools for git commit conventions
  echo -e "${COLOR1}Installing conventional-changelog-cli, Commitizen, cz-customizable, standard-version...${NC}"
  npm install -g conventional-changelog-cli commitizen cz-customizable standard-version diff-so-fancy

  echo -e "${COLOR1}Installing tldr...${NC}"
  npm install -g tldr

  echo -e "${COLOR1}Installing sonar-scanner...${NC}"
  npm install -g sonar-scanner

  if check_command git; then
    git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
  fi
} # }}}

function install_fish() {
  source $HOME/myConfigs/shell/fish/install.sh
  _install_fish
}

function install_zsh() { # {{{
  source $HOME/myConfigs/shell/zsh/install.sh
  _install_zsh
} # }}}

function install_vim() { # {{{
  source $HOME/myConfigs/vim/install.sh
  _install_vim
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
      if ! check_command rxvt; then
        echo -e "${COLOR}Installing ${COLOR1}rxvt-unicode-256color${COLOR}...${NC}"
        $SUDO env NEEDRESTART_MODE=a apt-get install -y rxvt-unicode-256color
      fi
    fi
  else
    echo -e "${COLOR1}rxvt-unicode-256color${COLOR} will only be installed on Linux.${NC}"
  fi
} # }}}

function install_docker() { # {{{
  source $HOME/myConfigs/docker/install.sh
  _install_docker
} # }}}

function install_containerd() { # {{{
  source $HOME/myConfigs/docker/install.sh
  _install_containerd
}
# }}}

function install_llvm() { # {{{
  if [ "$OS" = 'Linux' ]; then
    if [ "$DISTRO" = 'Ubuntu' ]; then
      $SUDO env NEEDRESTART_MODE=a apt-get install -y llvm clang clang-format clang-tidy clang-tools lldb lld
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
      $SUDO env NEEDRESTART_MODE=a apt-get install -y samba samba-common
      $SUDO cp "$HOME"/git/myConfigs/samba/smb.conf /etc/samba/smb.conf
      $SUDO smbpasswd -a yusiwen
      $SUDO systemctl restart smbd
      $SUDO systemctl enable smbd
    fi
  fi
} # }}}

function install_rust() { # {{{
  if [ "$OS" = 'Linux' ]; then
    if ! check_command rustc && [ ! -e "$HOME"/.cargo/bin/rustc ]; then
      echo -e "${COLOR}Installing ${COLOR1}Rust${COLOR} using official script...${NC}"
      if [ -n "$MIRRORS" ] && [ "$MIRRORS" -eq 1 ]; then
        RUSTUP_DIST_SERVER="https://rsproxy.cn" RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup" bash -c "curl --proto '=https' --tlsv1.2 -sSf https://rsproxy.cn/rustup-init.sh | sh -s -- -y"
      else
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
      fi

      if [ -e "$HOME/.cargo/env" ]; then
        source "$HOME/.cargo/env"
      else
        echo -e "${COLOR2}Installation is failed, please check manually.${NC}"
        exit 1
      fi

      if [ -n "$MIRRORS" ] && [ "$MIRRORS" -eq 1 ]; then
        cat << EOF | tee -a "${CARGO_HOME:-$HOME/.cargo}/config"
[source.crates-io]
replace-with = 'rsproxy-sparse'
[source.rsproxy]
registry = "https://rsproxy.cn/crates.io-index"
[source.rsproxy-sparse]
registry = "sparse+https://rsproxy.cn/index/"
[registries.rsproxy]
index = "https://rsproxy.cn/crates.io-index"
[net]
git-fetch-with-cli = true
EOF
      fi
    else
      echo -e "${COLOR}${COLOR1}$($HOME/.cargo/bin/rustc --version)${COLOR} is found.${NC}"
      if check_command rustup; then
        rustup update
      fi
    fi

    # Make sure cargo can be built when installing
    if ! check_command cc; then
      if [ "$DISTRO" = 'CentOS' ]; then
        $SUDO yum groupinstall 'Development Tools'
      else
        $SUDO env NEEDRESTART_MODE=a apt-get install -y build-essential pkg-config
      fi
    fi

    if ! check_command pkg-config; then
      if [ "$DISTRO" = 'CentOS' ]; then
        $SUDO yum install pkgconfig
      else
        $SUDO env NEEDRESTART_MODE=a apt-get install -y pkg-config
      fi
    fi

    if ! check_command cargo; then
      if [ -e "$HOME/.cargo/env" ]; then
        source "$HOME/.cargo/env"
      else
        echo -e "${COLOR2}Installation is failed, please check manually.${NC}"
        exit 1
      fi
    fi

    if ! check_command btm; then
      echo -e "${COLOR}Installing ${COLOR1}bottom${COLOR}...${NC}"
      cargo install bottom
    else
      echo -e "${COLOR}${COLOR1}bottom${COLOR} is found.${NC}"
    fi

    if ! check_command cargo-install-update; then
      echo -e "${COLOR}Installing ${COLOR1}cargo-update${COLOR}...${NC}"
      $SUDO env NEEDRESTART_MODE=a apt-get install -y libssl-dev
      cargo install cargo-update
      cargo install-update  -a
    else
      echo -e "${COLOR}${COLOR1}cargo-update${COLOR} is found.${NC}"
      cargo install-update  -a
    fi

    if ! check_command cargo-cache; then
      echo -e "${COLOR}Installing ${COLOR1}cargo-cache${COLOR}...${NC}"
      cargo install cargo-cache
    else
      echo -e "${COLOR}${COLOR1}cargo-cache${COLOR} is found.${NC}"
    fi
  elif [ "$OS" = "Windows_NT" ]; then
    echo -e "Please download and run installer from: https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-msvc/rustup-init.exe"
  fi
} # }}}

function install_lua() { # {{{
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
      pushd /tmp/luarocks-3.9.1
      ./configure && make && sudo make install
      popd
      rm -f /tmp/luarocks-3.9.1.tar.gz
      rm -rf /tmp/luarocks-3.9.1
    fi
  fi
} # }}}

function install_perl() { # {{{
  if [ "$OS" = 'Linux' ]; then
    if [ "$DISTRO" = 'Ubuntu' ] || [ "$DISTRO" = 'Debian' ]; then
      if ! check_command perl; then
        $SUDO env NEEDRESTART_MODE=a apt-get install perl cpanminus
      fi
    fi
  fi
} # }}}

function install_golang() { # {{{
  local version="$1"
  if [ -z "$version" ]; then
    # Get latest stable from official site
    local resp_str
    resp_str=$(curl -sL "https://golang.org/VERSION?m=text")
    version=$(echo "${resp_str}" | head -1)
    echo -e "${COLOR}The latest stable version is ${COLOR1}$version${COLOR}${NC}"
  elif ! (echo "$version" | grep -Eq ^go); then
    version="go$version"
  fi

  if [ "$OS" = 'Linux' ]; then
    if [ -z "$ARCH" ]; then
      echo -e "${COLOR2}Unknown archetecture ${COLOR1}$ARCH${NC}"
      exit 1
    fi

    local installation_path=$OPT_PATH
    local sudo_cmd=sudo
    if [ "$2" = '--user' ] || [ "$2" = '-u' ]; then
      installation_path="$HOME"/.local
      sudo_cmd=
    fi

    local target_path="$installation_path/$version.linux-$ARCH"
    if [ -d "$target_path" ]; then
      echo -e "${COLOR1}$target_path${COLOR} exists, skip${NC}"
      return
    fi

    echo -e "${COLOR}Downloading ${COLOR1}$version.linux-$ARCH.tar.gz${COLOR}${NC}"
    $sudo_cmd wget -P "$installation_path" "https://dl.google.com/go/$version.linux-$ARCH.tar.gz"

    $sudo_cmd mkdir -p "$target_path"
    $sudo_cmd tar xvvzf "$installation_path/$version.linux-$ARCH.tar.gz" -C "$target_path" --strip-components 1
    $sudo_cmd ln -sfnv "$target_path" "$installation_path"/go
    $sudo_cmd rm -rf "$installation_path/$version.linux-$ARCH.tar.gz"

    echo -e "${COLOR1}$version.linux-$ARCH${COLOR} is installed, re-login to take effect${NC}"
  elif [ "$OS" = 'Windows_NT' ]; then
    local target_path
    local installation_path
    target_path="$HOME"/.local
    mkdir -p "$target_path"
    if [ -d "$OPT_PATH" ]; then
      installation_path=$OPT_PATH/runtimes
    else
      installation_path="$target_path"
    fi

    if [ -d "$installation_path/$version" ]; then
      echo -e "${COLOR1}$version${COLOR} is already installed${NC}"
    else
      curl -L "https://dl.google.com/go/$version.windows-amd64.zip" -o "$installation_path/$version".windows-amd64.zip
      unzip -d "$installation_path/$version" "$installation_path/$version".windows-amd64.zip

      if [ -d "$installation_path/$version"/go ]; then
        mv "$installation_path/$version"/go/* "$installation_path/$version" && rm -rf "$installation_path/$version/go"
      fi
    fi

    if [ -d "$installation_path/go" ]; then
      rm -f "$installation_path/go"
    fi

    ln -sfnv "$installation_path/$version" "$installation_path"/go

    if [ -d "$target_path/go" ]; then
      rm -f "$target_path/go"
    fi

    ln -sfnv "$installation_path/$version" "$target_path"/go

    echo -e "${COLOR1}$version${COLOR} is installed, please set the correct environment variables in System Settings${NC}"
  fi
}
# }}}

function install_sdkman() { # {{{
  # https://sdkman.io/install
  curl -s "https://get.sdkman.io" | bash
  if [ -e "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
    # shellcheck source=/dev/null
    source "$HOME/.sdkman/bin/sdkman-init.sh"
  fi
} # }}}

function init_byobu() { # {{{
  if [ ! -d "$HOME/git/myConfigs" ]; then
    fetch_myConfigs
  fi

  rm -rf "$HOME"/.config/tmux "$HOME"/.tmux "$HOME"/.tmux.conf

  if [ "$OS" = 'Linux' ]; then
    mkdir -p "$HOME"/.config/mytmux
    check_link "$HOME"/git/myConfigs/shell/tmux/tmux.conf ~/.config/mytmux/tmux.conf

    if [ ! -d ~/.config/mytmux/plugins/tpm ]; then
      echo -e "${COLOR}Installing ${COLOR1}tpm${COLOR} for tmux...${NC}"
      git clone https://github.com/tmux-plugins/tpm ~/.config/mytmux/plugins/tpm
    fi

    mkdir -p "$HOME"/.config
    check_link "$HOME"/git/myConfigs/shell/byobu "$HOME"/.config/byobu

    if [ ! -d ~/.config/byobu/plugins/tpm ]; then
      echo -e "${COLOR}Installing ${COLOR1}tpm${COLOR} for byobu...${NC}"
      git clone https://github.com/tmux-plugins/tpm ~/.config/byobu/plugins/tpm
    fi
    echo -e "${COLOR}Restart byobu session and install plugins using '${COLOR1}ctrl+a I${COLOR}'${NC}"
  fi
} # }}}

function install_ansible() { # {{{
  if ! check_command pip3; then
    install_python
  fi

  echo -e "${COLOR}Install ${COLOR1}ansible${COLOR}...${NC}"
  pipx install ansible
} # }}}

function install_mc() { # {{{
  if [ "$OS" = 'Linux' ]; then
    curl -L "https://dl.min.io/client/mc/release/linux-$ARCH/mc" -o "$HOME"/.local/bin/mc
    chmod +x "$HOME"/.local/bin/mc
  elif [ "$OS" = 'Darwin' ]; then
    brew install minio/stable/mc
  elif [ "$OS" = 'Windows_NT' ]; then
    curl -L "https://dl.minio.io/client/mc/release/windows-amd64/mc.exe" -o "$HOME"/.local/bin/mc.exe
  fi
} # }}}

function init_k8s() { # {{{
  # Krew
  if [ "$OS" = 'Linux' ]; then
    KREW="krew-linux_${ARCH}"
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz"
    tar zxvf "${KREW}.tar.gz" "$KREW"
    ./"${KREW}" install krew
    rm -f "${KREW}.tar.gz" "${KREW}"
  fi
} # }}}

function init_cilium() { # {{{
  if [ "$OS" = 'Linux' ] || [ "$OS" = 'Darwin' ]; then
    local os_name
    os_name=$(echo "$OS" | tr '[:upper:]' '[:lower:]')

    # Cilium CLI
    local cilium_cli_latest_version
    echo -e "${COLOR}Checking latest ${COLOR1}Cilium CLI${COLOR} version ...${NC}"
    cilium_cli_latest_version=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/master/stable.txt)
    echo -e "${COLOR}Latest ${COLOR1}Cilium CLI${COLOR} version is ${COLOR1}${cilium_cli_latest_version}${NC}"

    local cilium_cli_current_version
    local cilium_cli_version
    if ! check_command cilium; then
      echo -e "${COLOR1}Cilium CLI${COLOR} not found.${NC}"
      cilium_cli_version="$cilium_cli_latest_version"
    else
      set +e
      cilium_cli_current_version="$(cilium version | head -n 1 | cut -d ' ' -f 2)"
      set -e
      echo -e "${COLOR}Current ${COLOR1}Cilium CLI${COLOR} version is ${COLOR1}${cilium_cli_current_version}${NC}"
      if [ "$cilium_cli_current_version" != "$cilium_cli_latest_version" ]; then
        cilium_cli_version="$cilium_cli_latest_version"
      else
        cilium_cli_version=
        cilium_cli_current_version=
      fi
    fi

    if [ -n "$cilium_cli_version" ]; then
      if [ -n "$cilium_cli_current_version" ]; then
        echo -e "${COLOR}Upgrading ${COLOR1}Cilium CLI${COLOR} from ${COLOR1}${cilium_cli_current_version}${COLOR} to ${COLOR1}${cilium_cli_version}${COLOR} ...${NC}"
      else
        echo -e "${COLOR}Installing ${COLOR1}Cilium CLI ${cilium_cli_version}${COLOR} ...${NC}"
      fi

      curl -L --fail --remote-name-all "https://github.com/cilium/cilium-cli/releases/download/${cilium_cli_version}/cilium-${os_name}-${ARCH}.tar.gz{,.sha256sum}"
      sha256sum --check cilium-"${os_name}"-${ARCH}.tar.gz.sha256sum
      $SUDO tar xzvfC cilium-"${os_name}"-${ARCH}.tar.gz /usr/local/bin
      rm cilium-"${os_name}"-${ARCH}.tar.gz{,.sha256sum}
    fi
  else
    echo -e "${COLOR}Please manually download ${COLOR1}Cilium CLI${COLOR} from https://github.com/cilium/cilium-cli/releases/latest${NC}"
  fi

  # Hubble CLI
  if [ "$OS" = 'Linux' ] || [ "$OS" = 'Darwin' ]; then
    local os_name
    os_name=$(echo "$OS" | tr '[:upper:]' '[:lower:]')

    local hubble_cli_latest_version
    echo -e "${COLOR}Checking latest ${COLOR1}Hubble CLI${COLOR} version ...${NC}"
    hubble_cli_latest_version=$(curl -s https://raw.githubusercontent.com/cilium/hubble/master/stable.txt)
    echo -e "${COLOR}Latest ${COLOR1}Hubble CLI${COLOR} version is ${COLOR1}${hubble_cli_latest_version}${NC}"

    local hubble_cli_current_version
    local hubble_cli_version
    if ! check_command cilium; then
      echo -e "${COLOR1}Hubble CLI${COLOR} not found.${NC}"
      hubble_cli_version="$hubble_cli_latest_version"
    else
      set +e
      hubble_cli_current_version=v"$(hubble version | head -n 1 | awk '{ print $2 }')"
      set -e
      echo -e "${COLOR}Current ${COLOR1}Hubble CLI${COLOR} version is ${COLOR1}${hubble_cli_current_version}${NC}"

      if [ "$hubble_cli_current_version" != "$hubble_cli_latest_version" ]; then
        hubble_cli_version="$hubble_cli_latest_version"
      else
        hubble_cli_version=
        hubble_cli_current_version=
      fi
    fi

    if [ -n "$hubble_cli_version" ]; then
      if [ -n "$hubble_cli_current_version" ]; then
        echo -e "${COLOR}Upgrading ${COLOR1}Hubble CLI${COLOR} from ${COLOR1}${hubble_cli_current_version}${COLOR} to ${COLOR1}${hubble_cli_version}${COLOR} ...${NC}"
      else
        echo -e "${COLOR}Installing ${COLOR1}Hubble CLI ${hubble_cli_version}${COLOR} ...${NC}"
      fi

      curl -L --fail --remote-name-all "https://github.com/cilium/hubble/releases/download/$hubble_cli_version/hubble-${os_name}-${ARCH}.tar.gz{,.sha256sum}"
      sha256sum --check hubble-"${os_name}"-${ARCH}.tar.gz.sha256sum
      $SUDO tar xzvfC hubble-"${os_name}"-${ARCH}.tar.gz /usr/local/bin
      rm hubble-"${os_name}"-${ARCH}.tar.gz{,.sha256sum}
    fi
  else
    echo -e "${COLOR}Please manually download ${COLOR1}Hubble CLI${COLOR} from https://github.com/cilium/hubble/releases${NC}"
  fi
} #}}}

function init_bpf() { # {{{ # Initialization of BPF development environment
  if [ "$OS" = 'Linux' ]; then
    if [ "$DISTRO" = 'Ubuntu' ]; then
      $SUDO env NEEDRESTART_MODE=a apt-get install build-essential git make libelf-dev libelf1 \
        clang llvm strace tar make bpfcc-tools \
        linux-headers-"$(uname -r)" gcc-multilib

      git clone --depth 1 git://kernel.ubuntu.com/ubuntu-stable/ubuntu-stable-"$(lsb_release -c -s)".git /tmp/kernel_src &&
        $SUDO mv /tmp/kernel_src /opt/kernel-src &&
        cd /opt/kernel-src/tools/lib/bpf &&
        $SUDO make && $SUDO make install prefix=/usr/local &&
        $SUDO mv /usr/local/lib64/libbpf.* /lib/x86_64-linux-gnu/
    fi
  else
    echo -e "${COLOR}OS not supported.${NC}"
  fi
} # }}}

function install_talosctl { # {{{ Install talosctl, see https://www.talos.dev
  if ! check_command talosctl; then
    curl -sL https://talos.dev/install | sh
  fi
} # }}}

function init_gui() { # {{{
  if [ "$OS" = 'Linux' ]; then
    # Install alacritty
    if ! check_command alacritty; then
      if ! check_command cargo; then
        install_rust
      fi
      cargo install alacritty
    fi
    mkdir -p ~/.config/alacritty
    if [ ! -d "$HOME/git/myConfigs" ]; then
      fetch_myConfigs
    fi
    ln -snfv "$HOME"/git/myConfigs/X11/alacritty "$HOME"/.config/alacritty

    if ! check_command npm; then
      install_node
    fi
    npm install -g alacritty-theme-switch
  fi
} # }}}

function print_info() { # {{{
  echo -e "\nUsage:\n${COLOR}install.sh [COMMAND]${NC}"
  echo -e "\nCommands:"
  echo -e "\tinfo \t\tShow system information"
  echo -e "\tinit \t\tInitialize environment, '-m' for minimal setup"
  echo -e "\tgit \t\tInstall git"
  echo -e "\truby \t\tInstall ruby"
  echo -e "\tmyConfigs \tClone myConfigs repository"
  echo -e "\tpython \t\tInstall python"
  echo -e "\tnode \t\tInstall node"
  echo -e "\tfish \t\tInstall fish shell (On Windows only)"
  echo -e "\tzsh \t\tInstall zsh"
  echo -e "\tvim \t\tInstall vim"
  echo -e "\trxvt \t\tInstall rxvt"
  echo -e "\tllvm \t\tInstall llvm"
  echo -e "\tdocker \t\tInstall docker"
  echo -e "\tcontainerd \tInstall containerd"
  echo -e "\tmysql \t\tInstall mysql"
  echo -e "\tsamba \t\tInstall samba"
  echo -e "\tctags \t\tInstall universal ctags"
  echo -e "\trust \t\tInstall Rust"
  echo -e "\tlua \t\tInstall lua"
  echo -e "\tperl \t\tInstall perl"
  echo -e "\tgolang \t\tInstall golang, version can be specified as the next argument"
  echo -e "\ttalosctl \tInstall talosctl"
  echo -e "\tsdkman \t\tInstall sdkman"
  echo -e "\tbyobu \t\tInstall byobu"
  echo -e "\tansible \tInstall ansible"
  echo -e "\tmc \t\tInstall Minio client" 
  echo -e "\tk8s \t\tInitialize Kubernetes"
  echo -e "\tcilium \t\tInitialize Cilium"
  echo -e "\tbpf \t\tInitialize BPF development environment"
  echo -e "\tgui \t\tInitialize GUI"
} # }}}

case $1 in
info) show_sysinfo ;;
init)
  shift
  init_env "$@"
  ;;
git) install_git ;;
ruby) install_ruby ;;
myConfigs) fetch_myConfigs ;;
python) install_python ;;
node) install_node ;;
fish) install_fish ;;
zsh) install_zsh ;;
vim) install_vim ;;
rxvt) install_rxvt ;;
llvm) install_llvm ;;
docker) install_docker ;;
containerd) install_containerd ;;
mysql) install_mysql ;;
samba) install_samba ;;
ctags) install_universal_ctags ;;
rust) install_rust ;;
lua) install_lua ;;
perl) install_perl ;;
golang)
  shift
  install_golang "$@"
  ;;
talosctl) install_talosctl ;;
sdkman) install_sdkman ;;
byobu) init_byobu ;;
ansible) install_ansible ;;
mc) install_mc ;;
k8s) init_k8s ;;
cilium) init_cilium ;;
bpf) init_bpf ;;
gui) init_gui ;;
*) print_info ;;
esac

# vim: fdm=marker
