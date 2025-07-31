#!/bin/bash

# Tmux Flutter Development Session Template
# Creates a pre-configured tmux session for Flutter development

PROJECT_DIR="/Users/g_black/versus-cursor"
SESSION_NAME="versus-dev"

# Kill existing session if it exists
tmux kill-session -t $SESSION_NAME 2>/dev/null

# Create new session with main window
tmux new-session -d -s $SESSION_NAME -n "main" -c $PROJECT_DIR

# Window 0: Main development (split into 3 panes)
# Pane 0: Editor/Terminal
tmux send-keys -t $SESSION_NAME:main "echo 'Main Development Terminal'" C-m
tmux send-keys -t $SESSION_NAME:main "echo 'Use this for editing, git commands, etc.'" C-m

# Pane 1: Flutter logs
tmux split-window -h -t $SESSION_NAME:main -c $PROJECT_DIR
tmux send-keys -t $SESSION_NAME:main.1 "echo 'Flutter Logs Window'" C-m
tmux send-keys -t $SESSION_NAME:main.1 "echo 'Run: flutter logs to see device logs'" C-m

# Pane 2: Flutter devices monitoring
tmux split-window -v -t $SESSION_NAME:main.1 -c $PROJECT_DIR
tmux send-keys -t $SESSION_NAME:main.2 "watch -n 5 flutter devices" C-m

# Window 1: Devices (for running on different devices)
tmux new-window -t $SESSION_NAME -n "devices" -c $PROJECT_DIR

# Split for up to 4 devices
tmux split-window -h -t $SESSION_NAME:devices -c $PROJECT_DIR
tmux split-window -v -t $SESSION_NAME:devices.0 -c $PROJECT_DIR
tmux split-window -v -t $SESSION_NAME:devices.1 -c $PROJECT_DIR

# Add instructions to each pane
tmux send-keys -t $SESSION_NAME:devices.0 "echo 'Device 1: Run flutter run -d <device-id>'" C-m
tmux send-keys -t $SESSION_NAME:devices.1 "echo 'Device 2: Run flutter run -d <device-id>'" C-m
tmux send-keys -t $SESSION_NAME:devices.2 "echo 'Device 3: Run flutter run -d <device-id>'" C-m
tmux send-keys -t $SESSION_NAME:devices.3 "echo 'Device 4: Run flutter run -d <device-id>'" C-m

# Set even layout
tmux select-layout -t $SESSION_NAME:devices tiled

# Window 2: Backend/Firebase
tmux new-window -t $SESSION_NAME -n "backend" -c $PROJECT_DIR/firebase/functions

# Split for Firebase functions
tmux split-window -h -t $SESSION_NAME:backend -c $PROJECT_DIR/firebase/functions
tmux send-keys -t $SESSION_NAME:backend.0 "echo 'Firebase Functions Development'" C-m
tmux send-keys -t $SESSION_NAME:backend.0 "echo 'Run: npm run serve to start local emulator'" C-m
tmux send-keys -t $SESSION_NAME:backend.1 "echo 'Firebase Deploy Terminal'" C-m
tmux send-keys -t $SESSION_NAME:backend.1 "echo 'Run: firebase deploy --only functions:<function-name>'" C-m

# Window 3: Testing
tmux new-window -t $SESSION_NAME -n "testing" -c $PROJECT_DIR

# Split for different test types
tmux split-window -h -t $SESSION_NAME:testing -c $PROJECT_DIR
tmux send-keys -t $SESSION_NAME:testing.0 "echo 'Unit Tests'" C-m
tmux send-keys -t $SESSION_NAME:testing.0 "echo 'Run: flutter test'" C-m
tmux send-keys -t $SESSION_NAME:testing.1 "echo 'Integration Tests'" C-m
tmux send-keys -t $SESSION_NAME:testing.1 "echo 'Run: flutter test integration_test'" C-m

# Window 4: Performance
tmux new-window -t $SESSION_NAME -n "performance" -c $PROJECT_DIR
tmux send-keys -t $SESSION_NAME:performance "echo 'Performance Monitoring'" C-m
tmux send-keys -t $SESSION_NAME:performance "echo 'Run: flutter run --profile'" C-m

# Go back to main window
tmux select-window -t $SESSION_NAME:main

# Show session info
echo "Tmux session '$SESSION_NAME' created with the following windows:"
echo "  0: main     - Main development (editor, logs, device monitoring)"
echo "  1: devices  - Run app on multiple devices"
echo "  2: backend  - Firebase functions development"
echo "  3: testing  - Unit and integration tests"
echo "  4: performance - Performance profiling"
echo ""
echo "To attach to the session, run:"
echo "  tmux attach-session -t $SESSION_NAME"
echo ""
echo "Keyboard shortcuts (after Ctrl+a):"
echo "  0-4     : Switch to window 0-4"
echo "  c       : Create new window"
echo "  n/p     : Next/Previous window"
echo "  arrows  : Navigate between panes"
echo "  d       : Detach from session"
echo "  ?       : Show all keybindings"

# Attach to session if not already in tmux
if [ -z "$TMUX" ]; then
    tmux attach-session -t $SESSION_NAME
else
    echo "Already in a tmux session. Use 'tmux switch-client -t $SESSION_NAME' to switch."
fi