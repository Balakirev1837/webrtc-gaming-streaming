#!/bin/bash
# stream-nvenc.sh - High-quality WebRTC streaming with NVENC

STREAM_KEY="${STREAM_KEY:-gaming}"
SERVER_URL="${SERVER_URL:-http://localhost:8080/api/whip}"
VIDEO_DEVICE="${VIDEO_DEVICE:-/dev/video0}"

echo "=== Starting WebRTC Stream (NVENC) ==="
echo "Stream Key: $STREAM_KEY"
echo "Server: $SERVER_URL"
echo "Video Device: $VIDEO_DEVICE"
echo

# Video: High quality H.264 with NVENC
# Audio: High quality Opus encoding

gst-launch-1.0 \
  v4l2src device="$VIDEO_DEVICE" \
  ! video/x-raw,width=1920,height=1080,framerate=60/1 \
  ! videoconvert \
  ! 'video/x-raw,format=NV12' \
  ! nvh264enc \
      preset=p4 \
      rc-mode=cbr \
      bitrate=8000000 \
      gop-size=60 \
      zerolatency=false \
      tune=ll \
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
  whipclientsink name=whip0 \
     \
    signaller::signaller::whip-endpoint="$SERVER_URL" \
    signaller::auth-token="$STREAM_KEY"
