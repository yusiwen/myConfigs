configs
=======

Installation
------------

1. Add `deb http://build.i3wm.org/debian/sid sid main` to `/etc/apt/sources.list`.

2. Install `libxcb-cursor0_0.1.1-1_amd64.deb` manually.
```
sudo dpkg --install libxcb-cursor0_0.1.1-1_amd64.deb
```

3. Update repository and install i3-keyring.
```
sudo apt-get update
sudo apt-get --allow-unauthenticated install i3-autobuild-keyring
sudo apt-get update
sudo apt-get install i3
```

4. (Optional) Remove unity.
On Ubuntu 13.10
```
sudo apt-get remove nautilus gnome-power-manager compiz compiz-gnome unity unity-* unity8* hud zeitgeist zeitgeist-core python-zeitgeist libzeitgeist* activity-log-manager-common gnome-control-center gnome-screenshot
```

5. (Optional) Cleanup.
```
sudo dpkg --list |grep "^rc" | cut -d " " -f 3 | xargs sudo dpkg --purge
```

Configuration
-------------

1. Make links of i3-wm config files.
```
ln -sf ~/myConfigs/i3/config ~/.i3/config
ln -sf ~/myConfigs/i3/i3status ~/.i3/i3status
```
or (on home-ubuntu)
```
ln -sf ~/myConfigs/i3/config.home-ubuntu ~/.i3/config
ln -sf ~/myConfigs/i3/i3status.home-ubuntu ~/.i3/i3status
```

2. (Optional) Change i3-wm session icon used by LightDM. Only applicable for unity-greeter.
```
cd /usr/share/unity-greeter
sudo cp /home/yusiwen/myConfigs/i3/i3.png custom_i3_badge.png 
```

3. (Optional) Set lock screen when restoring from suspension using i3lock.
   see `pm-utils` and `xautolock`.
```
cd /etc/pm/sleep.d
sudo cp /home/yusiwen/myConfigs/i3/i3lock.pm 66_i3lock
```

4. (Optional) Add a custom i3 session in lightdm/gdm:
```
sudo cp i3.desktop /usr/share/xsessions
```

5. Config `dunst`
`dunstrc` should be copied to `~/.config/dunst/` or linked to that folder.
```
ln -sf ~/myConfigs/i3/dunstrc ~/.config/dunst/dunstrc
```

6. Make thunar as default file manager.
```
vim ./local/share/applications/thunar.desktop
```
paste content as below:
```
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
```
inode/directory=thunar.desktop
x-directory/normal=thunar.desktop
```

gnome-keyring-daemon Problems
-----------------------------

When using unity-greeter with LightDM, there may be some PAM problem causing gnome-keyring-daemon not started after user login. By replacing unity-greeter with lightdm-gtk-greeter, the problem is gone.

