#!/usr/bin/env bash

### remove unnecessary Win PATHs
# This can prevent extension-less commands from bleeding into BASH.
# (eg. "ng" would execute the Win bin if "@angular/cli" wasn't installed on Linux.)
#
function path_remove {
  # Delete path by parts so we can never accidentally remove sub paths
  PATH=${PATH//":$1:"/":"} # delete any instances in the middle
  PATH=${PATH/#"$1:"/} # delete any instance at the beginning
  PATH=${PATH/%":$1"/} # delete any instance in the at the end
}

path_remove '/mnt/d/opt/runtimes/nodejs'
path_remove '/mnt/d/opt/apps/nvm'

export PATH
