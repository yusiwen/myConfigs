#!/bin/sh

if [ $OS != 'Linux' ]; then
  echo "Only Linux is suppported!"
  exit 0
fi

X11_FONT_DIR="$HOME/myConfigs/X11/themes/font-config"
X11_FONT_FILE="$HOME/.Xresources.font"
X11_FONT_INSTALLATION_DIR="$HOME/.local/share/fonts"
FONT_ZIP_DIR="$HOME/myConfigs/X11/fonts"

echo "Checking WenQuanYi Micro Hei Mono fonts..."
if [ $DISTRO = 'Ubuntu' ]; then
  if ! type 7z >/dev/null 2>&1; then
    sudo apt install p7zip-full
  fi
  PACKAGE=$(dpkg -l | grep fonts-wqy-microhei | cut -d ' ' -f 3 | grep ^fonts-wqy-microhei$ | wc -l)
  if [ $PACKAGE -eq 0 ]; then
    echo "Installing WenQuanYi Micro Hei Mono fonts..."
    sudo apt install -y fonts-wqy-microhei
  fi
elif [ $DISTRO = 'ManjaroLinux' ]; then
  PACKAGE=$(pacman -Q | grep wqy-microhei | wc -l)
  if [ $PACKAGE -eq 0 ]; then
    echo "Installing WenQuanYi Micro Hei Mono fonts..."
    sudo pacman -S wqy-microhei
  fi
fi

echo "[1] Input Mono Compressed"
echo "[2] Iosevka"
echo "[3] Iosevka Slab"
echo "[4] Fira Code"
echo "[0] Default(Ubuntu Mono + WenQuanYi Mirco Hei Mono)"
echo -n "Choose font[0]: "
read number

if [ -z $number ]; then
  number='0'
fi

if echo "$number" | grep -iq "^1"; then
  RESULT=$(fc-list | grep 'Input Mono Compressed' | wc -l)
  if [ $RESULT -eq 0 ]; then
    echo "Installing font: Input Mono Compressed ..."
    TARGET_DIR=$X11_FONT_INSTALLATION_DIR/truetype/input-mono-compressed
    mkdir -p $TARGET_DIR
    7z x $FONT_ZIP_DIR/Input-Mono-Compressed.7z -o$TARGET_DIR
    fc-cache -fv
  fi
  echo "Setting font to 'Input Mono Compressed'..."
  ln -sfnv $X11_FONT_DIR/input-mono-compressed.xresources $X11_FONT_FILE
elif echo "$number" | grep -iq "^2"; then
  RESULT=$(fc-list | grep "\/iosevka\/" | wc -l)
  if [ $RESULT -eq 0 ]; then
    echo "Installing font: Iosevka ..."
    TARGET_DIR=$X11_FONT_INSTALLATION_DIR/truetype/iosevka
    mkdir -p $TARGET_DIR
    7z x $FONT_ZIP_DIR/iosevka.7z -o$TARGET_DIR
    fc-cache -fv
  fi
  echo "Setting font to 'Iosevka'..."
  ln -sfnv $X11_FONT_DIR/iosevka.xresources $X11_FONT_FILE
elif echo "$number" | grep -iq "^3"; then
  RESULT=$(fc-list | grep "\/iosevka-slab\/" | wc -l)
  if [ $RESULT -eq 0 ]; then
    echo "Installing font: Iosevka Slab..."
    TARGET_DIR=$X11_FONT_INSTALLATION_DIR/truetype/iosevka-slab
    mkdir -p $TARGET_DIR
    7z x $FONT_ZIP_DIR/iosevka-slab.7z -o$TARGET_DIR
    fc-cache -fv
  fi
  echo "Setting font to 'Iosevka Slab'..."
  ln -sfnv $X11_FONT_DIR/iosevka-slab.xresources $X11_FONT_FILE
elif echo "$number" | grep -iq "^4"; then
  RESULT=$(fc-list | grep 'FiraCode' | wc -l)
  if [ $RESULT -eq 0 ]; then
    echo "Installing font: FiraCode..."
    TARGET_DIR=$X11_FONT_INSTALLATION_DIR/truetype/firacode
    mkdir -p $TARGET_DIR
    7z x $FONT_ZIP_DIR/FiraCode.7z -o$TARGET_DIR
    fc-cache -fv
  fi
  echo "Setting font to 'Fira Code'..."
  ln -sfnv $X11_FONT_DIR/firacode.xresources $X11_FONT_FILE
else
  echo "Use default settings..."
  ln -sfnv $X11_FONT_DIR/default.xresources $X11_FONT_FILE
  exit
fi

echo "Reloading xresources..."
xrdb -merge ~/.Xresources
echo "Restart urxvt or X session to take effect"

echo "Done."
