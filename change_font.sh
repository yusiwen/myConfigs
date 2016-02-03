#!/bin/sh

X11_FONT_DIR="$HOME/myConfigs/X11/fonts"
X11_FONT_FILE="$HOME/.Xresources.font"

echo "[1] Input Mono Compressed"
echo "[2] Iosevka"
echo "[3] Iosevka Slab"
echo -n "Choose font: "
read number

if echo "$number" | grep -iq "^1"; then
  echo "Setting font to 'Input Mono Compressed'..."
  ln -sfnv $X11_FONT_DIR/input-mono-compressed.xresources $X11_FONT_FILE
elif echo "$number" | grep -iq "^2"; then
  echo "Setting font to 'Iosevka'..."
  ln -sfnv $X11_FONT_DIR/iosevka.xresources $X11_FONT_FILE
elif echo "$number" | grep -iq "^3"; then
  echo "Setting font to 'Iosevka Slab'..."
  ln -sfnv $X11_FONT_DIR/iosevka-slab.xresources $X11_FONT_FILE
else
  echo "Nahh!"
  exit
fi

echo "Reloading xresources..."
xrdb -load ~/.Xresources

echo "Done."
