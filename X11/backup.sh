#!/usr/bin/env bash

function backup_regolith() {
  echo "backing up /usr/share/regolith/i3/config.d ..."
  mkdir -p /mnt/data/shares/backup/usr/share/regolith/i3/config.d
  rsync -avzp --delete /usr/share/regolith/i3/config.d/ /mnt/data/shares/backup/usr/share/regolith/i3/config.d
}

function backup_regolith-look() {
  echo "backing up /usr/share/regolith-look ..."
  mkdir -p /mnt/data/shares/backup/usr/share/regolith-look
  rsync -avzp --delete /usr/share/regolith-look/ /mnt/data/shares/backup/usr/share/regolith-look
}

function backup_wireguard() {
  echo "backing up /etc/wireguard ..."
  mkdir -p /mnt/data/shares/backup/etc/wireguard
  rsync -avzp --delete /etc/wireguard/ /mnt/data/shares/backup/etc/wireguard
}

function backup_ssh() {
  echo "backing up ~/.ssh ..."
  mkdir -p /mnt/data/shares/backup/home/"$USERNAME"/.ssh
  rsync -avzp --delete ~/.ssh/ /mnt/data/shares/backup/home/"$USERNAME"/.ssh
}

function backup_netprofiles() {
  echo "backing up ~/.config/netprofiles ..."
  mkdir -p /mnt/data/shares/backup/home/"$USERNAME"/.config/netprofiles
  rsync -avzp --delete ~/.config/netprofiles/ /mnt/data/shares/backup/home/"$USERNAME"/.config/netprofiles
}

function backup_localbin() {
  echo "backing up ~/.local/bin ..."
  mkdir -p /mnt/data/shares/backup/home/"$USERNAME"/.local/bin
  rsync -avzp --delete ~/.local/bin /mnt/data/shares/backup/home/"$USERNAME"/.local/bin
}

case $1 in
regolith) backup_regolith ;;
regolith-look) backup_regolith-look ;;
wireguard) backup_wireguard ;;
ssh) backup_ssh ;;
netprofiles) backup_netprofiles ;;
localbin) backup_localbin ;;
*)
  backup_regolith
  backup_regolith-look
  backup_wireguard
  backup_ssh
  backup_netprofiles
  backup_localbin ;;
esac

