#!/usr/bin/env bash

function _install_ruby() { # {{{
  if [ "$OS" = 'Linux' ]; then
    if [ "$DISTRO" = 'Ubuntu' ] || [ "$DISTRO" = 'Debian' ]; then
      if ! check_command ruby; then
        gum spin --show-error --title "Installing ruby..." -- \
          bash -c "$SUDO env NEEDRESTART_MODE=a DEBIAN_FRONTEND=noninteractive apt-get -qq install -y ruby-full curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev libffi-dev"
        echo -e "${COLOR}Installing ${COLOR1}Ruby${COLOR}...OK${NC}"
      else
        echo -e "${COLOR1}ruby${COLOR} was found.${NC}"
        set +e
        PACKAGE=$(dpkg -l | grep -c ruby-full)
        set -e
        if [ "$PACKAGE" -eq 0 ]; then
          gum spin --show-error --title "Installing ruby-full..." -- \
            bash -c "$SUDO env NEEDRESTART_MODE=a DEBIAN_FRONTEND=noninteractive apt-get -qq install -y ruby-full"
        fi
      fi
    elif [ "$DISTRO" = 'Manjaro' ]; then
      if ! check_command ruby; then
        echo -e "${COLOR}Installing ${COLOR1}Ruby${COLOR}...${NC}"
        yay -S ruby
        echo -e "${COLOR}Installing ${COLOR1}Ruby${COLOR}...OK${NC}"
      else
        echo -e "${COLOR1}ruby${COLOR} was found.${NC}"
      fi
    else
      echo -e "${COLOR}Distro ${COLOR1}$DISTRO${COLOR} not supported yet${NC}"
      return
    fi
  elif [ "$OS" = 'Darwin' ]; then
    if ! check_command ruby; then
      brew install ruby
    else
      echo -e "${COLOR1}ruby${COLOR} was found.${NC}"
    fi
  else
    echo -e "${COLOR}OS not supported${NC}"
    return
  fi

  echo -e "${COLOR}Replace official repo with Ruby-China mirror...${NC}"
  gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/
  gem sources -l
  echo -e "${COLOR}Replace official repo with Ruby-China mirror...OK${NC}"

  PATH="$(ruby -e 'puts Gem.user_dir')/bin:$PATH"
  export PATH
  if ! check_command bundle; then
    echo -e "${COLOR}Installing bundler...${NC}"
    gem install --user-install bundler -v 2.4.22
    echo -e "${COLOR}Installing bundler...OK${NC}"
  else
    echo -e "${COLOR1}bundler${COLOR} was found.${NC}"
  fi

  echo -e "${COLOR}Configurate bundler to use Ruby-China mirror...${NC}"
  bundle config mirror.https://rubygems.org https://gems.ruby-china.com
  echo -e "${COLOR}Configurate bundler to use Ruby-China mirror...OK${NC}"
} # }}}