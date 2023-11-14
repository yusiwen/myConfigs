#!/usr/bin/env bash

session_name=$1
if [ -z "$session_name" ]; then
  session_name='remote'
fi

# Test if there's a session already set up
if ! byobu list-sessions | grep -q "$session_name"; then
    # Create a new detached session named 'jupyter'
    byobu new-session -d -s "$session_name"
fi
# Attach to the session
byobu attach-session -t "$session_name"
