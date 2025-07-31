#!/bin/bash

# Flutter Multi-Device Runner for Versus Space
# This script runs the Flutter app on multiple devices simultaneously using tmux

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project directory
PROJECT_DIR="/Users/g_black/versus-cursor"

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if tmux is installed
if ! command -v tmux &> /dev/null; then
    print_error "tmux is not installed. Please install it first."
    exit 1
fi

# Check if flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "flutter is not installed. Please install it first."
    exit 1
fi

# Navigate to project directory
cd "$PROJECT_DIR" || exit 1

print_info "Getting available devices..."

# Get device information using flutter devices
DEVICE_OUTPUT=$(flutter devices 2>/dev/null | grep "•")
DEVICE_COUNT=$(echo "$DEVICE_OUTPUT" | grep -c "•" || echo "0")

if [ "$DEVICE_COUNT" -eq 0 ]; then
    print_error "No devices found. Please connect devices or start emulators/simulators."
    exit 1
fi

print_info "Found $DEVICE_COUNT device(s):"
echo "$DEVICE_OUTPUT"

# Extract device IDs from the output
# Device ID is the second field after splitting by •
DEVICES=$(echo "$DEVICE_OUTPUT" | while read line; do
    # Split by • and get the second field (device ID)
    device_id=$(echo "$line" | awk -F'•' '{print $2}' | xargs | awk '{print $1}')
    echo "$device_id"
done)

print_info "Extracted device IDs:"
echo "$DEVICES"

# Create or attach to tmux session
SESSION_NAME="versus-flutter"

# Kill existing session if it exists
tmux kill-session -t $SESSION_NAME 2>/dev/null

# Create new session
print_info "Creating new tmux session: $SESSION_NAME"
tmux new-session -d -s $SESSION_NAME -n "devices" -c "$PROJECT_DIR"

# Counter for pane creation
PANE_COUNT=0

# Create panes for each device
PANE_COUNT=0
while IFS= read -r DEVICE_ID; do
    if [ -n "$DEVICE_ID" ]; then
        PANE_COUNT=$((PANE_COUNT + 1))
        
        # Get device name from the output
        DEVICE_NAME=$(echo "$DEVICE_OUTPUT" | grep "$DEVICE_ID" | awk -F'•' '{print $1}' | xargs)
        
        print_info "Setting up pane for device: $DEVICE_NAME ($DEVICE_ID)"
        
        if [ $PANE_COUNT -eq 1 ]; then
            # Use the first pane
            tmux send-keys -t $SESSION_NAME:devices.0 "echo 'Device: $DEVICE_NAME'" C-m
            tmux send-keys -t $SESSION_NAME:devices.0 "flutter run -d $DEVICE_ID" C-m
        elif [ $PANE_COUNT -eq 2 ]; then
            # Split horizontally for second device
            tmux split-window -h -t $SESSION_NAME:devices -c "$PROJECT_DIR"
            tmux send-keys -t $SESSION_NAME:devices.1 "echo 'Device: $DEVICE_NAME'" C-m
            tmux send-keys -t $SESSION_NAME:devices.1 "flutter run -d $DEVICE_ID" C-m
        elif [ $PANE_COUNT -eq 3 ]; then
            # Split vertically for third device
            tmux split-window -v -t $SESSION_NAME:devices.0 -c "$PROJECT_DIR"
            tmux send-keys -t $SESSION_NAME:devices.2 "echo 'Device: $DEVICE_NAME'" C-m
            tmux send-keys -t $SESSION_NAME:devices.2 "flutter run -d $DEVICE_ID" C-m
        elif [ $PANE_COUNT -eq 4 ]; then
            # Split the second pane vertically for fourth device
            tmux split-window -v -t $SESSION_NAME:devices.1 -c "$PROJECT_DIR"
            tmux send-keys -t $SESSION_NAME:devices.3 "echo 'Device: $DEVICE_NAME'" C-m
            tmux send-keys -t $SESSION_NAME:devices.3 "flutter run -d $DEVICE_ID" C-m
        else
            # For more than 4 devices, create new windows
            WINDOW_NUM=$((PANE_COUNT / 4))
            tmux new-window -t $SESSION_NAME -n "devices-$WINDOW_NUM" -c "$PROJECT_DIR"
            tmux send-keys -t $SESSION_NAME:devices-$WINDOW_NUM "echo 'Device: $DEVICE_NAME' && flutter run -d $DEVICE_ID" C-m
        fi
    fi
done <<< "$DEVICES"

# Select even layout for better view
tmux select-layout -t $SESSION_NAME:devices tiled

# Create a control window
tmux new-window -t $SESSION_NAME -n "control" -c "$PROJECT_DIR"
tmux send-keys -t $SESSION_NAME:control "echo 'Control Window - Use this for git, editing, etc.'" C-m
tmux send-keys -t $SESSION_NAME:control "echo ''" C-m
tmux send-keys -t $SESSION_NAME:control "echo 'Hot Reload: Press \"r\" in any flutter run pane'" C-m
tmux send-keys -t $SESSION_NAME:control "echo 'Hot Restart: Press \"R\" in any flutter run pane'" C-m
tmux send-keys -t $SESSION_NAME:control "echo 'Quit: Press \"q\" in any flutter run pane'" C-m

# Go back to first window
tmux select-window -t $SESSION_NAME:devices

# Attach to session
print_success "All devices are launching. Attaching to tmux session..."
print_info "Use Ctrl+a followed by arrow keys to navigate between panes"
print_info "Use Ctrl+a followed by 0/1/2... to switch windows"
print_info "Use Ctrl+a followed by d to detach from session"

tmux attach-session -t $SESSION_NAME