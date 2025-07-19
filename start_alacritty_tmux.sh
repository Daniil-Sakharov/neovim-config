#!/bin/bash
# Start Alacritty with tmux session

# Check if we're in a graphical environment
if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
    echo "No display detected. Starting tmux in current terminal..."
    ./start_tmux.sh
    exit 0
fi

# Check if Alacritty is available
if ! command -v alacritty &> /dev/null; then
    echo "Alacritty not found. Starting tmux in current terminal..."
    ./start_tmux.sh
    exit 0
fi

# Start Alacritty with tmux
echo "Starting Alacritty with tmux..."
alacritty -e bash -c "cd ~ && tmux new-session -A -s main || tmux attach-session -t main"