dual-monitor
============

1. Copy `set_dual_monitor.sh` to `/usr/local/bin`

```
$ sudo cp set_dual_monitor.sh /usr/local/bin
```

2. Add this line to the bottom of `/etc/lightdm/lightdm.conf`

```
$ display-setup-script=/usr/local/bin/set_dual_monitor.sh
```
