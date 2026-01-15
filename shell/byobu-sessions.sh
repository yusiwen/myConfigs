#!/usr/bin/env bash

BIN=
if ! type byobu >/dev/null 2>&1; then
  BIN=tmux
else
  BIN=byobu
fi

session_name=$1
if [ -z "$session_name" ]; then
  session_name='remote'
fi

# Test if there's a session already set up
if ! $BIN list-sessions 2>&1 | grep -q "$session_name"; then
    # Create a new detached session named 'jupyter'
    $BIN new-session -d -s "$session_name"
fi
# Attach to the session
$BIN attach-session -t "$session_name"
