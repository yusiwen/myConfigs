#!/bin/sh

MAIL_CONFIG=$HOME/myConfigs/mail
MUTT_CONFIG=$MAIL_CONFIG/mutt
MUTT_HOME=$HOME/.mutt

mkdir -p $MUTT_HOME
mkdir -p $MUTT_HOME/cache
mkdir -p $MUTT_HOME/sent
mkdir -p $MUTT_HOME/temp

ln -sf $MUTT_CONFIG/muttrc.general $MUTT_HOME/muttrc.general
ln -sf $MUTT_CONFIG/muttrc.imap.gmail $MUTT_HOME/muttrc.imap
ln -sf $MUTT_CONFIG/muttrc.local $MUTT_HOME/muttrc.local
ln -sf $MUTT_HOME/muttrc.imap $MUTT_HOME/muttrc

ln -sf $MUTT_CONFIG/signature $MUTT_HOME/sig
ln -sf $MUTT_CONFIG/mailcap $MUTT_HOME/mailcap
ln -sf $MUTT_CONFIG/mutt_get_imap_passwd.py $MUTT_HOME/mutt_get_imap_passwd.py

ln -sf $MUTT_CONFIG/themes/jellybeans.muttrc $MUTT_HOME/theme.muttrc

# goobook
ln -sf $MAIL_CONFIG/goobook/goobookrc $HOME/.goobookrc

# msmtp
ln -sf $MAIL_CONFIG/msmtp/msmtprc $HOME/.msmtprc

# sup
SUP_CONFIG=$MAIL_CONFIG/sup
SUP_HOME=$HOME/.sup

mkdir -p $SUP_HOME
ln -sf $SUP_CONFIG/config.yaml $SUP_HOME/config.yaml
ln -sf $SUP_CONFIG/sources.yaml $SUP_HOME/sources.yaml
mkdir -p $SUP_HOME/hooks
ln -sf $SUP_CONFIG/hooks/before-poll.rb $SUP_HOME/hooks/before-poll.rb

# offlineimap
OFFLINEIMAP_CONFIG=$HOME/myConfigs/mail/offlineimap
OFFLINEIMAP_HOME=$HOME/.offlineimap

mkdir -p $OFFLINEIMAP_HOME
ln -sf $OFFLINEIMAP_CONFIG/offlineimaprc $HOME/.offlineimaprc
ln -sf $OFFLINEIMAP_CONFIG/offlineimap_scripts.py $OFFLINEIMAP_HOME/offlineimap_scripts.py
ln -sf $OFFLINEIMAP_CONFIG/notmuch-config $HOME/.notmuch-config
mkdir -p $HOME/.mail

# In python shell, use:
# import keyring
# keyring.set_password("gmail","yusiwen@gmail.com","XXXX")
#  to set password for mutt and goobook
