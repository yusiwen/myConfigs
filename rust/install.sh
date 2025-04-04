#!/usr/bin/env bash

function _install_rust() { # {{{
  if [ "$OS" = 'Linux' ]; then
    if ! check_command rustc && [ ! -e "$HOME"/.cargo/bin/rustc ]; then
      echo -e "${COLOR}Installing ${COLOR1}Rust${COLOR} using official script...${NC}"
      if [ -n "$MIRRORS" ] && [ "$MIRRORS" -eq 1 ]; then
        gum spin --show-error --title "Installing rust using CN repoistory..." -- \
          bash -c "env RUSTUP_DIST_SERVER='https://rsproxy.cn' RUSTUP_UPDATE_ROOT='https://rsproxy.cn/rustup' bash -c \"curl --proto '=https' --tlsv1.2 -sSf https://rsproxy.cn/rustup-init.sh | sh -s -- -y\""
      else
        gum spin --show-error --title "Installing rust..." -- \
          bash -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
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
        gum spin --show-error --title "Installing build-essential..." -- \
          bash -c "$SUDO env NEEDRESTART_MODE=a DEBIAN_FRONTEND=noninteractive apt-get -qq install -y build-essential"
      fi
    fi

    if ! check_command pkg-config; then
      if [ "$DISTRO" = 'CentOS' ]; then
        $SUDO yum install pkgconfig
      else
        gum spin --show-error --title "Installing pkg-config..." -- \
          bash -c "$SUDO env NEEDRESTART_MODE=a DEBIAN_FRONTEND=noninteractive apt-get -qq install -y pkg-config"
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
      gum spin --show-error --title "Installing bottom..." -- \
        bash -c "cargo install bottom"
    else
      echo -e "${COLOR}${COLOR1}bottom${COLOR} is found.${NC}"
    fi

    if ! check_command cargo-install-update; then
      echo -e "${COLOR}Installing ${COLOR1}cargo-update${COLOR}...${NC}"
      gum spin --show-error --title "Installing cargo-update..." -- \
        bash -c "$SUDO env NEEDRESTART_MODE=a DEBIAN_FRONTEND=noninteractive apt-get -qq install -y libssl-dev && cargo install cargo-update && cargo install-update -a"
    else
      echo -e "${COLOR}${COLOR1}cargo-update${COLOR} is found.${NC}"
      gum spin --show-error --title "Executing cargo install-update -a..." -- \
        bash -c "cargo install-update -a"
    fi

    if ! check_command cargo-cache; then
      echo -e "${COLOR}Installing ${COLOR1}cargo-cache${COLOR}...${NC}"
      gum spin --show-error --title "Installing cargo-cache..." -- \
        baseh -c "cargo install cargo-cache"
    else
      echo -e "${COLOR}${COLOR1}cargo-cache${COLOR} is found.${NC}"
    fi
  elif [ "$OS" = "Windows_NT" ]; then
    echo -e "Please download and run installer from: https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-msvc/rustup-init.exe"
  fi
} # }}}