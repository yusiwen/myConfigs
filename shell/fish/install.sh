#!/usr/bin/env bash

function _install_pacman() {
  if ! check_command pacman; then
    if ! check_command zstd; then
      if ! check_command unzip; then
        echo -e "${COLOR}No ${COLOR1}unzip${COLOR} found, install it manually first${NC}"
        return
      fi

      # check if zstd is installed
      local latest_zstd_version
      latest_zstd_version=$(get_latest_release_from_github facebook/zstd)
      echo "$latest_zstd_version"
      if [ -n "$latest_zstd_version" ]; then
        echo -e "${COLOR}Installing ${COLOR1}zstd${COLOR}...${NC}"
        cd /tmp && curl --retry 5 --retry-delay 3 -LO "https://github.com/facebook/zstd/releases/download/$latest_zstd_version/zstd-$latest_zstd_version-win64.zip"
        unzip zstd-"$latest_zstd_version"-win64.zip
        mv zstd-"$latest_zstd_version"-win64/zstd.exe /usr/bin/zstd.exe
        rm -rf zstd-"$latest_zstd_version"-win64.zip zstd-"$latest_zstd_version"-win64
      else
        echo -e "${COLOR}Failed to get latest version of ${COLOR1}zstd${COLOR}, please manually download it from https://github.com/facebook/zstd/releases${NC}"
        return
      fi
    fi

    cd /
    local packages
    packages=(
      "pacman-6.1.0-8-x86_64.pkg.tar.zst"
      "pacman-mirrors-20240523-1-any.pkg.tar.zst"
      "msys2-keyring-1~20241007-1-any.pkg.tar.zst"
      "gcc-libs-13.3.0-1-x86_64.pkg.tar.zst"
      "gettext-0.22.4-1-x86_64.pkg.tar.zst"
      "libasprintf-0.22.4-1-x86_64.pkg.tar.zst"
      "libgettextpo-0.22.4-1-x86_64.pkg.tar.zst"
      "libintl-0.22.4-1-x86_64.pkg.tar.zst"
    )
    echo -e "${COLOR}Installing ${COLOR1}pacman${COLOR}...${NC}"
    for p in "${packages[@]}"; do
      echo -e "${COLOR}Installing ${COLOR1}${p}${COLOR}...${NC}"
      curl --retry 5 --retry-delay 3 -LO "https://mirror.msys2.org/msys/x86_64/$p"
      zstd -d "$p"
      tar -xvf "${p%.*}"
      rm -f "${p%.*}"
    done

    pacman-key --init
    pacman-key --populate msys2
    pacman -Syu

    # # sync metadata for pacman
    # local url
    # url=https://github.com/git-for-windows/git-sdk-64/raw/main
    # cat /etc/package-versions.txt | while read -r p v; do
    #   d="/var/lib/pacman/local/$p-$v";
    #   mkdir -p "$d"
    #   for f in desc files install mtree; do
    #     echo -e "${COLOR}Syncing ${COLOR1}${url}${d}/${f}${COLOR}...${NC}"
    #     curl --retry 5 --retry-delay 3 -sSL "$url$d/$f" -o "$d/$f";
    #   done
    # done
  fi
}

function _install_fzf() {
  if ! check_command fzf; then
    echo -e "${COLOR}Installing ${COLOR1}fzf${COLOR}...${NC}"
    local latest_fzf_version
    latest_fzf_version=$(get_latest_release_from_github junegunn/fzf)
    if [ -n "$latest_fzf_version" ]; then
      cd /usr/bin && \
      curl --retry 5 --retry-delay 3 -LO "https://github.com/junegunn/fzf/releases/download/$latest_fzf_version/fzf-${latest_fzf_version:1}-windows_amd64.zip"
      unzip "fzf-${latest_fzf_version:1}-windows_amd64.zip" fzf.exe
      rm -f "fzf-${latest_fzf_version:1}-windows_amd64.zip"
    else
      echo -e "${COLOR}Failed to get latest version of ${COLOR1}fzf${COLOR}, please manually download it from https://github.com/junegunn/fzf/releases${NC}"
    fi
  fi
}

function _install_fish() {
  if [ "$OS" = 'Windows_NT' ]; then
    _install_pacman
    if ! check_command pacman; then
      echo -e "${COLOR}Cannot find ${COLOR1}pacman${COLOR}, please install it first${NC}"
      return
    fi
    pacman -S fish --overwrite '*'

    mkdir -p "$HOME"/.config/fish
    ln -snfv "$HOME"/myConfigs/shell/fish/config.fish "$HOME"/.config/fish/config.fish

    _install_fzf

    # install lua, tmux
    pacman -Syu mingw-w64-x86_64-lua51 tmux zip make autoconf --overwrite '*'

    cd
  fi
}
