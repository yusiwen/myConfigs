X11
===

Configuration files for X11 softwares.

## Contents

### Xresources and Xinit Files

`Xresources` and `Xresoruces.home-ubuntu` are Xresources file for URxvt.
`xinitrc` is xinitrc file for custom i3-wm xsession. If i3-wm is started from LightDM, this file is not used.

Usage:

  ln -sf ~/myConfigs/X11/Xresources ~/.Xresources
or
  ln -sf ~/myConfigs/X11/Xresources.home-ubuntu ~/.Xresources
  ln -sf ~/myConfigs/X11/xinitrc ~/.xinitrc
  ln -sf ~/myConfigs/X11/xinitrc ~/.xsession

### GTK Configuration Files

`gtkrc-2.0` is gtk2.0 config file.
`gtkrc-3.0` is gtk3.0 config file.
Both files set theme and icon theme for GTK environment.

Usage:

  ln -sf ~/myConfigs/X11/gtkrc-2.0 ~/.gtkrc-2.0
  ln -sf ~/myConfigs/X11/gtkrc-3.0 ~/.config/gtk-3.0/settings
