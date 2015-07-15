i3
==

Configurations for i3-wm.

Installation
------------

1. Installing from official repository.

  Debian repository:

  Add `deb http://build.i3wm.org/debian/sid sid main` to `/etc/apt/sources.list`.

  Then,
  ```sh
  $ sudo apt-get update
  $ sudo apt-get --allow-unauthenticated install i3-autobuild-keyring
  $ sudo apt-get update
  $ sudo apt-get install i3
  ```

  Or, Ubuntu repository(*recommended*):
  ```sh
  $ sudo echo "deb http://debian.sur5r.net/i3/ $(lsb_release -c -s) universe" >> /etc/apt/sources.list
  $ sudo apt-get update
  $ sudo apt-get --allow-unauthenticated install sur5r-keyring
  $ sudo apt-get update
  $ sudo apt-get install i3
  ```

  For better session management, using ConsoleKit to start i3wm:
  ```sh
  $ sudo cp ~/myConfigs/i3/i3.desktop /usr/share/xsessions/i3.desktop
  # or just edit following line to /usr/share/xsessions/i3.desktop
  # Exec=ck-launch-session dbus-launch --sh-syntax --exit-with-session i3
  ```

1. Install `i3blocks`.

  For better i3bar status informations.
  ```sh
  $ sudo apt-get install i3blocks
  ```

1. (Optional) Remove unity.
  ```sh
  $ sudo apt-get remove nautilus gnome-power-manager compiz compiz-gnome unity unity-* unity8* hud zeitgeist zeitgeist-core python-zeitgeist libzeitgeist* activity-log-manager-common gnome-control-center gnome-screenshot
  ```

1. (Optional) Cleanup.
  ```sh
  $ sudo dpkg --list |grep "^rc" | cut -d " " -f 3 | xargs sudo dpkg --purge
  ```

Configuration
-------------

1. Make links of i3-wm config files.
  ```sh
  $ ln -sf ~/myConfigs/i3/_config ~/.i3/_config
  $ ln -sf ~/myConfigs/i3/i3blocks/i3blocks.conf ~/.i3/i3blocks.conf
  $ ln -sf ~/myConfigs/i3/i3bang/i3bang.rb ~/bin/i3bang
  ```

  Use `i3bang` to generate the config file in `~/.i3i/`

1. (Optional) Change i3-wm session icon used by LightDM. Only applicable for unity-greeter.
  ```sh
  $ cd /usr/share/unity-greeter
  $ sudo cp /home/yusiwen/myConfigs/i3/xsessioins/i3.png custom_i3_badge.png
  ```

1. (Optional) Set lock screen when restoring from suspension using i3lock.
   see `pm-utils` and `xautolock`.
  ```sh
  $ cd /etc/pm/sleep.d
  $ sudo cp /home/yusiwen/myConfigs/i3/i3lock.pm 66_i3lock
  ```

1. (Optional) Add a custom i3 session in lightdm/gdm:
  ```sh
  $ sudo cp xsessions/i3.desktop /usr/share/xsessions
  ```

1. Config `dunst`

  `dunstrc` should be copied to `~/.config/dunst/` or linked to that folder.
  ```sh
  $ ln -sf ~/myConfigs/i3/dunst/dunstrc ~/.config/dunst/dunstrc
  ```

1. Make thunar as default file manager.
  ```sh
  $ vim ./local/share/applications/thunar.desktop
  ```

  paste content as below:
  ```text
  [Desktop Entry]
  Name=Open Folder
  TryExec=thunar
  Exec=thunar %U
  NoDisplay=true
  Terminal=false
  Icon=folder-open
  StartupNotify=true
  Type=Application
  MimeType=x-directory/gnome-default-handler;x-directory/normal;inode/directory;application/x-gnome-saved-search;
  ```

  add content below to ./local/share/applications/mimeapps.list

  ```text
  inode/directory=thunar.desktop
  x-directory/normal=thunar.desktop
  ```

`gnome-keyring-daemon` Problems
-----------------------------

When using unity-greeter with LightDM, there may be some PAM problem causing gnome-keyring-daemon not started after user login. By replacing unity-greeter with lightdm-gtk-greeter, the problem is gone.
