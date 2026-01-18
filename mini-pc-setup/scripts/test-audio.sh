#!/bin/bash
# test-audio.sh - Test audio capture

echo "=== Testing Audio Capture ==="
echo

# List PulseAudio sources
echo "[1] Available Audio Sources:"
pactl list sources short

echo
echo "[2] Default Source:"
pactl get-default-source

echo
echo "[3] Testing default source (3 seconds)..."
gst-launch-1.0 pulsesrc ! audioconvert ! autoaudiosink

echo
echo "[4] Testing with explicit source..."
read -p "Enter audio device name (or press Enter for default): " AUDIO_SRC

if [ -z "$AUDIO_SRC" ]; then
    AUDIO_SRC="alsa_output.pci-0000_00_1f.3.analog-stereo.monitor"
    echo "Using default: $AUDIO_SRC"
fi

echo "Testing: $AUDIO_SRC"
gst-launch-1.0 pulsesrc device="$AUDIO_SRC" ! audioconvert ! audioresample ! 'audio/x-raw,rate=48000,channels=2' ! autoaudiosink

echo
echo "=== Test Complete ==="
