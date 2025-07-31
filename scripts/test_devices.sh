#!/bin/bash

echo "=== Testing Flutter Device Detection ==="
echo ""

# Get raw flutter devices output
echo "1. Raw output from 'flutter devices':"
echo "-----------------------------------"
flutter devices
echo ""

# Get machine readable output
echo "2. Parsing device information:"
echo "-----------------------------------"

# Method 1: Parse human readable output
echo "Method 1 - Parsing text output:"
flutter devices 2>/dev/null | grep "•" | while IFS= read -r line; do
    # Extract device name (before first •)
    device_name=$(echo "$line" | awk -F'•' '{print $1}' | xargs)
    
    # Extract device ID (between first and second •)
    device_id=$(echo "$line" | awk -F'•' '{print $2}' | xargs | awk '{print $1}')
    
    # Extract platform (between second and third •)
    platform=$(echo "$line" | awk -F'•' '{print $3}' | xargs | awk '{print $1}')
    
    echo "  Device: $device_name"
    echo "  ID: $device_id"
    echo "  Platform: $platform"
    echo "  Command: flutter run -d $device_id"
    echo ""
done

# Method 2: Try to get specific known devices
echo "Method 2 - Looking for specific devices:"
echo ""

# Check for Chrome
if flutter devices 2>/dev/null | grep -q "Chrome"; then
    echo "Chrome detected!"
    chrome_line=$(flutter devices 2>/dev/null | grep "Chrome")
    chrome_id=$(echo "$chrome_line" | awk -F'•' '{print $2}' | xargs | awk '{print $1}')
    echo "Chrome ID: $chrome_id"
    echo "Command: flutter run -d $chrome_id"
else
    echo "Chrome not detected"
fi
echo ""

# Check for Android
if flutter devices 2>/dev/null | grep -q -E "(emulator|android)"; then
    echo "Android device detected!"
    android_line=$(flutter devices 2>/dev/null | grep -E "(emulator|android)")
    android_id=$(echo "$android_line" | awk -F'•' '{print $2}' | xargs | awk '{print $1}')
    echo "Android ID: $android_id"
    echo "Command: flutter run -d $android_id"
else
    echo "Android device not detected"
fi
echo ""

# Check for macOS
if flutter devices 2>/dev/null | grep -q "macOS"; then
    echo "macOS detected!"
    macos_line=$(flutter devices 2>/dev/null | grep "macOS")
    macos_id=$(echo "$macos_line" | awk -F'•' '{print $2}' | xargs | awk '{print $1}')
    echo "macOS ID: $macos_id"
    echo "Command: flutter run -d $macos_id"
else
    echo "macOS not detected"
fi

echo ""
echo "=== End of test ==="