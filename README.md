myConfigs
=========

Configuration files of my linux boxes: laptop and desktop (home-ubuntu).

Contents
--------
1. `base16/` `solarized/` are submodules. Both are color themes.  
1. `oh-my-zsh/` is a submodule. It's configurations for ZSH.  
1. `dual-monitor/` dual-monitor configurations for home-ubuntu.  
1. `eclipse/` Eclipse configurations under linux.  
1. `i3/` i3-wm configurations.  
1. `git/` Git configurations and scripts.
1. `keyring` keyring confiurations for i3 and mutt.  
1. `ls--/` submodule. ls++ - colorized ls on steroids.
1. `mc` submodule. MidnightCommander file manager.
1. `mounts/` fstab configurations for home-ubuntu.  
1. `mpd/` mpd configurations.  
1. `mutt/` mutt mail client configurations.  
1. `offlineimap/` offlineimap, sup, and notmuch configurations.  
1. `razer/` Razer DeathAdder mouse polling rate configurations.  
1. `rofi/` submodule. A popup window switcher roughly based on superswitcher, requiring only xlib and pango.
1. `rxvt/` rxvt-unicode terminal configurations.  
1. `screen/` screen configurations.  
1. `shell/` shell environments scripts.  
1. `vim/` VIM configurations.  
1. `X11/` X11 scripts.  
1. `route.sh` and `route_iPhone.sh` are routing config files for 3G mobile network when at work.  
1. `set_dual_monitor.sh` and `projector.sh` are config files for xrandr to work with multiple monitors.  
1. `color_sampler.perl` shell color sampler script in perl.  
1. `color_spaces.perl` another shell color sampler script in perl with 256 color.  
1. `mTouch.py` python script made by me. It enables three fingers swipe cycling within workspaces.  
1. `rsync_skydrive.sh` shell script made by me. It uses rsync to sync skydrive files to my backup disks.

Softwares
---------

Some important softwares. Needed after re-installing OS.  

1. Git

		$ sudo apt-add-repository ppa:git-core/ppa
		$ sudo apt-get install git

1. Chrome

		$ wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
		$ sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
		$ sudo apt-get install google-chrome-stable
	
	To solve the missing download page icons:

		$ sudo apt-get install gnome-icon-theme-full
	
	or install faenza icon theme.

1. Vim

	For x11-clipboard support under xterm, install `vim-gtk` instead of `vim` package.

		$ sudo apt-get install vim-gtk

	Install `vundle` pacakge manager for vim.

		$ git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle

1. rxvt-unicode

		$ cvs -z3 -d :pserver:anonymous@cvs.schmorp.de/schmorpforge co rxvt-unicode

	Or

		$ git clone git@github.com:yusiwen/rxvt-unicode.git
		$ git submodule init
		$ git submodule update

	Then

		$ sudo apt-get install libperl-dev libstartup-notification0-dev libgdk-pixbuf2.0-dev libxft-dev xsel
		$ cd rxvt-unicode
		$ ./configure --enable-256-color --enable-unicode3 --enable-combining --enable-xft --enable-font-styles --enable-pixbuf --enable-startup-notification --enable-transparency --enable-fading --enable-rxvt-scroll --enable-perl --enable-iso14755 --enable-keepscrolling --enable-selectionscrolling --enable-mousewheel --enable-slipwheeling --enable-smart-resize --enable-text-blink --enable-pointer-blank --enable-utmp --enable-wtmp --enable-lastlog

1. feh

	Install required package to build `feh`.

		$ sudo apt-get install libcurl4-openssl-dev libx11-dev libxt-dev libimlib2-dev giblib-dev libxinerama-dev libjpeg-progs

	Get source from:

		$ git clone git://derf.homelinux.org/feh

	Or

		$ git clone git@github.com:yusiwen/feh.git

1. Midnight Commander

	To get prerequisites:

		$ sudo apt-get build-dep mc

	To get the source:

		$ git clone git@github.com:yusiwen/mc.git

1. GoAgent Linux 

		$ sudo apt-get install python-dev python-greenlet python-gevent python-vte python-openssl python-crypto python-appindicator
		$ wget https://github.com/surfly/gevent/releases/download/1.0/gevent-1.0.tar.gz && tar xvzpf gevent-1.0.tar.gz && cd gevent-1.0 && sudo python setup.py install
		$ sudo apt-get install python-pip
		$ sudo pip install gevent --upgrade

	Then, download GoAgent client from [here](https://code.google.com/p/goagent/).

1. i3-wm

	Installation from official repository:

		$ sudo echo "deb http://debian.sur5r.net/i3/ $(lsb_release -c -s) universe" >> /etc/apt/sources.list
		$ sudo apt-get update
		$ sudo apt-get --allow-unauthenticated install sur5r-keyring
		$ sudo apt-get install consolekit
		$ sudo apt-get install i3

	Then, disable `xfce4-notifyd` because `dunst` is running:

		$ sudo mv /usr/share/dbus-1/services/org.xfce.xfce4-notifyd.Notifications.service /usr/share/dbus-1/services/org.xfce.xfce4-notifyd.Notifications.service.disabled

	Install i3blocks to replace i3status for better status display:

		$ sudo apt-get install i3blocks
		$ ln -s ~/myConfigs/i3/i3blocks.conf ~/.i3/i3blocks.conf

1. kingsoft-office

	To install kingsoft-office on 13.10+, which has removed ia32-libs package:

		$ sudo dpkg --add-architecture i386
		$ sudo apt-get update
		$ sudo apt-get install libc6:i386 libstdc++6:i386 libfreetype6:i386 libglu1-mesa:i386 libcups2:i386 libglib2.0-0:i386 libpng12-0:i386 libsm6:i386 libxrender1:i386 libfontconfig1:i386 

	Then, install kingsoft-office package using dpkg.

	* Note: Since version A18, kingsoft-office supports x64 architecture, just install the deb directly. No needs for i386 multi-arch supports.

	Install windows fonts:

		$ sudo apt-get install ttf-mscorefonts-installer

1. Calibre

		$ sudo python -c "import sys; py3 = sys.version_info[0] > 2; u = __import__('urllib.request' if py3 else 'urllib', fromlist=1); exec(u.urlopen('http://status.calibre-ebook.com/linux_installer').read()); main()"

1. Mail Clients

	* offlineImap

			$ git clone git://github.com/OfflineIMAP/offlineimap.git

		Then, run mkenv.sh
		Note: Using `shadowsocks-qt5` for proxy, see #21 below.

	* sup (need offlineImap)

			$ sudo apt-get install build-essential libncursesw5-dev libncurses5-dev uuid-dev zlib1g-dev
			$ sudo apt-get install msmtp sqlite
			$ sudo apt-get install ruby-full rubygems rake
			$ gem install sup # sudo is not needed if not using system ruby

	* mutt

			$ sudo apt-get install mutt-patched
			$ sudo apt-get install w3m w3m-img
		
		Run ~/myConfigs/mutt/mkenv.sh

			$ sudo pip install goobook
			$ sudo pip install keyring

	* Geary 

			$ sudo apt-add-repository ppa:yorba/ppa
			$ sudo apt-get install geary

1. MPD

		$ sudo apt-add-repository ppa:gmpc-trunk/mpd-trunk
	
	run ~/myConfigs/mpd/mkenv.sh

		$ sudo apt-get update
		$ sudo apt-get install mpd ncmpcpp

1. Indicators

	* Sound Switcher Indicator

			$ sudo apt-add-repository ppa:yktooo/ppa
			$ sudo apt-get update
			$ sudo apt-get install indicator-sound-switcher

	* Indicator Netspeed

			$ sudo add-apt-repository ppa:nilarimogard/webupd8
			$ sudo apt-get update
			$ sudo apt-get install indicator-netspeed

	* classicmenu-indicator

			$ sudo apt-add-repository ppa:diesch/testing
			$ sudo apt-get update
			$ sudo apt-get install classicmenu-indicator

1. wiznote

		$ sudo apt-add-repository ppa:wiznote-team/ppa
		$ sudo apt-get install wiznote

1. fbterm

		$ sudo apt-get install fbterm
		$ sudo gpasswd -a YOUR_USERNAME video
		$ sudo chmod u+s /usr/bin/fbterm

1. uGet

		$ sudo apt-add-repository ppa:plushuang-tw/uget-stable
		$ sudo apt-get update
		$ sudo apt-get install uget

1. TLP (Power management tools for laptop)

	Remove `laptop-mode-tools` first, it conflicts with TLP.

		$ sudo apt-get remove laptop-mode-tools

	Then

		$ sudo add-apt-repository ppa:linrunner/tlp
		$ sudo apt-get update
		$ sudo apt-get install tlp tlp-rdw

1. Themes

	* [Numix theme](https://numixproject.org/)

			$ sudo apt-add-repository ppa:numix/ppa

	* [Faenza icon theme](http://tiheum.deviantart.com/art/Faenza-Icons-173323228)
 
			$ sudo apt-add-repository ppa:webupd8team/themes

1. font-manager

			$ sudo apt-add-repository ppa:font-manager/staging

1. shadowsocks-qt5

	Install `shadowsocks-qt5`:

		$ sudo apt-add-repository ppa:hzwhuang/ss-qt5
		$ sudo apt-get install shadowsocks-qt5

	Startup `ss-qt5`:

		$ ss-qt5

	Install `tsocks`:

		$ sudo apt-get install tsocks

	Edit `/etc/tsocks.conf`:

		server = 127.0.0.1
		server_port = 1088

1. rofi (A window switcher, run dialog and dmenu replacement)

	Replace `dmenu` by `rofi`

		$ git clone git@github.com:yusiwen/rofi.git
		$ cd rofi
		$ git remote add upstream git@github.com:DaveDavenport/rofi.git
		$ autoreconf -i
		$ mkdir build/;cd build/
		$ ../configure
		$ make
		$ sudo make install

Troubleshooting
---------------

1. UTC problem in dual-boot within Ubuntu and Widnows 8.1

	Edit file: `/etc/default/rcS`, set `UTC=yes`

