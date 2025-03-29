#!/usr/bin/env bash

function _install_cilium() { # {{{
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
      sha256sum --check cilium-"${os_name}"-"${ARCH}".tar.gz.sha256sum
      $SUDO tar xzvfC cilium-"${os_name}"-"${ARCH}".tar.gz /usr/local/bin
      rm cilium-"${os_name}"-"${ARCH}".tar.gz{,.sha256sum}
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
      sha256sum --check hubble-"${os_name}"-"${ARCH}".tar.gz.sha256sum
      $SUDO tar xzvfC hubble-"${os_name}"-"${ARCH}".tar.gz /usr/local/bin
      rm hubble-"${os_name}"-"${ARCH}".tar.gz{,.sha256sum}
    fi
  else
    echo -e "${COLOR}Please manually download ${COLOR1}Hubble CLI${COLOR} from https://github.com/cilium/hubble/releases${NC}"
  fi
} # }}}