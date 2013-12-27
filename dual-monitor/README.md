dual-monitor
============

1. cp `set_dual_monitor.sh` to /usr/local/bin

2. add below line to /etc/lightdm/lightdm.conf
```
display-setup-script=/usr/local/bin/set_dual_monitor.sh
```
