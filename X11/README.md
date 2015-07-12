X11
===

Configuration files for X11 softwares.

## Contents

1. `dual-monitor/` contains script for dual monitor settings
1. `fonts/` contains script for edit truetype fonts by fontforge
1. `gtk/` contains gtk themes settings
1. `themes` contains X color themes

### Xresources and Xinit Files

`Xresources` is user's .Xresources file for X. It contains configurations for xterm, urxvt, rofi, etc.

`xinitrc` is user's .xinitrc file for custom i3-wm xsession. If i3-wm is started from LightDM by `/usr/share/xsessions/i3.desktop`, this file is not used.

Usage:

```sh
$ ln -sf ~/myConfigs/X11/Xresources ~/.Xresources
```

### GTK Configuration Files

`gtk/gtkrc-2.0` is gtk2.0 config file.

`gtk/gtkrc-3.0` is gtk3.0 config file.

Both files set theme and icon theme for GTK environment.

Usage:

```sh
$ ln -sf ~/myConfigs/X11/gtk/gtkrc-2.0 ~/.gtkrc-2.0
$ ln -sf ~/myConfigs/X11/gtk/gtkrc-3.0 ~/.config/gtk-3.0/settings
```

### Qt Configuration

To unify appearance of Qt applications with GTK ones, install `qt4-qtconfig` by:

```sh
$ sudo apt-get install qt4-qtconfig
$ qtconfig
```

Change the appearance to the same theme in GTK. See [Uniform Look for Qt and GTK Applications](https://wiki.archlinux.org/index.php/Uniform_Look_for_Qt_and_GTK_Applications) and [this answer](http://askubuntu.com/a/22319) on [AskUbuntu](http://askubuntu.com/)
