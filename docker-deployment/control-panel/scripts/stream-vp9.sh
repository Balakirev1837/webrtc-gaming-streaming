#!/bin/bash
# stream-vp9.sh - Optimized VP9 streaming for Intel OptiPlex 7070-570X4
# Uses libvpx VP9 encoder for excellent CPU efficiency

STREAM_KEY="${STREAM_KEY:-gaming}"
SERVER_URL="${SERVER_URL:-http://localhost:8080/api/whip}"
VIDEO_DEVICE="${VIDEO_DEVICE:-/dev/video0}"

# Optimized for OptiPlex Pentium G3250T (4 cores, 3.5GHz, 8 threads)
# VP9 via libvpx: 20-30% lower CPU than SVT-AV1 for same quality
RESOLUTION="${RESOLUTION:-1280x720}"
FPS="${FPS:-60}"
BITRATE="${BITRATE:-5000}"

# Source queue configuration
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/queue-config.sh"

echo "=== Optimized VP9 Streaming for OptiPlex ==="
echo "CPU: Intel Pentium G3250T (4 cores, 3.5GHz)"
echo "Capture: 2560x1440 @ 144Hz"
echo "Output: 720p @ 60Hz"
echo "Bitrate: ${BITRATE} Kbps"
echo "CPU Estimate: 30-40% (VP9 is 20-30% more efficient than AV1)"
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
REQUIRED_PLUGINS="v4l2src vp9enc rtpvp9pay whipclientsink pulsesrc opusenc rtpopuspay"
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
  ! $QUEUE_VIDEO_LOW_RES \
  ! videorate drop-only=true \
  ! video/x-raw,framerate=60/1 \
  ! videoscale method=0 add-borders=true n-threads=4 \
  ! video/x-raw,width=1280,height=720 \
  ! $QUEUE_VIDEO_LOW_RES \
  ! vp9enc \
      cpu-used=4 \
      target-bitrate=$BITRATE \
      deadline=1 \
      min-quantizer=0 \
      max-quantizer=63 \
      cq-level=10 \
      threads=4 \
      static-threshold=100 \
  ! rtpvp9pay pt=96 \
  ! $QUEUE_RTP \
  ! application/x-rtp,media=video,encoding-name=VP9,payload=96,clock-rate=90000 \
  ! whip0. \
  \
  pulsesrc \
  ! audioconvert \
  ! audioresample \
  ! 'audio/x-raw,rate=48000,channels=2' \
  ! $QUEUE_AUDIO \
  ! opusenc bitrate=192000 \
      audio-type=generic \
      frame-size=20 \
      inband-fec=false \
      complexity=8 \
  ! rtpopuspay pt=97 \
  ! $QUEUE_RTP \
  ! application/x-rtp,media=audio,encoding-name=OPUS,payload=97,clock-rate=48000 \
  ! whip0.sink_1 \
  \
  whipclientsink name=whip0 \
     \
    signaller::signaller::whip-endpoint="$SERVER_URL" \
    signaller::auth-token="$STREAM_KEY"
