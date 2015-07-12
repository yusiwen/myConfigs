Node.js
=======

# Installation

***Note:*** The packages on this page are maintained and supported by their respective packagers, **not** the Node.js core team. Please report any issues you encounter to the package maintainer. If it turns out your issue is a bug in Node.js itself, the maintainer will report the issue upstream.

## Ubuntu, Debian, Linux Mint, etc.

***Including most Ubuntu and Debian-based Linux distributions***

Node.js is available from the [NodeSource](https://nodesource.com) official Debian and Ubuntu repository.

Setup with:

```text
$ curl -sL https://deb.nodesource.com/setup | sudo bash -
```

Then install:

```text
$ sudo apt-get install nodejs
```

**Available architectures:**

* **i386** (32-bit)
* **amd64** (64-bit)
* **armhf** (ARM 32-bit hard-float, ARMv7 and up: _arm-linux-gnueabihf_)

**Supported Ubuntu versions:**

* **Ubuntu 10.04 LTS** (Lucid Lynx, *armhf build not available*)
* **Ubuntu 12.04 LTS** (Precise Pangolin)
* **Ubuntu 13.10** (Saucy Salamander)
* **Ubuntu 14.04 LTS** (Trusty Tahr)

**Supported Debian versions:**

* **Debian 7 / stable** (wheezy)
* **Debian testing** (jessie)
* **Debian unstable** (sid)

A Node.js package is also available in [official repo](http://packages.debian.org/search?searchon=names&keywords=nodejs) for Debian Sid (unstable) as "nodejs".

***Note:*** You may experience a naming conflict with the "node" package (Amateur Packet Radio Node Program), and find that the "nodejs" binary has been renamed from `node` to `nodejs`. You'll need to symlink `/usr/bin/node` to `/usr/bin/nodejs` or you could uninstall the Amateur Packet Radio Node Program to avoid the conflict.

## Gentoo

Node.js is available in the portage tree.

```text
$ emerge nodejs
```

## openSUSE & SLE

[Download Node.js via openSUSE one-click](http://software.opensuse.org/download.html?project=devel%3Alanguages%3Anodejs&package=nodejs).

Available RPM packages for: openSUSE 11.4, 12.1, 12.2, 12.3, 13.1, Factory and Tumbleweed; SLE 11 (with SP1/SP2/SP3 variations).

Example install on openSUSE 13.1:

```text
$ sudo zypper ar \
  http://download.opensuse.org/repositories/devel:/languages:/nodejs/openSUSE_13.1/ \
  Node.js
$ sudo zypper in nodejs nodejs-devel
```

## Fedora

[Node.js](https://apps.fedoraproject.org/packages/nodejs) and [npm](https://apps.fedoraproject.org/packages/npm) are available in Fedora 18 and later. Just use your favorite graphical package manager or run this on a terminal to install both node and npm:

```text
$ sudo yum install nodejs npm
```

## Enterprise Linux (RHEL, CentOS, Fedora, etc.)

Node.js and npm are available from the [Extra Packages for Enterprise Linux](https://fedoraproject.org/wiki/EPEL) (EPEL) repository.

To check if you have EPEL registered, run:

```text
$ yum repolist
```

If you don't see EPEL, [install it](https://fedoraproject.org/wiki/EPEL#How_can_I_use_these_extra_packages.3F
) via `yum`:

For **Enterprise Linux version 6** (EPEL version 6.8 at the time of writing):

```text
$ yum install \
  http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
```

For **Enterprise Linux version 7 Beta**:

```text
$ yum install \
  http://dl.fedoraproject.org/pub/epel/beta/7/x86_64/epel-release-7-0.2.noarch.rpm
```

Then install the **nodejs** and **npm** packages:

```text
$ sudo yum install nodejs npm --enablerepo=epel
```

## Arch Linux

Node.js is available in the Community Repository.

```text
$ pacman -S nodejs
```

## FreeBSD and OpenBSD

Node.js is available through the ports system.

```text
/usr/ports/www/node
```

Development versions are also available using ports

```text
$ cd /usr/ports/www/node-devel/ && make install clean
```

Or packages on FreeBSD:

```text
$ pkg_add -r node-devel
```

Using [pkg-ng](https://wiki.freebsd.org/pkgng) on FreeBSD

```text
$ pkg install node
```

Or the development versions:

```text
$ pkg install node-devel
```

## OSX

Simply download the [Macintosh Installer](http://nodejs.org/#download) direct from the [nodejs.org](http://nodejs.org) web site.

### Alternatives

Using **[Homebrew](http://brew.sh/)**:

```text
$ brew install node
```

Using **[Fink](http://www.finkproject.org)**:

```text
$ fink install nodejs
```

Using **[MacPorts](http://www.macports.org/)**:

```text
$ port install nodejs
```

## Windows

Simply download the [Windows Installer](http://nodejs.org/#download) directly from the [nodejs.org](http://nodejs.org) web site.

### Alternatives

Using **[Chocolatey](http://chocolatey.org)**:

```text
$ cinst nodejs
# or for full install with npm
$ cinst nodejs.install
```

Using **[Scoop](http://scoop.sh/)**:

```text
$ scoop install nodejs
```

# Install npm packages globally on Linux without sudo

npm installs packages locally within each of your projects by default. You
can also install packages globally (e.g. `npm install -g <package>`). However
the downside of this is that you need to be root (or use `sudo`) to be
able to install globally.

Here is a way to install packages globally for a given user.

1. Create a directory for your global packages
```bash
$ mkdir ~/.npm-packages
```

2. Reference this directory for future usage in your `.bashrc`/`.zshrc`:
```bash
NPM_PACKAGES="$HOME/.npm-packages"
```

3. Indicate to `npm` where to store your globally installed package. In
   your `~/.npmrc` file add:
```
prefix=~/.npm-packages
```

4. Ensure `node` will find them. Add the following to your
   `.bashrc`/`.zshrc`:
```bash
NODE_PATH="$NPM_PACKAGES/lib/node_modules:$NODE_PATH"
```

5. Ensure you'll find installed binaries and man pages. Add the following to your
   `.bashrc`/`.zshrc`:
```bash
PATH="$NPM_PACKAGES/bin:$PATH"
# Unset manpath so we can inherit from /etc/manpath via the `manpath`
# command
unset MANPATH  # delete if you already modified MANPATH elsewhere in your config
MANPATH="$NPM_PACKAGES/share/man:$(manpath)"
```

Inspired from this [answer on
StackOverflow](http://stackoverflow.com/a/13021677).

