myConfigs
=========

```text
███╗   ███╗██╗   ██╗ ██████╗ ██████╗ ███╗   ██╗███████╗██╗ ██████╗ ███████╗
████╗ ████║╚██╗ ██╔╝██╔════╝██╔═══██╗████╗  ██║██╔════╝██║██╔════╝ ██╔════╝
██╔████╔██║ ╚████╔╝ ██║     ██║   ██║██╔██╗ ██║█████╗  ██║██║  ███╗███████╗
██║╚██╔╝██║  ╚██╔╝  ██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██║   ██║╚════██║
██║ ╚═╝ ██║   ██║   ╚██████╗╚██████╔╝██║ ╚████║██║     ██║╚██████╔╝███████║
╚═╝     ╚═╝   ╚═╝    ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝ ╚══════╝

Configuration files of my linux boxes: laptop and desktop (home-ubuntu)
http://git.io/vtVXR
yusiwen@gmail.com
```

Contents
--------
1. `eclipse/` Eclipse configurations under linux.
1. `figlet/` figlet fonts for ascii art.
1. `gfw/` configurations for shadowsocks and polipo
1. `git/` Git configurations and scripts.
1. `i3/` i3-wm configurations.
1. `keyring/` keyring confiurations for i3 and mutt.
1. `mac/` configurations for MacOS.
1. `mail/` settings for all mail clients.
1. `mc.conf/` confiurations for MidnightCommander.
1. `mounts/` fstab configurations for home-ubuntu.
1. `mpd/` mpd configurations.
1. `node.js/` Node.js settings.
1. `python/` Python settings.
1. `razer/` Razer DeathAdder mouse polling rate configurations.
1. `shell/` shell environments scripts.
1. `vim/` VIM configurations.
1. `X11/` X11 scripts.
1. `calibre.sh` for installation for `calibre`.
1. `change_font.sh` script for changing font.
1. `change_theme.sh` script for changing themes of Xresources, vim, etc.
1. `composeKey.sh` compose keys setting for X.
1. `install_tools.sh` script for installing tools under Ubuntu.
1. `ocr.sh` script for OCR some pages in a PDF file.
1. `projector.sh` xrandr settings for connection with a projector.
1. `route.sh` routing config files for 3G mobile network when at work.

Softwares
---------

Some important softwares. Needed after re-installing OS.

1. i3-wm

	See `i3/README.md`.

1. Git

	```text
	$ sudo apt-add-repository ppa:git-core/ppa
	$ sudo apt-get install git
	```

	See more details in `git/README.md`.

1. Chrome

	```text
	$ wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
	$ sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
	$ sudo apt-get install google-chrome-stable
	```

	To solve the missing download page icons:

	```text
	$ sudo apt-get install gnome-icon-theme-full
	```

	or install faenza icon theme.

1. Vim & NeoVim

	For x11-clipboard support under xterm, install `vim-gtk` instead of `vim` package.

	```text
	$ sudo apt-add-repository ppa:neovim-ppa/stable
	$ sudo apt-get install vim-gtk neovim
	```

	See more details in `vim/README.md`.

1. Terminal tools

	* [rxvt-unicode](http://software.schmorp.de/pkg/rxvt-unicode.html)

		Installing from Ubuntu official repository:

		```text
		$ sudo apt-get install rxvt-unicode-256color
		```

		Building from source:

		```text
		$ cvs -z3 -d :pserver:anonymous@cvs.schmorp.de/schmorpforge co rxvt-unicode
		```

		Or

		```text
		$ git clone git@github.com:yusiwen/rxvt-unicode.git
		$ git submodule init
		$ git submodule update
		```

		Then

		```text
		$ sudo apt-get install libperl-dev libstartup-notification0-dev libgdk-pixbuf2.0-dev libxft-dev xsel
		$ cd rxvt-unicode
		$ ./configure --enable-256-color --enable-unicode3 --enable-combining --enable-xft --enable-font-styles --enable-pixbuf --enable-startup-notification --enable-transparency --enable-fading --enable-rxvt-scroll --enable-perl --enable-iso14755 --enable-keepscrolling --enable-selectionscrolling --enable-mousewheel --enable-slipwheeling --enable-smart-resize --enable-text-blink --enable-pointer-blank --enable-utmp --enable-wtmp --enable-lastlog
		```

		See `rxvt/README.md` for more details.

	* fbterm

		```text
		$ sudo apt-get install fbterm
		$ sudo gpasswd -a YOUR_USERNAME video
		$ sudo chmod u+s /usr/bin/fbterm
		```

	* [rofi](https://davedavenport.github.io/rofi/) (A window switcher, run dialog and dmenu replacement)

		Replace `dmenu` by `rofi`

		```text
		$ git clone git@github.com:yusiwen/rofi.git
		$ cd rofi
		$ git remote add upstream git@github.com:DaveDavenport/rofi.git
		$ autoreconf -i
		$ mkdir build/;cd build/
		$ ../configure
		$ make
		$ sudo make install
		```

	* Midnight Commander

		To get prerequisites:

		```text
		$ sudo apt-get build-dep mc
		```

		To get the source:

		```text
		$ git clone git@github.com:yusiwen/mc.git
		```

1. feh

	Install required package to build `feh`.

	```text
	$ sudo apt-get install libcurl4-openssl-dev libx11-dev libxt-dev libimlib2-dev giblib-dev libxinerama-dev libjpeg-progs
	```

	Get source from:

	```text
	$ git clone git://derf.homelinux.org/feh
	```

	Or

	```text
	$ git clone git@github.com:yusiwen/feh.git
	```

1. GFW tools & settings

	* Mirror for launchpad PPAs

		Use `launchpad.proxy.ustclug.org` to replace `ppa.launchpad.net` in every PPA addresses to reverse proxy the requests.

		See [中科大开源软件镜像服务帮助-反向代理](https://lug.ustc.edu.cn/wiki/mirrors/help/revproxy)


	* [shadowsocks-qt5](https://github.com/librehat/shadowsocks-qt5)

		Install `shadowsocks-qt5`:

		```text
		$ sudo apt-add-repository ppa:hzwhuang/ss-qt5
		$ sudo apt-get install shadowsocks-qt5
		```

		Go to [shadowsocks.com](https://portal.shadowsocks.com/clientarea.php) to get server information.

		Manually add server to shadowsocks-qt5, set the port to `1088`.

		Install `tsocks`:

		```text
		$ sudo apt-get install tsocks
		```

		Edit `/etc/tsocks.conf`:

		```text
		...
		server = 127.0.0.1
		server_port = 1088
		...
		```

1. [kingsoft-office](http://linux.wps.cn/) (AKA "WPS")

	To install kingsoft-office on 13.10+, which has removed ia32-libs package:

	```text
	$ sudo dpkg --add-architecture i386
	$ sudo apt-get update
	$ sudo apt-get install libc6:i386 libstdc++6:i386 libfreetype6:i386 libglu1-mesa:i386 libcups2:i386 libglib2.0-0:i386 libpng12-0:i386 libsm6:i386 libxrender1:i386 libfontconfig1:i386
	```

	Then, install kingsoft-office package using dpkg.

	* Note: Since version A18, kingsoft-office supports x64 architecture, just install the deb directly. No needs for i386 multi-arch supports.

	Install windows fonts:

	```text
	$ sudo apt-get install ttf-mscorefonts-installer
	```

	Then, extract files from `wps_symbol_fonts.zip`, install them in `Font-Manager`.

1. Calibre

	```text
	$ sudo -v && wget -nv -O- https://raw.githubusercontent.com/kovidgoyal/calibre/master/setup/linux-installer.py | sudo python -c "import sys; main=lambda:sys.stderr.write('Download failed\n'); exec(sys.stdin.read()); main()"
	```

	Or, installing manually (changing the path to `calibre-tarball.txz` below as appropriate):

	```text
	$ sudo mkdir -p /opt/calibre && sudo rm -rf /opt/calibre/* && sudo tar xvf /path/to/downloaded/calibre-tarball.txz -C /opt/calibre && sudo /opt/calibre/calibre_postinstall
	```

1. Mail Clients

	* offlineImap

		```text
		$ git clone git://github.com/OfflineIMAP/offlineimap.git
		```

		Then, run mkenv.sh
		Note: Using `shadowsocks-qt5` for proxy, see #21 below.

	* sup (need offlineImap)

		```text
		$ sudo apt-get install build-essential libncursesw5-dev libncurses5-dev uuid-dev zlib1g-dev
		$ sudo apt-get install msmtp sqlite
		$ sudo apt-get install ruby-full rubygems rake
		$ gem install sup # sudo is not needed if not using system ruby
		```

	* mutt

		```text
		$ sudo apt-get install mutt-patched
		$ sudo apt-get install w3m w3m-img
		```

		Run ~/myConfigs/mutt/mkenv.sh

		```text
		$ sudo pip install goobook
		$ sudo pip install keyring
		```

1. Media tools

	* MPD

		```text
		$ sudo apt-add-repository ppa:gmpc-trunk/mpd-trunk
		```

		Run ~/myConfigs/mpd/mkenv.sh

		```text
		$ sudo apt-get update
		$ sudo apt-get install mpd ncmpcpp
		```

	* smplayer

		```text
		$ sudo apt-add-repository ppa:rvm/smplayer
		$ sudo apt-get update
		$ sudo apt-get install smplayer smtube smplayer-themes smplayer-skins
		```

1. Indicators

	* Sound Switcher Indicator

		```text
		$ sudo apt-add-repository ppa:yktooo/ppa
		$ sudo apt-get update
		$ sudo apt-get install indicator-sound-switcher
		```

	* Indicator Netspeed

		```text
		$ sudo add-apt-repository ppa:nilarimogard/webupd8
		$ sudo apt-get update
		$ sudo apt-get install indicator-netspeed
		```

	* classicmenu-indicator

		```text
		$ sudo apt-add-repository ppa:diesch/testing
		$ sudo apt-get update
		$ sudo apt-get install classicmenu-indicator
		```

1. wiznote

	```text
	$ sudo apt-add-repository ppa:wiznote-team/ppa
	$ sudo apt-get install wiznote
	```

1. Download managers

	* uGet

		```
		$ sudo apt-add-repository ppa:plushuang-tw/uget-stable
		$ sudo apt-get update
		$ sudo apt-get install uget
		```

	* xunlei-lixian 迅雷离线下载

		```
		$ git clone git@github.com:yusiwen/xunlei-lixian.git
		$ ln -sf xunlei-lixian/lixian_cli.py ~/bin/xllx
		```

1. TLP (Power management tools for laptop)

	Remove `laptop-mode-tools` first, it conflicts with TLP.

	```text
	$ sudo apt-get remove laptop-mode-tools
	```

	Then

	```text
	$ sudo add-apt-repository ppa:linrunner/tlp
	$ sudo apt-get update
	$ sudo apt-get install tlp tlp-rdw
	```

1. Themes

	* [Numix theme](https://numixproject.org/)

		```text
		$ sudo apt-add-repository ppa:numix/ppa
		```

	* [Faenza icon theme](http://tiheum.deviantart.com/art/Faenza-Icons-173323228)

		```text
		$ sudo apt-add-repository ppa:webupd8team/themes
		```

1. font-manager

	```text
	$ sudo apt-add-repository ppa:font-manager/staging
	```

Troubleshooting
---------------

1. UTC problem in dual-boot within Ubuntu and Widnows 8.1

	Edit file: `/etc/default/rcS`, set `UTC=yes`

1. Qt applications in GTK+ looks ugly

	After setting gtk+ themes by `$HOME/.gtkrc-2.0` (see `X11/README.md`), install `qt4-qtconfig`:

	```text
	$ sudo apt-get install qt4-qtconfig
	$ qtconfig
	```

	Choose 'GUI style' to 'GTK+', this will unify the style between Qt and GTK+.

1. Fix apt-get GPG error “NO_PUBKEY”

	This problem is caused by [bug #1263540](https://bugs.launchpad.net/ubuntu/+source/apt/+bug/1263540), it occurs if there are more than 40 keys (*.gpg) in /etc/apt/trusted.gpg.d/. Try below:

	```text
	$ sudo apt-get clean
	$ sudo mv /var/lib/apt/lists /var/lib/apt/lists.old
	$ sudo mkdir -p /var/lib/apt/lists/partial
	$ sudo mv /etc/apt/trusted.gpg.d/ /etc/apt/trusted.gpg.d.backup/
	$ sudo mkdir /etc/apt/trusted.gpg.d/
	sudo apt-get update
	```

	And add your missing key manually using:

	```text
	$ sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys KEY1 KEY2 KEY3 ...
	```
