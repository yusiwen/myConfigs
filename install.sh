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

SPINNER=

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
      gum spin --show-error --title "Adding universe repository..." -- \
        bash -c "$SUDO add-apt-repository -y universe"
      gum spin --show-error --title "Installing libfuse2..." -- \
        bash -c "$SUDO env NEEDRESTART_MODE=a apt-get -qq install -y libfuse2"
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

function install_mu() {
  local path=""
  if [ "$OS" == 'Windows_NT' ]; then
    path="windows/amd64/mu.exe"
  elif [ "$OS" == 'Linux' ]; then
    path="linux/$ARCH/mu"
  fi

  $SUDO curl -s -L "https://share.yusiwen.cn/public/mu/$path" -o /usr/local/bin/mu
  $SUDO chmod +x /usr/local/bin/mu
}

function install_gum() { # {{{
  if ! check_command mu; then
    install_mu
  fi

  mu install --move charmbracelet/gum
} # }}}

# Initialize apt and install prerequisite packages
function init_env() { # {{{
  local minimal=0
  if [ "$1" = '-m' ]; then
    minimal=1
  elif [ "$1" = '-b' ]; then
    minimal=2
  fi

  echo -e "${COLOR}Initializing system...${NC}"

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

      gum spin --title "Updating apt-get index..." -- bash -c "$SUDO apt-get update"
      local pkg_pstack=()
      if [ "$ARCH" = 'amd64' ] && [ "$DISTRO" = 'Ubuntu' ]; then
        pkg_pstack=( pstack ltrace )
      else
        pkg_pstack=()
      fi

      local pkg_btop=()
      if apt-cache search btop | grep -q '^btop'; then
        pkg_btop=( btop )
      fi
      
      local pkg_core=( gdebi-core software-properties-common apt-transport-https )
      local pkg_zip=( p7zip-full pigz zip unzip )
      local pkg_network=( curl wget net-tools iputils-ping iputils-arping hping3 nmap ethtool )
      local pkg_build=( build-essential cmake "${pkg_pstack[@]}" )
      local pkg_fs=( cifs-utils nfs-common )
      local pkg_monitor=( htop atop "${pkg_btop[@]}" iotop iftop nethogs nload sysstat )
      local pkg_misc=( tmux byobu jq pass ncdu silversearcher-ag shellcheck command-not-found )

      gum spin --show-error --title "Installing core packages..." -- \
        bash -c "$SUDO env NEEDRESTART_MODE=a DEBIAN_FRONTEND=noninteractive apt-get -qq install -y ${pkg_core[*]}" 
      gum spin --show-error --title "Installing zip packages..." -- \
        bash -c "$SUDO env NEEDRESTART_MODE=a DEBIAN_FRONTEND=noninteractive apt-get -qq install -y ${pkg_zip[*]}"
      gum spin --show-error --title "Installing network packages..." -- \
        bash -c "$SUDO env NEEDRESTART_MODE=a DEBIAN_FRONTEND=noninteractive apt-get -qq install -y ${pkg_network[*]}"
      gum spin --show-error --title "Installing filesystem packages..." -- \
        bash -c "$SUDO env NEEDRESTART_MODE=a DEBIAN_FRONTEND=noninteractive apt-get -qq install -y ${pkg_fs[*]}"
      gum spin --show-error --title "Installing monitor packages..." -- \
        bash -c "$SUDO env NEEDRESTART_MODE=a DEBIAN_FRONTEND=noninteractive apt-get install -qq -y ${pkg_monitor[*]}"
      gum spin --show-error --title "Installing misc packages..." -- \
        bash -c "$SUDO env NEEDRESTART_MODE=a DEBIAN_FRONTEND=noninteractive apt-get install -qq -y ${pkg_misc[*]}"

      if [ $minimal -eq 2 ]; then
        gum spin --show-error --title "Installing development packages..." -- \
          bash -c "$SUDO env NEEDRESTART_MODE=a DEBIAN_FRONTEND=noninteractive apt-get -qq install -y ${pkg_build[*]}"
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
      fetch_myConfigs
      install_git
    else
      fetch_myConfigs
      install_perl
      install_lua
      install_rust
      install_git
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

# Initialize myConfigs repo
function fetch_myConfigs() { # {{{
  mkdir -p "$HOME"/git
  if [ -d "$HOME"/git/myConfigs ]; then
    echo -e "${COLOR1}git/myConfigs${COLOR} already exists.${NC}"
    return
  fi

  if ! check_command git; then
    curl -L "https://codeload.github.com/yusiwen/myConfigs/zip/refs/heads/master" -o /tmp/myConfigs.zip
    unzip /tmp/myConfigs.zip -d "$HOME"/git
    mv "$HOME"/git/myConfigs-master "$HOME"/git/myConfigs
    rm -f /tmp/myConfigs.zip
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
  # shellcheck disable=SC1091
  source "$HOME"/myConfigs/python/install.sh
  _install_python 
} # }}}

function install_node() { # {{{
  # shellcheck disable=SC1091
  source "$HOME"/myConfigs/node/install.sh
  _install_node
} # }}}

function install_fish() {
  # shellcheck disable=SC1091
  source "$HOME"/myConfigs/shell/fish/install.sh
  _install_fish
}

function install_zsh() { # {{{
  # shellcheck disable=SC1091
  source "$HOME"/myConfigs/shell/zsh/install.sh
  _install_zsh
} # }}}

function install_vim() { # {{{
  # shellcheck disable=SC1091
  source "$HOME"/myConfigs/vim/install.sh
  _install_vim
} #}}}

# Universal Ctags
function install_universal_ctags() { # {{{
  # shellcheck disable=SC1091
  source "$HOME"/myConfigs/ctags/install.sh
  _install_ctags
} # }}}

# Git
function install_git() { # {{{
  # shellcheck disable=SC1091
  source "$HOME"/myConfigs/git/install.sh
  _install_git 
} # }}}

function install_ruby() { # {{{
  # shellcheck disable=SC1091
  source "$HOME"/myConfigs/ruby/install.sh
  _install_ruby
} # }}}

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
  # shellcheck disable=SC1091
  source "$HOME"/myConfigs/docker/install.sh
  _install_docker
} # }}}

function install_containerd() { # {{{
  # shellcheck disable=SC1091
  source "$HOME"/myConfigs/docker/install.sh
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
  # shellcheck disable=SC1091
  source "$HOME"/myConfigs/rust/install.sh
  _install_rust
} # }}}

function install_lua() { # {{{
  # shellcheck disable=SC1091
  source "$HOME"/myConfigs/lua/install.sh
  _install_lua
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
  # shellcheck disable=SC1091
  source "$HOME"/myConfigs/golang/install.sh
  _install_golang "$@"
} # }}}

function install_sdkman() { # {{{
  # https://sdkman.io/install
  curl -s "https://get.sdkman.io" | bash
  if [ -e "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
    # shellcheck source=/dev/null
    source "$HOME/.sdkman/bin/sdkman-init.sh"
  fi
} # }}}

function init_byobu() { # {{{
  # shellcheck disable=SC1091
  source "$HOME"/myConfigs/byobu/install.sh
  _install_byobu
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
  # shellcheck disable=SC1091
  source "$HOME"/myConfigs/k8s/cilium/install.sh
  _install_cilium
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
  echo -e "\tgum \t\tInstall charmbracelet/gum"
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
gum) install_gum ;;
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
