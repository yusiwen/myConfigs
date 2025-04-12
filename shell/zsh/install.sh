#!/usr/bin/env bash

function _install_zsh() { # {{{
  CONFIG_SHELL="$HOME"/myConfigs/shell
  if [ ! -d "$CONFIG_SHELL" ]; then
    fetch_myConfigs
  fi

  # Make sure submodules are fetched or updated
  git -C "$HOME/myConfigs" submodule update --init

  if [ "$OS" = 'Linux' ]; then
    if [ ! "$SHELL" = "/usr/bin/zsh" ] && [ ! "$SHELL" = "/usr/local/bin/zsh" ]; then
      echo -e "${COLOR}Current SHELL is not ${COLOR1}Zsh${NC}"
      if [ ! -e /usr/bin/zsh ]; then
        echo -e "${COLOR}Installing ${COLOR1}Zsh${COLOR}...${NC}"
        if [ "$DISTRO" = 'Ubuntu' ] || [ "$DISTRO" = 'Debian' ]; then
          $SUDO env NEEDRESTART_MODE=a apt-get install -y zsh zip
        elif [ "$DISTRO" = 'CentOS' ]; then
          $SUDO yum install -y zsh zip
          which zsh | $SUDO tee -a /etc/shells >/dev/null
        fi
      fi
      echo -e "${COLOR}Change SHELL to ${COLOR1}Zsh${COLOR}, take effect on next login${NC}"
      $SUDO chsh -s "$(which zsh)" "$(whoami)"
    fi
  elif [ "$OS" = 'Darwin' ]; then
    if [ ! "$SHELL" = "/usr/local/bin/zsh" ]; then
      echo -e "${COLOR}Current SHELL is not latest ${COLOR1}Zsh${NC}"
      if [ ! -e /usr/local/bin/zsh ] || [ ! -e /bin/zsh ]; then
        echo -e "${COLOR}Installing ${COLOR1}Zsh${COLOR}...${NC}"
        brew install zsh
        echo -e "${COLOR}Change SHELL to ${COLOR1}Zsh${COLOR}, take effect on next login${NC}"
        chsh -s /usr/local/bin/zsh
      fi
    fi
  elif [ "$OS" = 'Windows_NT' ]; then
    if [ ! -e /usr/bin/zsh ]; then
      if check_command pacman; then
        echo -e "${COLOR}Installing ${COLOR1}Zsh${COLOR}...${NC}"
        pacman -S zsh --overwrite '*'
      else
        echo -e "${COLOR}Please install ${COLOR1}pacman${COLOR} first or manually install zsh${NC}"
      fi
    fi
  else
    echo -e "${COLOR}Unsupported OS: ${COLOR1}${OS}{COLOR}${NC}"
  fi

  check_link "$CONFIG_SHELL"/bash/bashrc "$HOME"/.bashrc
  check_link "$CONFIG_SHELL"/bash/bash_aliases "$HOME"/.bash_aliases
  check_link "$CONFIG_SHELL"/bash/bash_profile "$HOME"/.bash_profile
  check_link "$CONFIG_SHELL"/profile "$HOME"/.profile
  check_link "$CONFIG_SHELL"/zsh/zshrc.zinit "$HOME"/.zshrc
  check_link "$CONFIG_SHELL"/starship/starship.toml "$HOME"/.config/starship.toml

  if [ "$SHELL" = 'zsh' ]; then
    source "$HOME/.zshrc"
  else
    echo -e "${COLOR}Please restart your terminal${NC}"
  fi
} # }}}
