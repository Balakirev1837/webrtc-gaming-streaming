#!/bin/bash
# stream.sh - High-quality WebRTC streaming pipeline

STREAM_KEY="${STREAM_KEY:-gaming}"
SERVER_URL="${SERVER_URL:-http://localhost:8080/api/whip}"
VIDEO_DEVICE="${VIDEO_DEVICE:-/dev/video0}"

echo "=== Starting WebRTC Stream ==="
echo "Stream Key: $STREAM_KEY"
echo "Server: $SERVER_URL"
echo "Video Device: $VIDEO_DEVICE"
echo

# Video: High quality H.264 with VA-API hardware encoding
# Audio: High quality Opus encoding

gst-launch-1.0 \
  v4l2src device="$VIDEO_DEVICE" \
  ! video/x-raw,width=1920,height=1080,framerate=60/1 \
  ! videoconvert \
  ! 'video/x-raw,format=NV12' \
  ! vaapih264enc \
      rate-control=cbr \
      target-bitrate=8000 \
      keyframe-period=60 \
      quality-level=7 \
      tune=hq \
  ! h264parse \
  ! rtph264pay config-interval=1 pt=96 \
  ! application/x-rtp,media=video,encoding-name=H264,payload=96,clock-rate=90000 \
  ! whip0.sink_0 \
  \
  pulsesrc \
  ! audioconvert \
  ! audioresample \
  ! 'audio/x-raw,rate=48000,channels=2' \
  ! opusenc bitrate=192000 \
  ! rtpopuspay \
  ! application/x-rtp,media=audio,encoding-name=OPUS,payload=96,clock-rate=48000 \
  ! whip0.sink_1 \
  \
  whipsink name=whip0 \
    use-link-headers=true \
    whip-endpoint="$SERVER_URL" \
    auth-token="$STREAM_KEY"
