#!/bin/sh

VIM_THEME_DIR="$HOME/myConfigs/vim"
VIM_THEME_FILE="$HOME/.vim/vimrc.theme"

X11_THEME_DIR="$HOME/myConfigs/X11/themes"
X11_THEME_FILE="$HOME/.Xresources.theme"
BASE16_THEME_SHELL="$HOME/.base16rc"

MUTT_THEME_DIR="$HOME/myConfigs/mail/mutt/themes"
MUTT_THEME_FILE="$HOME/.mutt/theme.muttrc"

GREP="grep -q"

change_theme()
{
  if [ $(uname) = 'Linux' ]; then
    if [ ! -e $HOME/.Xresources.font ]; then
      $HOME/myConfigs/change_font.sh
    fi

    echo "Setting theme to '$1'..."

    ln -sfnv $VIM_THEME_DIR/vimrc.theme.$1 $VIM_THEME_FILE

    BASE16=
    if echo "$1" | $GREP "^base16"; then
      ln -sfnv $X11_THEME_DIR/$1.dark.256.xresources $X11_THEME_FILE
      ln -sfnv $X11_THEME_DIR/$1.dark.sh $BASE16_THEME_SHELL
      BASE16=".dark.256"
    else
      ln -sfnv $X11_THEME_DIR/$1.xresources $X11_THEME_FILE
      rm -f $BASE16_THEME_SHELL
    fi

    # Check if mutt is installed or not
    PACKAGE=$(dpkg -l | grep mutt)
    if [ ! -z "$PACKAGE" ]; then
      ln -sfnv $MUTT_THEME_DIR/$1$BASE16.muttrc $MUTT_THEME_FILE
    fi

    echo "Reloading xresources..."
    xrdb -load ~/.Xresources
  else
    echo 'Only Linux is supported.'
  fi
}

echo "[1] Gruvbox"
echo "[2] Jellybeans"
echo "[3] Sourcerer"
echo "[4] Base16-Default"
echo "[5] Base16-Atelier Seaside"
echo "[6] Base16-Atelier Sulphurpool"
echo "[7] Base16-Bespin"
echo "[8] Base16-Solarized Dark"
echo "[9] Base16-Tomorrow"
echo "[0] Base16-Twilight"
echo "[a] Dracula"
echo -n "Choose theme[3]: "
read number

if [ -z $number ]; then
  number='3'
fi

if echo "$number" | grep -iq "^1"; then
  change_theme gruvbox
elif echo "$number" | grep -iq "^2"; then
  change_theme jellybeans
elif echo "$number" | grep -iq "^3"; then
  change_theme sourcerer
elif echo "$number" | grep -iq "^4"; then
  change_theme base16-default
elif echo "$number" | grep -iq "^5"; then
  change_theme base16-atelierseaside
elif echo "$number" | grep -iq "^6"; then
  change_theme base16-ateliersulphurpool
elif echo "$number" | grep -iq "^7"; then
  change_theme base16-bespin
elif echo "$number" | grep -iq "^8"; then
  change_theme base16-solarized
elif echo "$number" | grep -iq "^9"; then
  change_theme base16-tomorrow
elif echo "$number" | grep -iq "^0"; then
  change_theme base16-twilight
elif echo "$number" | grep -iq "^a"; then
  change_theme dracula
else
  echo "Nahh!"
  exit
fi

echo "Done."
