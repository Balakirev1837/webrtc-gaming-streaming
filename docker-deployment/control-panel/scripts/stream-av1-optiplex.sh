#!/bin/bash
# stream-av1-optiplex.sh - Optimized AV1 streaming for Intel OptiPlex 7070-570X4
# Captures at 1440p@144Hz and downscales directly to 720p@60Hz for optimal CPU efficiency

set -e

STREAM_KEY="${STREAM_KEY:-gaming}"
SERVER_URL="${SERVER_URL:-http://localhost:8080/api/whip}"
VIDEO_DEVICE="${VIDEO_DEVICE:-/dev/video0}"

# Optimized for OptiPlex Pentium G3250T (4 cores, 3.5GHz, 8 threads)
# Direct downscale: 1440p@144Hz → 720p@60Hz (2.07M → 0.92M pixels = 55% reduction)
RESOLUTION="${RESOLUTION:-1280x720}"
FPS="${FPS:-60}"
BITRATE="${BITRATE:-4000}"

echo "=== Optimized AV1 Streaming for OptiPlex ==="
echo "CPU: Intel Pentium G3250T (4 cores, 3.5GHz)"
echo "Capture: 2560x1440 @ 144Hz"
echo "Output: 720p @ 60Hz"
echo "Bitrate: ${BITRATE} Kbps"
echo "CPU Estimate: 45-60%"
echo

# Validate video device exists
if [ ! -e "$VIDEO_DEVICE" ]; then
    echo "ERROR: Video device not found: $VIDEO_DEVICE"
    echo "Please check:"
    echo "  1. Capture card is connected"
    echo "  2. User has permissions: sudo usermod -a -G video \$USER"
    echo "  3. Device is detected: ls -l /dev/video*"
    exit 1
fi

# Validate Broadcast Box is running
if ! curl -s --connect-timeout 3 "$SERVER_URL" > /dev/null 2>&1; then
    echo "WARNING: Broadcast Box may not be running at $SERVER_URL"
    echo "Attempting to start stream anyway..."
    echo
fi

# Check for required GStreamer plugins
REQUIRED_PLUGINS="v4l2src svtav1enc av1parse rtpav1pay whipsink pulsesrc opusenc rtpopuspay"
for plugin in $REQUIRED_PLUGINS; do
    if ! gst-inspect-1.0 "$plugin" > /dev/null 2>&1; then
        echo "ERROR: Missing GStreamer plugin: $plugin"
        echo "Please install required packages:"
        echo "  sudo dnf install gstreamer1-plugins-base-tools gstreamer1-plugins-bad-free"
        exit 1
    fi
done

gst-launch-1.0 \
  v4l2src device="$VIDEO_DEVICE" \
  ! video/x-raw,width=2560,height=1440,framerate=144/1 \
  ! videoconvert ! 'video/x-raw,format=I420' \
  ! queue max-size-buffers=2 max-size-time=0 max-size-bytes=1048576 leaky=1 \
  ! videorate drop-only=true \
  ! video/x-raw,framerate=60/1 \
  ! videoscale method=0 add-borders=true n-threads=4 \
  ! video/x-raw,width=1280,height=720 \
  ! queue max-size-buffers=2 max-size-time=0 max-size-bytes=655360 leaky=1 \
  ! svtav1enc \
      preset=10 \
      bitrate=$BITRATE \
      rc-mode=1 \
      threads=4 \
      tier=1 \
      tile-columns=2 \
      tile-rows=1 \
      cpu-used=4 \
      keyframe-interval=2 \
      enable-overlays=0 \
      tune=1 \
  ! av1parse \
  ! rtpav1pay pt=96 \
  ! queue max-size-buffers=2 max-size-time=0 max-size-bytes=1048576 \
  ! application/x-rtp,media=video,encoding-name=AV1,payload=96,clock-rate=90000 \
  ! whip0.sink_0 \
  \
  pulsesrc \
  ! audioconvert \
  ! audioresample \
  ! 'audio/x-raw,rate=48000,channels=2' \
  ! queue max-size-buffers=1 max-size-time=0 max-size-bytes=65536 leaky=1 \
  ! opusenc bitrate=192000 \
      audio-type=generic \
      frame-size=20 \
      inband-fec=false \
      complexity=8 \
  ! rtpopuspay pt=97 \
  ! queue max-size-buffers=1 max-size-time=0 max-size-bytes=32768 \
  ! application/x-rtp,media=audio,encoding-name=OPUS,payload=97,clock-rate=48000 \
  ! whip0.sink_1 \
  \
  whipsink name=whip0 \
    use-link-headers=true \
    whip-endpoint="$SERVER_URL" \
    auth-token="$STREAM_KEY"
