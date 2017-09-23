#!/bin/sh

X11_FONT_DIR="$HOME/myConfigs/X11/fonts"
X11_FONT_FILE="$HOME/.Xresources.font"

echo "[1] Input Mono Compressed"
echo "[2] Iosevka"
echo "[3] Iosevka Slab"
echo "[4] Fira Code"
echo -n "Choose font[1]: "
read number

if [ -z $number ]; then
  number='1'
fi

if echo "$number" | grep -iq "^1"; then
  echo "Setting font to 'Input Mono Compressed'..."
  ln -sfnv $X11_FONT_DIR/input-mono-compressed.xresources $X11_FONT_FILE
elif echo "$number" | grep -iq "^2"; then
  echo "Setting font to 'Iosevka'..."
  ln -sfnv $X11_FONT_DIR/iosevka.xresources $X11_FONT_FILE
elif echo "$number" | grep -iq "^3"; then
  echo "Setting font to 'Iosevka Slab'..."
  ln -sfnv $X11_FONT_DIR/iosevka-slab.xresources $X11_FONT_FILE
elif echo "$number" | grep -iq "^4"; then
  echo "Setting font to 'Fira Code'..."
  ln -sfnv $X11_FONT_DIR/firacode.xresources $X11_FONT_FILE
else
  echo "Nahh!"
  exit
fi

echo "Reloading xresources..."
xrdb -load ~/.Xresources

echo "Done."
