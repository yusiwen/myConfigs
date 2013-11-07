configs
=======
1. i3-wm session icon used by LightDM session chooser:
cd /usr/share/unity-greeter
sudo cp /home/yusiwen/myConfigs/i3/i3.png custom_i3_badge.png 

2. lock screen when restoring from suspension using i3lock.
   see pm-utils and xautolock.
cd /etc/pm/sleep.d
sudo cp /home/yusiwen/myConfigs/i3/i3lock.pm 66_i3lock

3. custom i3 session in lightdm/gdm:
sudo cp i3.desktop /usr/share/xsessions

4. dunstrc should be copied to ~/.config/dunst/ or linked to that folder.
