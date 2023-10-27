#!/bin/bash
    
session=$1
window1=$2
pane1=$3
pane2=$4
pane3=$5
pane4=$6
window2=$7
window3=$8
    
#Get width and lenght size of terminal, this is needed if one wants to resize a detached session/window/pane
#with resize-pane command here
set -- $(stty size) #$1=rows, $2=columns

#start a new session in dettached mode with resizable panes
tmux new-session -s $session -n $window1 -d -x "$2" -y "$(($1 - 1))"
    
#rename pane 0 with value of $pane1
tmux set -p @mytitle "$pane1"

#split window vertically
tmux split-window -h
tmux set -p @mytitle "$pane2"

tmux split-window -v
tmux set -p @mytitle "$pane3"

tmux select-pane -t 0
tmux split-window -v
tmux set -p @mytitle "$pane4"

tmux send-keys -t 0 'btop' C-m

# Second window
tmux new-window -n $window2 
#rename pane 0 with value of $pane1
tmux set -p @mytitle "$pane1"

#split window vertically
tmux split-window -h
tmux set -p @mytitle "$pane2"

tmux split-window -v
tmux set -p @mytitle "$pane3"

tmux select-pane -t 0
tmux split-window -v
tmux set -p @mytitle "$pane4"

tmux select-window -t 0

# Third window
tmux new-window -n $window3 
#rename pane 0 with value of $pane1
tmux set -p @mytitle "$pane1"

#split window vertically
tmux split-window -h
tmux set -p @mytitle "$pane2"

tmux split-window -v
tmux set -p @mytitle "$pane3"

tmux select-pane -t 0
tmux split-window -v
tmux set -p @mytitle "$pane4"

tmux select-window -t 0

#At the end, attach to the customized session
tmux attach -t $session
