#!/usr/bin/env bash

function _install_golang() { # {{{
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
} # }}}