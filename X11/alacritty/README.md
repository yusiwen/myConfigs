# Use alacritty

[alacritty](https://github.com/jwilm/alacritty) is a cross-platform, GPU-accelerated terminal emulator. Alacritty is a terminal emulator with a strong focus on simplicity and performance. With such a strong focus on performance, included features are carefully considered and you can always expect Alacritty to be blazingly fast. By making sane choices for defaults, Alacritty requires no additional setup. However, it does allow configuration of many aspects of the terminal.

The software is considered to be at a beta level of readiness -- there are a few missing features and bugs to be fixed, but it is already used by many as a daily driver.

Precompiled binaries are available from the GitHub releases page.

## Installation

```sh
add-apt-repository ppa:mmstick76/alacritty
apt install alacritty
```

## Configuration

```sh
mkdir -p $HOME/.config/alacritty
ln -snv $HOME/myConfigs/X11/alacritty/alacritty.yml $HOME/.config/alacritty/alacritty.yml
```
