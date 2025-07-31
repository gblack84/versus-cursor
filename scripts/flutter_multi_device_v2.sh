#!/bin/bash

# Flutter Multi-Device Runner v2 - Simplified and More Reliable
# This script runs Flutter app on all connected devices

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

# Navigate to project directory
cd "$PROJECT_DIR" || exit 1

# Session name
SESSION_NAME="versus-flutter"

# Kill existing session if it exists
tmux kill-session -t $SESSION_NAME 2>/dev/null

print_info "Checking for Flutter devices..."

# Create arrays to store device info
declare -a DEVICE_IDS
declare -a DEVICE_NAMES
DEVICE_COUNT=0

# Parse flutter devices output line by line
while IFS= read -r line; do
    if [[ $line == *"•"* ]]; then
        # Extract device ID (second field when split by •)
        device_id=$(echo "$line" | awk -F'•' '{print $2}' | xargs | awk '{print $1}')
        # Extract device name (first field when split by •)
        device_name=$(echo "$line" | awk -F'•' '{print $1}' | xargs)
        
        if [ -n "$device_id" ]; then
            DEVICE_IDS[$DEVICE_COUNT]="$device_id"
            DEVICE_NAMES[$DEVICE_COUNT]="$device_name"
            DEVICE_COUNT=$((DEVICE_COUNT + 1))
            print_info "Found device: $device_name (ID: $device_id)"
        fi
    fi
done < <(flutter devices 2>/dev/null)

if [ $DEVICE_COUNT -eq 0 ]; then
    print_error "No devices found. Please connect devices or start emulators/simulators."
    exit 1
fi

print_success "Found $DEVICE_COUNT device(s)"

# Create new tmux session
print_info "Creating tmux session: $SESSION_NAME"
tmux new-session -d -s $SESSION_NAME -n "devices" -c "$PROJECT_DIR"

# Create panes and run Flutter for each device
for i in "${!DEVICE_IDS[@]}"; do
    device_id="${DEVICE_IDS[$i]}"
    device_name="${DEVICE_NAMES[$i]}"
    
    print_info "Setting up device $((i+1)): $device_name"
    
    if [ $i -eq 0 ]; then
        # First device uses the existing pane
        tmux send-keys -t $SESSION_NAME:devices "echo '=== Device: $device_name ==='" C-m
        tmux send-keys -t $SESSION_NAME:devices "echo 'ID: $device_id'" C-m
        tmux send-keys -t $SESSION_NAME:devices "echo 'Starting Flutter...'" C-m
        tmux send-keys -t $SESSION_NAME:devices "flutter run -d $device_id" C-m
    elif [ $i -eq 1 ]; then
        # Second device: split horizontally
        tmux split-window -h -t $SESSION_NAME:devices -c "$PROJECT_DIR"
        tmux send-keys -t $SESSION_NAME:devices.1 "echo '=== Device: $device_name ==='" C-m
        tmux send-keys -t $SESSION_NAME:devices.1 "echo 'ID: $device_id'" C-m
        tmux send-keys -t $SESSION_NAME:devices.1 "echo 'Starting Flutter...'" C-m
        tmux send-keys -t $SESSION_NAME:devices.1 "flutter run -d $device_id" C-m
    elif [ $i -eq 2 ]; then
        # Third device: split first pane vertically
        tmux split-window -v -t $SESSION_NAME:devices.0 -c "$PROJECT_DIR"
        tmux send-keys -t $SESSION_NAME:devices.2 "echo '=== Device: $device_name ==='" C-m
        tmux send-keys -t $SESSION_NAME:devices.2 "echo 'ID: $device_id'" C-m
        tmux send-keys -t $SESSION_NAME:devices.2 "echo 'Starting Flutter...'" C-m
        tmux send-keys -t $SESSION_NAME:devices.2 "flutter run -d $device_id" C-m
    elif [ $i -eq 3 ]; then
        # Fourth device: split second pane vertically
        tmux split-window -v -t $SESSION_NAME:devices.1 -c "$PROJECT_DIR"
        tmux send-keys -t $SESSION_NAME:devices.3 "echo '=== Device: $device_name ==='" C-m
        tmux send-keys -t $SESSION_NAME:devices.3 "echo 'ID: $device_id'" C-m
        tmux send-keys -t $SESSION_NAME:devices.3 "echo 'Starting Flutter...'" C-m
        tmux send-keys -t $SESSION_NAME:devices.3 "flutter run -d $device_id" C-m
    else
        # More than 4 devices: create new window
        print_warning "Device $device_name will be in a new window (more than 4 devices)"
        tmux new-window -t $SESSION_NAME -n "device-$((i+1))" -c "$PROJECT_DIR"
        tmux send-keys -t $SESSION_NAME:"device-$((i+1))" "echo '=== Device: $device_name ==='" C-m
        tmux send-keys -t $SESSION_NAME:"device-$((i+1))" "flutter run -d $device_id" C-m
    fi
done

# Adjust layout for better view
if [ $DEVICE_COUNT -gt 1 ]; then
    tmux select-layout -t $SESSION_NAME:devices tiled
fi

# Create control window
tmux new-window -t $SESSION_NAME -n "control" -c "$PROJECT_DIR"
tmux send-keys -t $SESSION_NAME:control "echo 'Control Window'" C-m
tmux send-keys -t $SESSION_NAME:control "echo ''" C-m
tmux send-keys -t $SESSION_NAME:control "echo 'Commands:'" C-m
tmux send-keys -t $SESSION_NAME:control "echo '  r - Hot Reload'" C-m
tmux send-keys -t $SESSION_NAME:control "echo '  R - Hot Restart'" C-m
tmux send-keys -t $SESSION_NAME:control "echo '  q - Quit app'" C-m
tmux send-keys -t $SESSION_NAME:control "echo ''" C-m
tmux send-keys -t $SESSION_NAME:control "echo 'Devices running:'" C-m

for i in "${!DEVICE_NAMES[@]}"; do
    tmux send-keys -t $SESSION_NAME:control "echo '  $((i+1)). ${DEVICE_NAMES[$i]} (${DEVICE_IDS[$i]})'" C-m
done

# Go back to devices window
tmux select-window -t $SESSION_NAME:devices

# Success message
print_success "All devices are starting up!"
print_info "tmux shortcuts:"
print_info "  Ctrl+a → arrow keys: Navigate between panes"
print_info "  Ctrl+a → 0/1: Switch between windows"
print_info "  Ctrl+a → d: Detach from session"

# Attach to session
tmux attach-session -t $SESSION_NAME