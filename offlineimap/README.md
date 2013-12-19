offlineimap
===========

Configurations for offlineImap.

## Installation
Get offlineImap source from git repository.
```
git clone git://github.com/OfflineIMAP/offlineimap.git
```
Install
```
cd ~/offlineimap
sudo python setup.py install
```

## Configurations
```
mkdir ~/.offlineimap
mkdir ~/.mail
ln -sf ~/myConfigs/offlineimap/offlineimaprc ~/.offlineimaprc
ln -sf ~/myConfigs/offlineimap/offlineimap_scripts.py ~/.offlineimap/offlineimap_scripts.py
cp ~/myConfigs/offlineimap/notmuch-config ~/.notmuch-config
```
NOTE: Change path in `~/.notmuch-config` of database to real MailBox path.


