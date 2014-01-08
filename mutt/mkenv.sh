#!/bin/sh
cd
mkdir .mutt
cd .mutt
mkdir cache
mkdir sent
mkdir temp
ln -sf ~/myConfigs/mutt/muttrc.general muttrc.general
ln -sf ~/myConfigs/mutt/muttrc.imap muttrc.imap
ln -sf ~/myConfigs/mutt/muttrc.local muttrc.local
ln -sf ./muttrc.imap muttrc

ln -sf ~/myConfigs/mutt/signature sig
ln -sf ~/myConfigs/mutt/mailcap mailcap
ln -sf ~/myConfigs/solarized/mutt-colors-solarized/ mutt-colors-solarized
ln -sf ~/myConfigs/mutt/mutt_get_imap_passwd.py mutt_get_imap_passwd.py

cd
ln -sf ~/myConfigs/mutt/goobookrc .goobookrc

# In python shell, use:
# import keyring
# keyring.set_password("gmail","yusiwen@gmail.com","XXXX")
#  to set password for mutt and goobook
