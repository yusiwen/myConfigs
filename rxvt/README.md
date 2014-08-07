rxvt
====

Configuration files for rxvt/rxvt-unicode.

## Get rxvt-unicode source
```
checkout source with:
cvs -z3 -d :pserver:anonymous@cvs.schmorp.de/schmorpforge co rxvt-unicode
```

## Install required packages
```
sudo apt-get install libperl-dev libstartup-notification0-dev libgdk-pixbuf2.0-dev
```

## Configure build options
```
cd ~/rxvt-unicode
./configure --enable-256-color --enable-unicode3 --enable-combining --enable-xft --enable-font-styles --enable-pixbuf --enable-startup-notification --enable-transparency --enable-fading --enable-rxvt-scroll --enable-perl --enable-iso14755 --enable-keepscrolling --enable-selectionscrolling --enable-mousewheel --enable-slipwheeling --enable-smart-resize --enable-text-blink --enable-pointer-blank --enable-utmp --enable-wtmp --enable-lastlog
```

## Install clipboard support
  `clipboard` is a perl script for rxvt to copy/paste text in both X primary selection and clipboard.
  
  In `~/.Xresources`, add 'clipboard' to URxvt.perl-ext-common string. see `X11/Xresources` for details.
  need xsel package.
  
```
sudo apt-get install xsel
sudo cp ~/myConfigs/rxvt/clipboard /usr/local/lib/urxvt/perl/
```

Note:  
Since Jan 2014, there is an official clipboard perl script also named `clipboard` in rxvt-unicode sources.

## Import official CVS repository into GitHub

  # Import CVS repository into current directory. 
  $ mkdir rxvt-unicode
  $ cd rxvt-unicode
  $ git cvsimport -p -x -r cvs -k -v -d :pserver:anonymous@cvs.schmorp.de/schmorpforge rxvt-unicode
  $ git config cvsimport.module rxvt-unicode
  $ git config cvsimport.r cvs
  $ git config cvsimport.d :pserver:anonymous@cvs.schmorp.de/schmorpforge
  # Import 'libecb' 'libev' 'libptytty' and add them as submodules into project 'rxvt-unicode'
