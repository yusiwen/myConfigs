#!/usr/bin/env fish

# {{{ Distribution Information
# Determine OS platform
if test -n "$WINDIR"
  set OS 'Windows_NT'
else
  set OS $(uname)
end
export OS
# If Linux, try to determine specific distribution
if test "$OS" = 'Linux'
  # If available, use LSB to identify distribution
  if test -f /etc/lsb-release || test -d /etc/lsb-release.d
    set DISTRO $(lsb_release -i | cut -d: -f2 | sed s/'^\t'//)
  # Otherwise, use release info file
  else
    set DISTRO $(awk -F= '/^NAME/{print $2}' /etc/os-release | xargs | cut -d ' ' -f1)
  end 
end
# For everything else (or if above failed), just use generic identifier
if test -z "$DISTRO"
  set DISTRO $OS
end
export DISTRO
#}}}

set -l OPT_PATH /opt
# Mount /opt on Windows
if test "$OS" = 'Windows_NT' && test "$(uname -o)" = 'Msys'
  set -l OPT_WIN_PATH ''
  if test -d "/d/opt"
    set OPT_WIN_PATH 'D:/opt'
  else if test -d "/e/opt"
    set OPT_WIN_PATH 'E:/opt'
  end 
  mkdir -p "$OPT_PATH"

  if test -n "$OPT_WIN_PATH"
    mount -fo binary,noacl,posix=0,user "$OPT_WIN_PATH" "$OPT_PATH"
  end
end

# Locale {{{
if test -z "$LC_COLLATE"
  export LC_COLLATE=en_US.UTF-8
end
if test -z "$LC_CTYPE"
  export LC_CTYPE=en_US.UTF-8
end
if test -z "$LC_MESSAGES"
  export LC_MESSAGES=en_US.UTF-8
end
if test -z "$LC_MONETARY"
  export LC_MONETARY=en_US.UTF-8
end
if test -z "$LC_NUMERIC"
  export LC_NUMERIC=en_US.UTF-8
end
if test -z "$LC_TIME"
  export LC_TIME=en_US.UTF-8
end
if test -z "$LC_ALL"
  export LC_ALL=en_US.UTF-8
end

if test -z "$LANG"
  export LANG=en_US.UTF-8
  export LANGUAGE=en_US.UTF-8
end
# }}}

# vim: foldmethod=marker :