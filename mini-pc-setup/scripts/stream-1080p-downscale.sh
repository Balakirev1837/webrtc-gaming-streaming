#!/bin/bash
# stream-1080p-downscale.sh - 1440p@144Hz → 1080p@60Hz downscaling

STREAM_KEY="${STREAM_KEY:-gaming}"
SERVER_URL="${SERVER_URL:-http://localhost:8080/api/whip}"
VIDEO_DEVICE="${VIDEO_DEVICE:-/dev/video0}"

echo "=== 1440p@144Hz → 1080p@60Hz Streaming ==="
echo "Stream Key: $STREAM_KEY"
echo "Server: $SERVER_URL"
echo "Video Device: $VIDEO_DEVICE"
echo "Downscaling: 1440p → 1080p, 144Hz → 60Hz"
echo

# Video: Capture at 1440p@144Hz, downscale to 1080p@60Hz, encode with AV1
# Audio: High quality Opus encoding

gst-launch-1.0 \
  v4l2src device="$VIDEO_DEVICE" \
  ! video/x-raw,width=2560,height=1440,framerate=144/1 \
  ! videoconvert ! 'video/x-raw,format=I420' \
  ! queue max-size-buffers=2 max-size-time=0 max-size-bytes=4194304 leaky=1 \
  ! videoscale method=0 add-borders=true \
  ! video/x-raw,width=1920,height=1080,framerate=60/1 \
  ! queue max-size-buffers=2 max-size-time=0 max-size-bytes=2097152 leaky=1 \
  ! svtav1enc \
      preset=10 \
      bitrate=6000 \
      tune=1 \
      rc-mode=1 \
      threads=4 \
      tier=1 \
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
  ! queue max-size-buffers=1 max-size-time=0 max-size-bytes=131072 leaky=1 \
  ! opusenc bitrate=192000 \
      audio-type=generic \
      frame-size=20 \
      inband-fec=false \
      complexity=8 \
  ! rtpopuspay pt=97 \
  ! queue max-size-buffers=1 max-size-time=0 max-size-bytes=65536 \
  ! application/x-rtp,media=audio,encoding-name=OPUS,payload=97,clock-rate=48000 \
  ! whip0.sink_1 \
  \
  whipsink name=whip0 \
    use-link-headers=true \
    whip-endpoint="$SERVER_URL" \
    auth-token="$STREAM_KEY"
