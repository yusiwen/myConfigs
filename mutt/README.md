mutt
====
Mutt mail client configuration files.

Contents
--------
`goobookrc` configuration file for python goobook module.  
`mailcap` .mailcap file for mutt.  
`mkenv.sh` script for establishing environments for mutt.  
`mutt_get_imap_passwd.py` script for mutt to get password from gnome-keyring.  
`mutt_get_passwd.py` another script for mutt to get password from gnome-keyring.  
`muttrc.general` general mutt configuration parts, to be included in the final configuration file.  
`muttrc.imap.gmail` mutt configuration file for gmail accounts.  
`muttrc.local` mutt configuration file for local mbox.  
`signature` my signature for mutt.  

Installation
------------
```
sudo apt-get install mutt mutt-patched w3m w3m-img notmuch notmuch-mutt
sudo pip install goobook
sudo pip install keyring
```
Run mkenv.sh script to establish environments for mutt.

