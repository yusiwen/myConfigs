#!/usr/bin/env bash

function _install_byobu() { # {{{
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