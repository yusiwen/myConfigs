Mail clients
============

Mail clients configuration files.

Contents
--------
`goobook/` configuration file for python goobook module

`msmtp/` configuration file for msmtp

`mutt/` configuration files for mutt

`offlineimap/` configuration files for OfflineIMAP

`sup/` configuration files for sup

`mkenv.sh` script for initializing all in one step

Installation
------------

Install [`mutt`](http://www.mutt.org/), `mutt-patched`, [`w3m`](http://w3m.sourceforge.net/), [`goobook`](https://pypi.python.org/pypi/goobook), [`keyring`](https://pypi.python.org/pypi/keyring), [`offlineimap`](http://offlineimap.org/), [`sup`](http://supmua.org/)

```
$ sudo apt-get install mutt mutt-patched w3m w3m-img notmuch notmuch-mutt
$ sudo pip install goobook
$ sudo pip install keyring

# Configure goobook
$ goobook authenticate
$ goobook config-template > ~/.goobookrc
# Or, ln -sf ~/myConfigs/mutt/goobookrc .goobookrc

$ sudo gem install sup
```

See `offlineimap/README.md` for installation notes on `offlineimap`.

Run mkenv.sh script to establish environments.

