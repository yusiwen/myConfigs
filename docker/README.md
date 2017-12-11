# Docker

## Insallation

```sh
$ sudo apt install docker.io
```

## Fix "No {swap,memory} limit support"

Add `cgroup_enable=memory swapaccount=1` to `GRUB_CMDLINE_LINUX_DEFAULT` in `/etc/default/grub`, then run `sudo update-grub` and restart.
