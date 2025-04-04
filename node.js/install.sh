#!/usr/bin/env bash

function _install_node() { # {{{
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

  npm install -g yarn eslint npm-check npm-check-updates nrm pnpm
  # Install cli tools for git commit conventions
  echo -e "${COLOR1}Installing conventional-changelog-cli, Commitizen, cz-customizable, standard-version...${NC}"
  npm install -g conventional-changelog-cli commitizen cz-customizable standard-version diff-so-fancy

  echo -e "${COLOR1}Installing tldr...${NC}"
  npm install -g tldr

  echo -e "${COLOR1}Installing sonar-scanner...${NC}"
  npm install -g sonar-scanner

  if check_command git; then
    if ! check_command delta; then
      git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
    fi
  fi
} # }}}