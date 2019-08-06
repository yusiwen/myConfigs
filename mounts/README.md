mounts
======

Mount point and HHD drive configurations.

using `sudo blkid` to show UUIDs of all attached devices.

1. fstab

`fstab` file for diskmini-server

```
sudo mkdir /mnt/disk1
sudo mkdir /mnt/disk2
sudo mkdir /mnt/airdisk
sudo cp /etc/fstab /etc/fstab.backup
sudo cp fstab /etc/fstab
# change password for airdisk user
# use 'sudo mount -a' to do a test before rebooting
```

3. 60-schedulers.rules

`udev` rule file for block device schedulers.

Copy this file to `/etc/udev/rules.d`.

This method is used for ssd & hdd mixed environments, it sets block scheduler for ssd and hdd seperately. If there is only ssd installed, use `/etc/default/grub` to set scheduler in kernel parameter.
