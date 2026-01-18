#!/bin/bash
# test-capture.sh - Test capture card functionality

VIDEO_DEVICE="${VIDEO_DEVICE:-/dev/video0}"

echo "=== Testing Capture Card ==="
echo "Device: $VIDEO_DEVICE"
echo

# Check if device exists
if [ ! -e "$VIDEO_DEVICE" ]; then
    echo "ERROR: Device $VIDEO_DEVICE not found"
    echo "Available devices:"
    ls -l /dev/video* 2>/dev/null || echo "No video devices found"
    exit 1
fi

# List device info
echo "[1] Device Information:"
v4l2-ctl --device="$VIDEO_DEVICE" --all

echo
echo "[2] Supported Formats:"
v4l2-ctl --device="$VIDEO_DEVICE" --list-formats

echo
echo "[3] Current Input:"
v4l2-ctl --device="$VIDEO_DEVICE" --get-input

echo
echo "[4] Testing capture (10 seconds)..."
echo "Displaying captured video. Press Ctrl+C to stop early."
echo

ffmpeg -f v4l2 \
  -framerate 60 \
  -video_size 1920x1080 \
  -i "$VIDEO_DEVICE" \
  -t 10 \
  -f null - \
  2>&1 | grep -E "(Input|Stream|Duration|bitrate)"

echo
echo "[5] Quick preview test (3 seconds)..."
ffplay -f v4l2 -framerate 60 -video_size 1920x1080 -i "$VIDEO_DEVICE" -t 3 -autoexit

echo
echo "=== Test Complete ==="
