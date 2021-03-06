# keyring

Gnome keyring configurations for non-gnome session, for example, i3-wm.

## Contents

`keyring.sh` Gnome keyring startup script for non-gnome session. **Note**: By using `dex` to load gnome-keyring services on X session startup, this shell script is not needed any more. See `i3/_config/`

`keyringrc.cfg` Python keyring library configuration file.

## Required packages

```sh
sudo apt-get install libgnome-keyring-common libgnome-keyring0 libgnome-keyring0:i386 libp11-kit-gnome-keyring libp11-kit-gnome-keyring:i386 libgnome-keyring-dev python-keyring
```

## Configuration for python keyring module

```sh
cd
cd .local/share
mkdir python_keyring
cd python_keyring
ln -sf ~/myConfigs/keyring/keyringrc.cfg keyringrc.cfg
```
