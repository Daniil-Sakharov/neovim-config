#!/bin/bash
# Quick tmux startup script

SESSION_NAME="dev"

# Check if session already exists
if tmux has-session -t $SESSION_NAME 2>/dev/null; then
    echo "Session $SESSION_NAME already exists. Attaching..."
    tmux attach-session -t $SESSION_NAME
    exit 0
fi

# Create new session with initial window
tmux new-session -d -s $SESSION_NAME -n "main"

# Create additional windows
tmux new-window -t $SESSION_NAME -n "term"
tmux new-window -t $SESSION_NAME -n "git"

# Split the main window
tmux split-window -h -t $SESSION_NAME:main
tmux split-window -v -t $SESSION_NAME:main.0

# Set up initial commands for each pane
tmux send-keys -t $SESSION_NAME:main.0 "nvim" C-m
tmux send-keys -t $SESSION_NAME:main.1 "ls -la" C-m
tmux send-keys -t $SESSION_NAME:main.2 "htop" C-m

# Select the main window
tmux select-window -t $SESSION_NAME:main

# Attach to the session
echo "Starting tmux session: $SESSION_NAME"
tmux attach-session -t $SESSION_NAME