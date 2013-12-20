configs
=======

Configurations for i3-wm.

1. i3-wm config files.
```
ln -sf ~/myConfigs/i3/config ~/.i3/config
ln -sf ~/myConfigs/i3/i3status ~/.i3/i3status
```
or (on home-ubuntu)
```
ln -sf ~/myConfigs/i3/config.home-ubuntu ~/.i3/config
ln -sf ~/myConfigs/i3/i3status.home-ubuntu ~/.i3/i3status
```

2. i3-wm session icon used by LightDM session chooser:
```
cd /usr/share/unity-greeter
sudo cp /home/yusiwen/myConfigs/i3/i3.png custom_i3_badge.png 
```

3. lock screen when restoring from suspension using i3lock.
   see `pm-utils` and `xautolock`.
```
cd /etc/pm/sleep.d
sudo cp /home/yusiwen/myConfigs/i3/i3lock.pm 66_i3lock
```

4. custom i3 session in lightdm/gdm:
```
sudo cp i3.desktop /usr/share/xsessions
```

5. dunstrc should be copied to ~/.config/dunst/ or linked to that folder.
```
ln -sf ~/myConfigs/i3/dunstrc ~/.config/dunst/dunstrc
```

6. make thunar as default file manager.
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
