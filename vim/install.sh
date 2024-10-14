#!/usr/bin/env bash

function _install_vim() { # {{{
  CONFIG_VIM="$HOME"/myConfigs/vim

  if [ ! -d "$CONFIG_VIM" ]; then
    fetch_myConfigs
  fi

  if [ "$OS" = 'Linux' ]; then
    if [ "$DISTRO" = 'Ubuntu' ] || [ "$DISTRO" = 'Debian' ]; then

      # Get latest version
      local latest_version
      local installation_target
      local download_url

      if [ "$OS_ARCH" = 'aarch64' ]; then # for Raspberry Pi
        latest_version=$(get_latest_release_from_github 'matsuu/neovim-aarch64-appimage')
        installation_target="$HOME/.local/bin/nvim-v${latest_version}-aarch64.appimage"
        download_url="https://github.com/matsuu/neovim-aarch64-appimage/releases/download/v${latest_version}/nvim-v${latest_version}-aarch64.appimage"
      else
        latest_version=$(curl -sL 'https://api.github.com/repos/neovim/neovim/releases/tags/stable' | jq --raw-output '.created_at')
        installation_target="$HOME/.local/bin/neovim.${latest_version}.appimage"
        download_url="https://github.com/neovim/neovim/releases/download/stable/nvim.appimage"
      fi

      if ! check_command nvim; then
        echo -e "${COLOR1}NeoVim${COLOR} is not found.${NC}"

        # Install VIM_PACKAGE
        echo -e "${COLOR}Install latest stable ${COLOR1}NeoVim${COLOR} created at $latest_version...${NC}"

        local link_target="$HOME/.local/bin/nvim"
        curl -L "$download_url" -o "$installation_target"
        chmod +x "$installation_target"
        check_link "$installation_target" "$link_target"
      else
        echo -e "${COLOR1}NeoVim${COLOR} is found at '$(which nvim)'${NC}"
        if [ ! -e "$installation_target" ]; then
          # Upgrade VIM_PACKAGE
          echo -e "${COLOR}Upgrade to latest stable ${COLOR1}NeoVim${COLOR} created at $latest_version...${NC}"

          local link_target="$HOME/.local/bin/nvim"
          curl -L "$download_url" -o "$installation_target"
          chmod +x "$installation_target"
          if [ -e  "$(readlink "$link_target")" ]; then
            rm -f "$(readlink "$link_target")"
          fi
          check_link "$installation_target" "$link_target"
        fi
      fi

      echo -e "${COLOR}Install supplementary tools...${NC}"
      install_perl
      install_lua
      $SUDO env NEEDRESTART_MODE=a apt-get install -y silversearcher-ag cscope astyle
    elif [ "$DISTRO" = 'Manjaro' ]; then
      if ! check_command nvim; then
        yay -S neovim
      fi
    elif [ "$DISTRO" = 'CentOS' ]; then
      if ! check_command nvim; then
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
        wget "$download_url" -P "$HOME"/.local/bin
        ln -sfnv "$HOME"/.local/bin/nvim.appimage "$HOME"/.local/bin/nvim
      fi
    fi
  elif [ "$OS" = 'Darwin' ]; then
    echo -e "${COLOR}Install development branch of Neovim...${NC}"
    brew install --HEAD neovim
    echo -e "${COLOR}Install supplementary tools...${NC}"
    brew install the_silver_searcher cscope astyle
  elif [ "$OS" = 'Windows_NT' ]; then
    if ! check_command nvim; then
      echo -e "${COLOR}Please make sure neovim is installed.${NC}"
      return
    fi
  else
    echo -e "${COLOR}Unknown OS, please make sure neovim is installed.${NC}"
    return
  fi

  check_link "$HOME"/git/myConfigs/vim/nvchad "$HOME"/.config/nvim

  if [ "$OS" = 'Windows_NT' ]; then
    check_link "$HOME"/git/myConfigs/vim/nvchad "$HOME"/AppData/Local/nvim
  fi

  check_link "$HOME"/git/myConfigs/vim/ideavimrc "$HOME"/.ideavimrc

  echo -e "${COLOR}Run ${COLOR1}nvim${COLOR} to initialize plugins and run ${COLOR1}:MasonInstallAll${COLOR} to install LSP${NC}"
} #}}}