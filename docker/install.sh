#!/usr/bin/env bash

function _install_docker() { # {{{
  if [ "$OS" = 'Linux' ]; then
    if [ "$DISTRO" = 'Ubuntu' ] || [ "$DISTRO" = 'Debian' ]; then
      echo -e "${COLOR}Ubuntu is found, checking ${COLOR1}docker${COLOR}...${NC}"
      if ! check_command docker; then
        echo -e "${COLOR1}docker${COLOR} is not found, installing...${NC}"
        echo -e "${COLOR}Installing prerequisite packages...${NC}"
        $SUDO env NEEDRESTART_MODE=a apt-get -y install apt-transport-https ca-certificates curl software-properties-common

        if [ ! -e /etc/apt/trusted.gpg.d/aliyun-docker-ce.gpg ]; then
          echo -e "${COLOR}Add mirrors.aliyun.com/docker-ce public key...${NC}"
          curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | gpg --dearmor >aliyun-docker-ce.gpg
          sudo install -D -o root -m 644 aliyun-docker-ce.gpg /etc/apt/trusted.gpg.d/aliyun-docker-ce.gpg
          rm -f aliyun-docker-ce.gpg
        fi

        local add_docker_repo
        add_docker_repo=0
        if [ -e /etc/apt/sources.list.d ] && [ -n "$(find /etc/apt/sources.list.d -maxdepth 1 -name '*.list' -printf 'FOUND' -quit)" ]; then
          if ! grep -q "aliyun.com/docker-ce" /etc/apt/sources.list.d/*.list; then
            add_docker_repo=1
          fi
        else
          add_docker_repo=1
        fi

        if [ $add_docker_repo -eq 1 ]; then
          echo -e "${COLOR}Add mirrors.aliyun.com/docker-ce apt source...${NC}"
          if [ "$OS_ARCH" = 'aarch64' ] || [ "$OS_ARCH" = 'arm64' ]; then # for Raspberry Pi
            $SUDO add-apt-repository -y "deb [arch=arm64] http://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
          else
            $SUDO add-apt-repository -y "deb [arch=amd64] http://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
          fi
          $SUDO apt-get -y update
        fi

        echo -e "${COLOR}Installing docker-ce...${NC}"
        $SUDO env NEEDRESTART_MODE=a apt-get -y install docker-ce
      else
        echo -e "${COLOR1}$(docker -v)${COLOR} is found...${NC}"
      fi

      # User and group 
      $SUDO groupadd -f docker
      if [ "$USER" != 'root' ]; then
        if ! grep -q "^docker.*:$USER.*" /etc/group; then
          echo -e "${COLOR}Add user ${COLOR1}${USER}${COLOR} to group 'docker'...${NC}"
          $SUDO usermod -aG docker "$USER"
        fi
      fi

      if [ ! -e /etc/docker/daemon.json ]; then
        $SUDO mkdir -p /etc/docker
        $SUDO cp "$HOME"/myConfigs/docker/daemon.json /etc/docker/daemon.json
      fi

      if [ -n "$USE_PROXY" ] && [ "$USE_PROXY" -eq 1 ]; then
        if [ ! -e /etc/systemd/system/docker.service.d ]; then
          $SUDO mkdir -p /etc/systemd/system/docker.service.d
          $SUDO cp "$HOME"/myConfigs/docker/proxy.conf /etc/systemd/system/docker.service.d/proxy.conf
        fi
      fi
    fi
  else
    echo -e "${COLOR}Unsupported on this OS.${NC}"
  fi
} # }}}

function _install_containerd() { # {{{
  if [ "$OS" = 'Linux' ]; then
    if ! check_command containerd; then
      local containerd_version
      containerd_version=$(get_latest_release_from_github containerd/containerd)
      echo -e "${COLOR}Installing containerd ${COLOR1}${containerd_version}${COLOR}...${NC}"
      wget "https://github.com/containerd/containerd/releases/download/v${containerd_version}/cri-containerd-cni-${containerd_version}-linux-${ARCH}.tar.gz" -O /tmp/cri-containerd.tar.gz
      $SUDO tar xvzf /tmp/cri-containerd.tar.gz -C /
      $SUDO mkdir -p /etc/containerd && /usr/local/bin/containerd config default | sudo tee /etc/containerd/config.toml >/dev/null
    fi

    if ! check_command buildctl; then
      local buildkit_version
      buildkit_version=$(get_latest_release_from_github moby/buildkit)
      echo -e "${COLOR}Installing buildkit ${COLOR1}${buildkit_version}${COLOR}...${NC}"
      wget "https://github.com/moby/buildkit/releases/download/v${buildkit_version}/buildkit-v${buildkit_version}.linux-${ARCH}.tar.gz" -O /tmp/buildkit.tar.gz
      $SUDO tar xvzf /tmp/buildkit.tar.gz -C /usr/local/
      rm /tmp/buildkit.tar.gz
    fi

    # {{{ Install nerdctl
    local nerdctl_version
    nerdctl_version=$(get_latest_release_from_github containerd/nerdctl)
    local nerdctl_download_url
    if ! check_command nerdctl; then
      nerdctl_download_url="https://github.com/containerd/nerdctl/releases/download/v${nerdctl_version}/nerdctl-${nerdctl_version}-linux-${ARCH}.tar.gz"
    else
      local nerdctl_current_version
      nerdctl_current_version=$(nerdctl version -f '{{ .Client.Version }}' | sed 's/^v//g')
      echo -e "${COLOR}Found current nerdctl ${COLOR1}${nerdctl_current_version}${COLOR}${NC}"
      local vercomp_rst=0
      vercomp_rst=$(vercomp "$nerdctl_current_version" "$nerdctl_version")
      if [ "$vercomp_rst" -eq 1 ]; then
        echo -e "${COLOR}Found latest nerdctl ${COLOR1}${nerdctl_version}${COLOR}${NC}"
        nerdctl_download_url="https://github.com/containerd/nerdctl/releases/download/v${nerdctl_version}/nerdctl-${nerdctl_version}-linux-${ARCH}.tar.gz"
      fi
    fi
    echo "$nerdctl_download_url"
    if [ -n "$nerdctl_download_url" ]; then
      echo -e "${COLOR}Installing nerdctl ${COLOR1}${nerdctl_version}${COLOR}...${NC}"
      wget "$nerdctl_download_url" -O /tmp/nerdctl.tar.gz
      $SUDO tar xvzf /tmp/nerdctl.tar.gz -C /usr/local/bin
      rm /tmp/nerdctl.tar.gz
    fi # }}}

    if [ -e /etc/systemd/system/containerd.service ]; then
      $SUDO systemctl daemon-reload
      $SUDO systemctl enable containerd
      $SUDO systemctl start containerd
    fi

    # {{{ Rootless containers
    read -r -p "Do you want rootless container? (yes/No) " yn

    case $yn in
    yes | YES | Yes | y | Y) ;;
    *) return ;;
    esac

    if [ "$DISTRO" = 'Ubuntu' ] || [ "$DISTRO" = 'Debian' ]; then
      if ! check_command newuidmap; then
        $SUDO env NEEDRESTART_MODE=a apt-get install uidmap
      fi

      if ! check_command slirp4netns; then
        $SUDO env NEEDRESTART_MODE=a apt-get install slirp4netns
      fi

      if ! check_command rootlesskit; then
        local rootlesskit_version
        rootlesskit_version=$(get_latest_release_from_github rootless-containers/rootlesskit)
        wget "https://github.com/rootless-containers/rootlesskit/releases/download/v${rootlesskit_version}/rootlesskit-${OS_ARCH}.tar.gz" -O /tmp/rootlesskit.tar.gz
        $SUDO tar xvzf /tmp/rootlesskit.tar.gz -C /usr/local/bin
      fi

      /usr/local/bin/containerd-rootless-setuptool.sh install

      # Install CNI tools
      if ! check_command cnitool; then
        if ! check_command go; then
          install_golang
          export GOROOT="$HOME"/.local/go
          export GOPATH=$HOME/.gopackages
        fi
        echo -e "${COLOR}Installing ${COLOR1}cnitool${COLOR}...${NC}"
        go install github.com/containernetworking/cni/cnitool@latest
      fi
    else
      echo -e "${COLOR}Unsupported on this ${COLOR1}${DISTRO}${COLOR}.${NC}"
    fi
    # }}}
  else
    echo -e "${COLOR}Unsupported on this OS.${NC}"
  fi
}
# }}}

