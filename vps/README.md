# VPS Configurations

## Applications

- [Leanote](https://note.yusiwen.cc)
- [Gitea](https://gitea.yusiwen.cc)
- [Lobsters](https://links.yusiwen.cc)

## Conifurations

### Supervisor

Install `supervisor` using `apt-get`: `sudo apt-get install supervisor`.

Copy `supervisord/*.conf` to `/etc/supervisor/conf.d/`.

Create log dir in `/var/log`:
```shell
mkdir -p /var/log/leanote
mkdir -p /var/log/gitea
mkdir -p /var/log/lobsters

chown leanote:leanote /var/log/leanote
chown gitea:gitea /var/log/gitea
chown lobsters:lobsters /var/log/lobsters
```

Restart `supervisor` using `systemctl`: `sudo systemctl restart supervisor`.
