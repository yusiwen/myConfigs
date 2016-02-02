#!/bin/sh

echo "[1] Solarized"
echo "[2] Gruvbox"
echo "[3] Sourcerer"
echo "[4] Base16-Default"
echo "[5] Base16-Tomorrow"
echo "[6] Base16-Twilight"
echo -n "Choose theme[1-6]: "
read number

if echo "$number" | grep -iq "^1"; then
  echo "Setting theme to 'Solarized'..."
  ln -sf ~/myConfigs/vim/vimrc.theme.solarized ~/.vim/vimrc.theme
  ln -sf ~/myConfigs/X11/themes/solarized.xresources ~/.Xresources.theme
  ln -sf ~/myConfigs/mail/mutt/themes/solarized-dark-256.muttrc ~/.mutt/theme.muttrc
  rm -f ~/.base16rc
elif echo "$number" | grep -iq "^2"; then
  echo "Setting theme to 'Gruvbox'..."
  ln -sf ~/myConfigs/vim/vimrc.theme.gruvbox ~/.vim/vimrc.theme
  ln -sf ~/myConfigs/X11/themes/gruvbox.xresources ~/.Xresources.theme
  rm -f ~/.base16rc
elif echo "$number" | grep -iq "^3"; then
  echo "Setting theme to 'Sourcerer'..."
  ln -sf ~/myConfigs/vim/vimrc.theme.sourcerer ~/.vim/vimrc.theme
  ln -sf ~/myConfigs/X11/themes/sourcerer.xresources ~/.Xresources.theme
  rm -f ~/.base16rc
elif echo "$number" | grep -iq "^4"; then
  echo "Setting theme to 'Base16-Default'..."
  ln -sf ~/myConfigs/vim/vimrc.theme.base16-default ~/.vim/vimrc.theme
  ln -sf ~/myConfigs/X11/themes/base16-default.dark.256.xresources ~/.Xresources.theme
  ln -sf ~/myConfigs/X11/themes/base16-default.dark.sh ~/.base16rc
  ln -sf ~/myConfigs/mail/mutt/themes/base16-256.muttrc ~/.mutt/theme.muttrc
elif echo "$number" | grep -iq "^5"; then
  echo "Setting theme to 'Base16-Tomorrow'..."
  ln -sf ~/myConfigs/vim/vimrc.theme.base16-tomorrow ~/.vim/vimrc.theme
  ln -sf ~/myConfigs/X11/themes/base16-tomorrow.dark.256.xresources ~/.Xresources.theme
  ln -sf ~/myConfigs/X11/themes/base16-tomorrow.dark.sh ~/.base16rc
elif echo "$number" | grep -iq "^6"; then
  echo "Setting theme to 'Base16-Twilight'..."
  ln -sf ~/myConfigs/vim/vimrc.theme.base16-twilight ~/.vim/vimrc.theme
  ln -sf ~/myConfigs/X11/themes/base16-twilight.dark.256.xresources ~/.Xresources.theme
  ln -sf ~/myConfigs/X11/themes/base16-twilight.dark.sh ~/.base16rc
else
  echo "Nahh!"
  exit
fi

echo "Reloading xresources..."
xrdb -load ~/.Xresources

echo "Done."
