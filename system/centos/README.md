# Setup for CentOS

# Mirror for CentOS

Use TUNA(清华大学开源软件镜像站) mirror for CentOS

```shell
sudo cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
sudo cp ./CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo
sudo yum makecache
sudo yum install -y epel-release
sudo cp /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel.repo.backup
sudo cp ./epel.repo /etc/yum.repos.d/epel.repo
sudo yum makecache
```

## Netword setup example for CentOS VMs

See `ifcfg-enp0s3` and `ifcfg-enp0s8`
