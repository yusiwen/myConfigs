#!/bin/sh

if [ ! -e $HOME/.Xresources.font ]; then
  $HOME/myConfigs/change_font.sh
fi

VIM_THEME_DIR="$HOME/myConfigs/vim"
VIM_THEME_FILE="$HOME/.vim/vimrc.theme"

X11_THEME_DIR="$HOME/myConfigs/X11/themes"
X11_THEME_FILE="$HOME/.Xresources.theme"
BASE16_THEME_SHELL="$HOME/.base16rc"

MUTT_THEME_DIR="$HOME/myConfigs/mail/mutt/themes"
MUTT_THEME_FILE="$HOME/.mutt/theme.muttrc"

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
echo -n "Choose theme[3]: "
read number

if [ -z $number ]; then
  number='3'
fi

if echo "$number" | grep -iq "^1"; then
  echo "Setting theme to 'Gruvbox'..."
  ln -sfnv $VIM_THEME_DIR/vimrc.theme.gruvbox $VIM_THEME_FILE
  ln -sfnv $X11_THEME_DIR/gruvbox.xresources $X11_THEME_FILE
  rm -f $BASE16_THEME_SHELL
  ln -sfnv $MUTT_THEME_DIR/gruvbox.muttrc $MUTT_THEME_FILE
elif echo "$number" | grep -iq "^2"; then
  echo "Setting theme to 'Jellybeans'..."
  ln -sfnv $VIM_THEME_DIR/vimrc.theme.jellybeans $VIM_THEME_FILE
  ln -sfnv $X11_THEME_DIR/jellybeans.xresources $X11_THEME_FILE
  rm -f $BASE16_THEME_SHELL
  ln -sfnv $MUTT_THEME_DIR/jellybeans.muttrc $MUTT_THEME_FILE
elif echo "$number" | grep -iq "^3"; then
  echo "Setting theme to 'Sourcerer'..."
  ln -sfnv $VIM_THEME_DIR/vimrc.theme.sourcerer $VIM_THEME_FILE
  ln -sfnv $X11_THEME_DIR/sourcerer.xresources $X11_THEME_FILE
  rm -f $BASE16_THEME_SHELL
  ln -sfnv $MUTT_THEME_DIR/sourcerer.muttrc $MUTT_THEME_FILE
elif echo "$number" | grep -iq "^4"; then
  echo "Setting theme to 'Base16-Default'..."
  ln -sfnv $VIM_THEME_DIR/vimrc.theme.base16-default $VIM_THEME_FILE
  ln -sfnv $X11_THEME_DIR/base16-default.dark.256.xresources $X11_THEME_FILE
  ln -sfnv $X11_THEME_DIR/base16-default.dark.sh $BASE16_THEME_SHELL
  ln -sfnv $MUTT_THEME_DIR/base16-default.dark.256.muttrc $MUTT_THEME_FILE
elif echo "$number" | grep -iq "^5"; then
  echo "Setting theme to 'Base16-Atelier Seaside'..."
  ln -sfnv $VIM_THEME_DIR/vimrc.theme.base16-atelierseaside $VIM_THEME_FILE
  ln -sfnv $X11_THEME_DIR/base16-atelierseaside.dark.256.xresources $X11_THEME_FILE
  ln -sfnv $X11_THEME_DIR/base16-atelierseaside.dark.sh $BASE16_THEME_SHELL
  ln -sfnv $MUTT_THEME_DIR/base16-atelierseaside.dark.256.muttrc $MUTT_THEME_FILE
elif echo "$number" | grep -iq "^6"; then
  echo "Setting theme to 'Base16-Atelier Sulphurpool'..."
  ln -sfnv $VIM_THEME_DIR/vimrc.theme.base16-ateliersulphurpool $VIM_THEME_FILE
  ln -sfnv $X11_THEME_DIR/base16-ateliersulphurpool.dark.256.xresources $X11_THEME_FILE
  ln -sfnv $X11_THEME_DIR/base16-ateliersulphurpool.dark.sh $BASE16_THEME_SHELL
  ln -sfnv $MUTT_THEME_DIR/base16-ateliersulphurpool.dark.256.muttrc $MUTT_THEME_FILE
elif echo "$number" | grep -iq "^7"; then
  echo "Setting theme to 'Base16-Bespin'..."
  ln -sfnv $VIM_THEME_DIR/vimrc.theme.base16-bespin $VIM_THEME_FILE
  ln -sfnv $X11_THEME_DIR/base16-bespin.dark.256.xresources $X11_THEME_FILE
  ln -sfnv $X11_THEME_DIR/base16-bespin.dark.sh $BASE16_THEME_SHELL
  ln -sfnv $MUTT_THEME_DIR/base16-bespin.dark.256.muttrc $MUTT_THEME_FILE
elif echo "$number" | grep -iq "^8"; then
  echo "Setting theme to 'Base16-Solarized Dark'..."
  ln -sfnv $VIM_THEME_DIR/vimrc.theme.base16-solarized $VIM_THEME_FILE
  ln -sfnv $X11_THEME_DIR/base16-solarized.dark.256.xresources $X11_THEME_FILE
  ln -sfnv $X11_THEME_DIR/base16-solarized.dark.sh $BASE16_THEME_SHELL
  ln -sfnv $MUTT_THEME_DIR/base16-solarized.dark.256.muttrc $MUTT_THEME_FILE
elif echo "$number" | grep -iq "^9"; then
  echo "Setting theme to 'Base16-Tomorrow'..."
  ln -sfnv $VIM_THEME_DIR/vimrc.theme.base16-tomorrow $VIM_THEME_FILE
  ln -sfnv $X11_THEME_DIR/base16-tomorrow.dark.256.xresources $X11_THEME_FILE
  ln -sfnv $X11_THEME_DIR/base16-tomorrow.dark.sh $BASE16_THEME_SHELL
  ln -sfnv $MUTT_THEME_DIR/base16-tomorrow.dark.256.muttrc $MUTT_THEME_FILE
elif echo "$number" | grep -iq "^0"; then
  echo "Setting theme to 'Base16-Twilight'..."
  ln -sfnv $VIM_THEME_DIR/vimrc.theme.base16-twilight $VIM_THEME_FILE
  ln -sfnv $X11_THEME_DIR/base16-twilight.dark.256.xresources $X11_THEME_FILE
  ln -sfnv $X11_THEME_DIR/base16-twilight.dark.sh $BASE16_THEME_SHELL
  ln -sfnv $MUTT_THEME_DIR/base16-twilight.dark.256.muttrc $MUTT_THEME_FILE
else
  echo "Nahh!"
  exit
fi

echo "Reloading xresources..."
xrdb -load ~/.Xresources

echo "Done."
