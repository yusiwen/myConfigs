# VPS Configurations

## Applications

- [Leanote](https://note.yusiwen.cc)
- [Gitea](https://gitea.yusiwen.cc)
- [Lobsters](https://links.yusiwen.cc)
- [Jingo](https://note.yusiwen.cc)
- [Wiki.js](https://note.yusiwen.cc)

## Conifurations

### Supervisor

Install `supervisor` using `apt-get`: `sudo apt-get install supervisor`.

Copy `supervisord/*.conf` to `/etc/supervisor/conf.d/`.

Create log dir in `/var/log`:

```shell
mkdir -p /var/log/leanote
mkdir -p /var/log/gitea
mkdir -p /var/log/lobsters
mkdir -p /var/log/jingo
mkdir -p /var/log/wikijs
```

Restart `supervisor` using `systemctl`: `sudo systemctl restart supervisor`.
