#!/usr/bin/env bash

function _install_rust() { # {{{
  if [ "$OS" = 'Linux' ]; then
    if ! check_command rustup && [ ! -e "$HOME"/.cargo/bin/rustc ]; then
      echo -e "${COLOR}Installing ${COLOR1}Rust${COLOR} using official script...${NC}"
      if [ -n "$MIRRORS" ] && [ "$MIRRORS" -eq 1 ]; then
        "$MU_BIN" run --command "Installing rust using CN repoistory"::"env RUSTUP_DIST_SERVER='https://rsproxy.cn' RUSTUP_UPDATE_ROOT='https://rsproxy.cn/rustup' bash -c \"curl --proto '=https' --tlsv1.2 -sSf https://rsproxy.cn/rustup-init.sh | sh -s -- -y\""
      else
        "$MU_BIN" run --command "Installing rust"::"curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
      fi

      if [ -e "$HOME/.cargo/env" ]; then
        source "$HOME/.cargo/env"
      else
        echo -e "${COLOR2}Installation is failed, please check manually.${NC}"
        exit 1
      fi

      if [ -n "$MIRRORS" ] && [ "$MIRRORS" -eq 1 ]; then
        cat << EOF | tee -a "${CARGO_HOME:-$HOME/.cargo}/config.toml"
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
        rustup self update
        rustup update
      fi
    fi

    # Make sure cargo can be built when installing
    if ! check_command cc; then
      if [ "$DISTRO" = 'CentOS' ]; then
        $SUDO yum groupinstall 'Development Tools'
      else
        "$MU_BIN" run --command "Installing build-essential"::"$SUDO env NEEDRESTART_MODE=a DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential"
      fi
    fi

    if ! check_command pkg-config; then
      if [ "$DISTRO" = 'CentOS' ]; then
        $SUDO yum install pkgconfig
      else
        "$MU_BIN" run --command "Installing pkg-config"::"$SUDO env NEEDRESTART_MODE=a DEBIAN_FRONTEND=noninteractive apt-get install -y pkg-config"
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
      "$MU_BIN" run --command "Installing bottom"::"cargo install bottom"
    else
      echo -e "${COLOR}${COLOR1}bottom${COLOR} is found.${NC}"
    fi

    if ! check_command cargo-install-update; then
      echo -e "${COLOR}Installing ${COLOR1}cargo-update${COLOR}...${NC}"
      "$MU_BIN" run --command "Installing cargo-update"::"$SUDO env NEEDRESTART_MODE=a DEBIAN_FRONTEND=noninteractive apt-get install -y libssl-dev && cargo install cargo-update && cargo install-update -a"
    else
      echo -e "${COLOR}${COLOR1}cargo-update${COLOR} is found.${NC}"
      "$MU_BIN" run --command "Executing cargo install-update -a"::"cargo install-update -a"
    fi

    if ! check_command cargo-cache; then
      echo -e "${COLOR}Installing ${COLOR1}cargo-cache${COLOR}...${NC}"
      "$MU_BIN" run --command "Installing cargo-cache"::"cargo install cargo-cache"
    else
      echo -e "${COLOR}${COLOR1}cargo-cache${COLOR} is found.${NC}"
    fi
  elif [ "$OS" = "Windows_NT" ]; then
    echo -e "Please download and run installer from: https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-msvc/rustup-init.exe"
  fi
} # }}}