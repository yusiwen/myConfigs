keyring
=======

Gnome keyring config for non-gnome session, for example, i3-wm.

keyring.sh
----------

Gnome keyring startup script for non-gnome session.

Required packages
-----------------
```
sudo apt-get install libgnome-keyring-common libgnome-keyring0 libgnome-keyring0:i386 libp11-kit-gnome-keyring libp11-kit-gnome-keyring:i386 libgnome-keyring-dev python-keyring
```

keyringrc.cfg
-------------

Python keyring library config file.
```
cd
cd .local/share
mkdir python_keyring
cd python_keyring
ln -sf ~/myConfigs/keyring/keyringrc.cfg keyringrc.cfg
```
