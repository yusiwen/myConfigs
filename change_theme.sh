#!/bin/sh

VIM_THEME_DIR="$HOME/myConfigs/vim"
VIM_THEME_FILE="$HOME/.vim/vimrc.theme"

X11_THEME_DIR="$HOME/myConfigs/X11/themes"
X11_THEME_FILE="$HOME/.Xresources.theme"
BASE16_THEME_SHELL="$HOME/.base16rc"

MUTT_THEME_DIR="$HOME/myConfigs/mail/mutt/themes"
MUTT_THEME_FILE="$HOME/.mutt/theme.muttrc"

echo "[1] Solarized"
echo "[2] Gruvbox"
echo "[3] Sourcerer"
echo "[4] Base16-Default"
echo "[5] Base16-Bespin"
echo "[6] Base16-Tomorrow"
echo "[7] Base16-Twilight"
echo -n "Choose theme[1-7]: "
read number

if echo "$number" | grep -iq "^1"; then
  echo "Setting theme to 'Solarized'..."
  ln -sf $VIM_THEME_DIR/vimrc.theme.solarized $VIM_THEME_FILE
  ln -sf $X11_THEME_DIR/solarized.xresources $X11_THEME_FILE
  ln -sf $MUTT_THEME_DIR/solarized-dark-256.muttrc $MUTT_THEME_FILE
  rm -f $BASE16_THEME_SHELL
elif echo "$number" | grep -iq "^2"; then
  echo "Setting theme to 'Gruvbox'..."
  ln -sf $VIM_THEME_DIR/vimrc.theme.gruvbox $VIM_THEME_FILE
  ln -sf $X11_THEME_DIR/gruvbox.xresources $X11_THEME_FILE
  rm -f $BASE16_THEME_SHELL
elif echo "$number" | grep -iq "^3"; then
  echo "Setting theme to 'Sourcerer'..."
  ln -sf $VIM_THEME_DIR/vimrc.theme.sourcerer $VIM_THEME_FILE
  ln -sf $X11_THEME_DIR/sourcerer.xresources $X11_THEME_FILE
  rm -f $BASE16_THEME_SHELL
elif echo "$number" | grep -iq "^4"; then
  echo "Setting theme to 'Base16-Default'..."
  ln -sf $VIM_THEME_DIR/vimrc.theme.base16-default $VIM_THEME_FILE
  ln -sf $X11_THEME_DIR/base16-default.dark.256.xresources $X11_THEME_FILE
  ln -sf $X11_THEME_DIR/base16-default.dark.sh $BASE16_THEME_SHELL
  ln -sf $MUTT_THEME_DIR/base16-256.muttrc $MUTT_THEME_FILE
elif echo "$number" | grep -iq "^5"; then
  echo "Setting theme to 'Base16-Bespin'..."
  ln -sf $VIM_THEME_DIR/vimrc.theme.base16-bespin $VIM_THEME_FILE
  ln -sf $X11_THEME_DIR/base16-bespin.dark.256.xresources $X11_THEME_FILE
  ln -sf $X11_THEME_DIR/base16-bespin.dark.sh $BASE16_THEME_SHELL
elif echo "$number" | grep -iq "^6"; then
  echo "Setting theme to 'Base16-Tomorrow'..."
  ln -sf $VIM_THEME_DIR/vimrc.theme.base16-tomorrow $VIM_THEME_FILE
  ln -sf $X11_THEME_DIR/base16-tomorrow.dark.256.xresources $X11_THEME_FILE
  ln -sf $X11_THEME_DIR/base16-tomorrow.dark.sh $BASE16_THEME_SHELL
elif echo "$number" | grep -iq "^7"; then
  echo "Setting theme to 'Base16-Twilight'..."
  ln -sf $VIM_THEME_DIR/vimrc.theme.base16-twilight $VIM_THEME_FILE
  ln -sf $X11_THEME_DIR/base16-twilight.dark.256.xresources $X11_THEME_FILE
  ln -sf $X11_THEME_DIR/base16-twilight.dark.sh $BASE16_THEME_SHELL
else
  echo "Nahh!"
  exit
fi

echo "Reloading xresources..."
xrdb -load ~/.Xresources

echo "Done."
