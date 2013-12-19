Configuration files for rxvt/rxvt-unicode.

rxvt-unicode
  checkout source with:
  cvs -z3 -d :pserver:anonymous@cvs.schmorp.de/schmorpforge co rxvt-unicode

required packages
  libperl-dev libstartup-notification0-dev libgdk-pixbuf2.0-dev

configure options
  --enable-256-color --enable-unicode3 --enable-combining --enable-xft --enable-font-styles --enable-pixbuf --enable-startup-notification --enable-transparency --enable-fading --enable-rxvt-scroll --enable-perl --enable-iso14755 --enable-keepscrolling --enable-selectionscrolling --enable-mousewheel --enable-slipwheeling --enable-smart-resize --enable-text-blink --enable-pointer-blank --enable-utmp --enable-wtmp --enable-lastlog

clipboard 
  perl script for rxvt to copy/paste text in both X primary selection and clipboard.
  in .Xresources, add 'clipboard' to URxvt.perl-ext-common string. see X11/Xresources for setting-up.
  need xsel package.
  this file is in /usr/local/lib/urxvt/perl/ directory.
