keyring
=======
Gnome keyring configurations for non-gnome session, for example, i3-wm.

Contents
--------
`keyring.sh` Gnome keyring startup script for non-gnome session.  
`keyringrc.cfg` Python keyring library configuration file.  

Required packages
-----------------

```
$ sudo apt-get install libgnome-keyring-common libgnome-keyring0 libgnome-keyring0:i386 libp11-kit-gnome-keyring libp11-kit-gnome-keyring:i386 libgnome-keyring-dev python-keyring
```

Configuration for python keyring module
---------------------------------------

```
$ cd
$ cd .local/share
$ mkdir python_keyring
$ cd python_keyring
$ ln -sf ~/myConfigs/keyring/keyringrc.cfg keyringrc.cfg
```
