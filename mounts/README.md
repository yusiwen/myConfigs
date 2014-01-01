mounts
======

Mount point and HHD drive configurations.

1. fstab
`fstab` file for laptop.
```
sudo mkdir /data
sudo cp /etc/fstab /etc/fstab.backup
sudo cp fstab /etc/fstab
```

2. fstab.home-ubuntu
`fstab` file for home-ubuntu.
```
sudo mkdir /data
sudo mkdir /documents
sudo mkdir /softwares
sudo mkdir /games
sudo cp /etc/fstab /etc/fstab.backup
sudo cp fstab.home-ubuntu /etc/fstab
```

3. 60-schedulers.rules
`udev` rule file for block device schedulers.
Copy this file to `/etc/udev/rules.d`.
This method is used for ssd & hdd mixed environments, it sets block scheduler for ssd and hdd seperately. If there is only ssd installed, use `/etc/default/grub` to set scheduler in kernel parameter.
