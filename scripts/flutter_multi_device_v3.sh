#!/bin/bash

# Flutter Multi-Device Runner v3 - Using tmux layout for reliable pane creation
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
        
        # macOS 디바이스는 건너뛰기
        if [[ $device_name == *"macOS"* ]] || [[ $device_name == *"Mac"* ]]; then
            continue
        fi
        
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

# Create new tmux session with first device
print_info "Creating tmux session: $SESSION_NAME"
device_id="${DEVICE_IDS[0]}"
device_name="${DEVICE_NAMES[0]}"

# Create session with first device
tmux new-session -d -s $SESSION_NAME -n "devices" -c "$PROJECT_DIR" \
    "echo '=== Device: $device_name ===' && echo 'ID: $device_id' && echo 'Starting Flutter...' && flutter run -d $device_id"

# Add remaining devices by splitting windows
for ((i=1; i<$DEVICE_COUNT; i++)); do
    device_id="${DEVICE_IDS[$i]}"
    device_name="${DEVICE_NAMES[$i]}"
    
    print_info "Setting up device $((i+1)): $device_name"
    
    # Always split from the session target, not specific pane
    tmux split-window -t $SESSION_NAME:devices -c "$PROJECT_DIR" \
        "echo '=== Device: $device_name ===' && echo 'ID: $device_id' && echo 'Starting Flutter...' && flutter run -d $device_id"
done

# Apply tiled layout to arrange all panes evenly
if [ $DEVICE_COUNT -gt 1 ]; then
    tmux select-layout -t $SESSION_NAME:devices tiled
fi

# Create control window
tmux new-window -t $SESSION_NAME -n "control" -c "$PROJECT_DIR"
tmux send-keys -t $SESSION_NAME:control "echo 'Control Window'" C-m
tmux send-keys -t $SESSION_NAME:control "echo ''" C-m
tmux send-keys -t $SESSION_NAME:control "echo 'Flutter commands (use in device panes):'" C-m
tmux send-keys -t $SESSION_NAME:control "echo '  r - Hot Reload'" C-m
tmux send-keys -t $SESSION_NAME:control "echo '  R - Hot Restart'" C-m
tmux send-keys -t $SESSION_NAME:control "echo '  q - Quit app'" C-m
tmux send-keys -t $SESSION_NAME:control "echo ''" C-m
tmux send-keys -t $SESSION_NAME:control "echo 'Running on $DEVICE_COUNT devices:'" C-m

for i in "${!DEVICE_NAMES[@]}"; do
    tmux send-keys -t $SESSION_NAME:control "echo '  $((i+1)). ${DEVICE_NAMES[$i]} (${DEVICE_IDS[$i]})'" C-m
done

tmux send-keys -t $SESSION_NAME:control "echo ''" C-m
tmux send-keys -t $SESSION_NAME:control "echo 'tmux shortcuts:'" C-m
tmux send-keys -t $SESSION_NAME:control "echo '  Ctrl+a → arrow keys: Navigate panes'" C-m
tmux send-keys -t $SESSION_NAME:control "echo '  Ctrl+a → 0/1: Switch windows'" C-m
tmux send-keys -t $SESSION_NAME:control "echo '  Ctrl+a → d: Detach session'" C-m

# Go back to devices window
tmux select-window -t $SESSION_NAME:devices

# Success message
print_success "All $DEVICE_COUNT devices are starting up!"
echo ""
echo "Layout: $DEVICE_COUNT panes in tiled arrangement"
echo ""
print_info "Navigation:"
print_info "  Alt + Arrow keys: Quick pane navigation"
print_info "  Ctrl+a → Arrow keys: Navigate between panes"
print_info "  Ctrl+a → 0: Devices window"
print_info "  Ctrl+a → 1: Control window"
print_info "  Ctrl+a → d: Detach from session"

# Attach to session
tmux attach-session -t $SESSION_NAME