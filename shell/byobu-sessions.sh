#!/usr/bin/env bash

if ! type byobu >/dev/null 2>&1; then
  exit 0
fi

session_name=$1
if [ -z "$session_name" ]; then
  session_name='remote'
fi

# Test if there's a session already set up
if ! byobu list-sessions 2>&1 | grep -q "$session_name"; then
    # Create a new detached session named 'jupyter'
    byobu new-session -d -s "$session_name"
fi
# Attach to the session
byobu attach-session -t "$session_name"
