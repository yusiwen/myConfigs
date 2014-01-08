#!/bin/sh
# Workaround for LP: ##932177
#
#   If you have gnome-keyring package installed gnome-keyring-daemon
#   is started for lightdm by pam_gnome_keyring (package libpam-gnome-keyring),
#   but not initialized, at least in 12.04..13.04.
#   
#   This script finishes gnome-keyring-daemon initialization as described in
#     https://wiki.gnome.org/GnomeKeyring/RunningDaemon
#
#   By default gnome-keyring-daemon provides ssh, gpg, pkcs11 and secrets services.
#   This script uses all of them, overriding existing environment. If you prefer
#   ssh-agent, gpg-agent or ksecretsservice, you need to modify the script.
#   

if [ -n "$GNOME_KEYRING_PID" ]; then
    eval $(/usr/bin/gnome-keyring-daemon --start --components=gpg,pkcs11,secrets,ssh)

    for k in GNOME_KEYRING_CONTROL SSH_AUTH_SOCK GPG_AGENT_INFO; do
        eval v=\$$k
        eval [ -n "$v" ] && export $k
    done

fi

