# Notes on CentOS

## Enable EPEL 7 repository

```shell
yum install epel-release
yum install centos-release-scl
yum install the_silver_searcher
```

## Packages needed after minimal installation

- `net-tools`: for `netstat` and `ifconfig`, etc.
- `zsh`

### Git

Use WANDisco's CentOS repository to install Git 2.x for CentOS 7

```shell
yum install http://opensource.wandisco.com/centos/7/git/x86_64/wandisco-git-release-7-2.noarch.rpm
yum install git
```

Or manually download packages from [here](http://opensource.wandisco.com/centos/7/git/x86_64/)

### Vim

```shell
wget "https://copr.fedorainfracloud.org/coprs/lantw44/vim-latest/repo/epel-7/lantw44-vim-latest-epel-7.repo" \
  -o /etc/yum.repos.d/lantw44-vim-latest-epel-7.repo

yum update
yum install vim
```

### NeoVim

```shell
curl -o /etc/yum.repos.d/dperson-neovim-epel-7.repo \
  "https://copr.fedorainfracloud.org/coprs/dperson/neovim/repo/epel-7/dperson-neovim-epel-7.repo"
yum -y install neovim
```

### Node.js

```shell
curl --silent --location https://rpm.nodesource.com/setup_8.x | sudo bash -
sudo yum install -y nodejs
```

### Python3

```shell
sudo yum install python36 python-pip
sudo pip install --upgrade pip
```
