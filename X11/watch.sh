#!/usr/bin/env bash

if ! type watchman >/dev/null 2>&1; then
  watchman watch /usr/share/regolith/i3/config.d
  watchman -- trigger /usr/share/regolith/i3/config.d 'regolith-trigger' '**/*' -- /opt/backup.sh regolith

  watchman watch /usr/share/regolith-look
  watchman -- trigger /usr/share/regolith-look 'regolith-look-trigger' '**/*' -- /opt/backup.sh regolith-look

  watchman watch /etc/wireguard
  watchman -- trigger /etc/wireguard 'wireguard-trigger' '**/*' -- /opt/backup.sh wireguard

  watchman watch ~/.ssh
  watchman -- trigger ~/.ssh 'ssh-trigger' '**/*' -- /opt/backup.sh ssh

  watchman watch ~/.config/netprofiles
  watchman -- trigger ~/.config/netprofiles 'netprofiles-trigger' '**/*' -- /opt/backup.sh netprofiles
fi