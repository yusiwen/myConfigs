# VPS Configurations

## Applications

- [Artifactory](https://maven.yusiwen.cn)
- [Gitea](https://gitea.yusiwen.cn)
- [Jenkins](https://jenkins.yusiwen.cn)
- [Wiki.js](https://note.yusiwen.cn)

## Conifurations

### SSH Keys

Add SSH keys to `vps01` and `aliyun01` as root manually or using `ssh-copy-id`

### Jenkins

Install backup plugin, see detail at [Periodic Backup](https://plugins.jenkins.io/periodicbackup)

### Gitea

Add crontab of user `git`

```sh
sudo mkdir -p /var/lib/gitea
sudo chown -R git:gitservice /var/lib/gitea
crontab -e
```

Add line as following

```text
0 2 * * MON (cd /var/lib/gitea && /usr/local/bin/gitea/gitea dump)
```

## FAQ

### Add Rsync to “Git Bash for Windows”

Download the [package](http://www2.futureware.at/~nickoe/msys2-mirror/msys/x86_64/rsync-3.1.2-2-x86_64.pkg.tar.xz) from [pacman repository](http://www2.futureware.at/~nickoe/msys2-mirror/msys/x86_64/).

Extract t using 7-zip and drop rsync.exe to `C:\Program Files\Git\usr\bin`.

Likewise, you can find more *nix tools from pacman repository and install it manually.

[Original Post](https://blog.tiger-workshop.com/add-rsync-to-git-bash-for-windows/)
