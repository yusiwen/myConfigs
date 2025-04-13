#!/usr/bin/env bash

function _install_git() { # {{{
  if [ "$OS" = 'Linux' ]; then
    if [ "$DISTRO" = 'Ubuntu' ] || [ "$DISTRO" = 'Debian' ]; then
      # install git if not exist
      if ! check_command git; then
        if [ "$DISTRO" = 'Ubuntu' ]; then
          GIT_PPA=/etc/apt/sources.list.d/git-core-ubuntu-ppa-$CODENAME.list
          if [ ! -e "$GIT_PPA" ]; then
            echo -e "${COLOR}Add ${COLOR1}git-core${COLOR} ppa...${NC}"
            gum spin --show-error --title "Adding ppa:git-core/ppa..." -- \
              bash -c "$SUDO apt-add-repository -y ppa:git-core/ppa"

            if [ -n "$MIRRORS" ] && [ "$MIRRORS" -eq 1 ]; then
              # Replace official launchpad address with reverse proxy from USTC
              $SUDO sed -i "s/http:\/\/ppa\.launchpad\.net/https:\/\/launchpad\.proxy\.ustclug\.org/g" "$GIT_PPA"
            fi

            echo -e "${COLOR}Add ${COLOR1}git-core${COLOR} ppa...OK${NC}"
            gum spin --show-error --title "Updating apt repository..." -- \
              bash -c "$SUDO apt-get -qq update"
            gum spin --show-error --title "Upgrading system..." -- \
              bash -c "$SUDO env NEEDRESTART_MODE=a apt-get -qq full-upgrade -y"
          else
            echo -e "${COLOR1}ppa:git-core/ppa${COLOR} was found.${NC}"
          fi
        fi
        echo -e "${COLOR}Installing ${COLOR1}git-core${COLOR}...${NC}"
        gum spin --show-error --title "Installing git-core..." -- \
          bash -c "$SUDO env NEEDRESTART_MODE=a apt-get -qq install -y git"
        echo -e "${COLOR}Installing ${COLOR1}git-core${COLOR}...OK${NC}"
      else
        echo -e "${COLOR1}git${COLOR} was found at '$(which git)'.${NC}"
      fi

      if ! check_command git-credential-manager && [ ! -e /usr/local/bin/git-credential-manager ] && [ "$ARCH" = 'amd64' ]; then
        echo -e "${COLOR}Installing ${COLOR1}git-credential-manager${COLOR}...${NC}"
        local gcm_latest_version
        gcm_latest_version=$(get_latest_release_from_github 'git-ecosystem/git-credential-manager')
        curl -sL "https://github.com/git-ecosystem/git-credential-manager/releases/download/v$gcm_latest_version/gcm-linux_$ARCH.$gcm_latest_version.deb" -o /tmp/gcm.deb
        gum spin --show-error --title "Installing git-credential-manager..." -- \
          bash -c "$SUDO dpkg --install /tmp/gcm.deb && rm -f /tmp/gcm.deb"
      else
        echo -e "${COLOR1}git-credential-manager${COLOR} was found at '/usr/local/bin/git-credential-manager'.${NC}"
      fi
      if [ "$(git config --global --get credential.helper)" != '/usr/local/bin/git-credential-manager' ] && [ "$ARCH" = 'amd64' ]; then
        /usr/local/bin/git-credential-manager configure
      fi

      if ! check_command tig; then
        echo -e "${COLOR}Installing ${COLOR1}tig${COLOR}...${NC}"
        gum spin --show-error --title "Installing tig..." -- \
          bash -c "$SUDO env NEEDRESTART_MODE=a apt-get -qq install -y tig"
        echo -e "${COLOR}Installing ${COLOR1}tig${COLOR}...OK${NC}"
      else
        echo -e "${COLOR1}tig${COLOR} was found at '$(which tig)'.${NC}"
      fi
    elif [ "$DISTRO" = 'Manjaro' ]; then
      # Manjaro has git installed already
      if ! check_command tig; then
        echo -e "${COLOR}Installing ${COLOR1}tig${COLOR}...${NC}"
        yay -S tig
        echo -e "${COLOR}Installing ${COLOR1}tig${COLOR}...OK${NC}"
      else
        echo -e "${COLOR1}tig${COLOR} was found at '$(which tig)'.${NC}"
      fi
    elif [ "$DISTRO" = 'CentOS' ]; then
      if [ "$OS_VERSION" = '"7"' ]; then
        PACKAGE=$(yum list installed | grep -c ^ius-release.noarch)
        if [ "$PACKAGE" = 0 ]; then
          $SUDO yum -y install https://centos7.iuscommunity.org/ius-release.rpm
        fi

        $SUDO yum -y install git2u-all
      else
        $SUDO yum -y install git
      fi
    elif [ "$DISTRO" = 'OpenWrt' ]; then
      if ! check_command git; then
        $SUDO opkg update && opkg install git
      fi
    else
      echo -e "${COLOR}Distro ${COLOR1}$DISTRO${COLOR} not supported yet${NC}"
      return
    fi
  elif [ "$OS" = 'Darwin' ]; then
    brew install git
  elif [ "$OS" = 'Windows_NT' ]; then
    if ! check_command git; then
      echo -e "${COLOR}Please download git-for-windows from https://git-scm.com/ and install it manually${NC}"
      return
    fi
  else
    echo -e "${COLOR}OS not supported${NC}"
    return
  fi

  echo -e "${COLOR}Configuring...${NC}"
  echo -e "${COLOR}Setting 'user.email' to 'yusiwen@gmail.com'${NC}"
  git config --global user.email "yusiwen@gmail.com"

  echo -e "${COLOR}Setting 'user.name' to 'Siwen Yu'${NC}"
  git config --global user.name "Siwen Yu"

  echo -e "${COLOR}Setting line feed behavior...${NC}"
  if [ "$OS" = "Windows_NT" ]; then
    # On Windows, commit with LF and checkout with CRLF
    git config --global core.autocrlf true
  else
    # On Linux or Mac, commit with LF and no change on checkout
    git config --global core.autocrlf input
  fi
  # Turn on warning on convert EOL failure
  git config --global core.safecrlf warn

  echo -e "${COLOR}Setting misc...${NC}"
  git config --global core.editor vim
  if [ "$OS" = 'Windows_NT' ]; then
    if [ -n "$APP_HOME" ]; then
      git config --global core.editor "$APP_HOME/GitExtensions/GitExtensions.exe fileeditor"
    fi
  fi
  git config --global pull.rebase true
  git config --global fetch.prune true
  git config --global merge.tool vimdiff
  git config --global merge.conflictstyle diff3
  git config --global mergetool.prompt false
  git config --global diff.colorMoved zebra

  # Global ignore files
  cat <<EOF | tee "$HOME"/.gitignore >/dev/null
# Global ignore config for Git
#   git config --global core.excludesfile $HOME/.gitignore
#
# Siwen Yu (yusiwen@gmail.com)

# Ignore all ctags files
target/
.project
.classpath
.factorypath
.settings/
.idea/
.vscode/
node_modules/
*.iml
EOF
  git config --global core.excludesfile "$HOME"/.gitignore

  if check_command delta; then
    git config --global core.pager "delta --line-numbers"
    git config --global interactive.diffFilter "delta --color-only --line-numbers"
    git config --global delta.navigate true
    git config --global delta.features decorations
    git config --global delta.interactive.keep-plus-minus-markers false
    git config --global delta.decorations.commit-decoration-style "blue ol"
    git config --global delta.decorations.commit-style raw
    git config --global delta.decorations.file-style omit
    git config --global delta.decorations.hunk-header-decoration-style "blue box"
    git config --global delta.decorations.hunk-header-file-style red
    git config --global delta.decorations.hunk-header-line-number-style "#067a00"
    git config --global delta.decorations.hunk-header-style "file line-number syntax"
  elif check_command diff-so-fancy; then
    git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
  fi

  if [ "$DISTRO" = 'OpenWrt' ]; then
    if ! check_command dropbearkey; then
      $SUDO opkg install dropbear
    fi
    if [ ! -e "$HOME/.ssh" ]; then
      mkdir -p "$HOME/.ssh"
    fi
    if [ -e "$HOME"/.ssh/id_dropbear.pub ]; then
      echo -e "${COLOR1}.ssh/id_dropbear.pub${COLOR} was found, please add it to GitHub, BitBucket, GitLab and Gitea${NC}"
      cat "$HOME"/.ssh/id_dropbear.pub
    else
      dropbearkey -t rsa -s 4096 -f "$HOME/.ssh/id_dropbear" | grep "^ssh-rsa " > "$HOME"/.ssh/id_dropbear.pub
      echo -e "${COLOR}Please add it to GitHub, BitBucket, Gitlab and Gitea${NC}"
    fi
  else
    if [ -e "$HOME"/.ssh/id_rsa.pub ]; then
      echo -e "${COLOR1}.ssh/id_rsa.pub${COLOR} was found, please add it to GitHub, BitBucket, GitLab and Gitea${NC}"
      cat "$HOME"/.ssh/id_rsa.pub
    else
      echo -e "${COLOR1}.ssh/id_rsa.pub${COLOR} was not found, generating it now...${NC}"
      ssh-keygen -t rsa -N "" -C "default key" -f "$HOME"/.ssh/id_rsa
      echo -e "${COLOR}Please add it to GitHub, BitBucket, Gitlab and Gitea${NC}"
      cat "$HOME"/.ssh/id_rsa.pub
    fi
  fi

  echo -e "${COLOR}You may need 'commitizen', 'cz-customizable' to run git commit conventions, run './install.sh node' to setup.${NC}"

  if [ ! -d "$HOME/myConfigs/.git" ]; then
    cd "$HOME"/myConfigs || exit
    git init
    git remote add origin "https://github.com/yusiwen/myConfigs.git"
    git add .
    git remote update
    git checkout master
  fi
} # }}}