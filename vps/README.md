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

## FAQ

### Add Rsync to “Git Bash for Windows”

Download the [package](http://www2.futureware.at/~nickoe/msys2-mirror/msys/x86_64/rsync-3.1.2-2-x86_64.pkg.tar.xz) from [pacman repository](http://www2.futureware.at/~nickoe/msys2-mirror/msys/x86_64/).

Extract t using 7-zip and drop rsync.exe to `C:\Program Files\Git\usr\bin`.

Likewise, you can find more *nix tools from pacman repository and install it manually.

[Original Post](https://blog.tiger-workshop.com/add-rsync-to-git-bash-for-windows/)
