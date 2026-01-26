#!/bin/bash
# stream-av1-nvenc.sh - AV1 streaming pipeline with NVENC (NVIDIA RTX 40-series)

STREAM_KEY="${STREAM_KEY:-gaming}"
SERVER_URL="${SERVER_URL:-http://localhost:8080/api/whip}"
VIDEO_DEVICE="${VIDEO_DEVICE:-/dev/video0}"

# Source queue configuration
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/queue-config.sh"

echo "=== Starting AV1 WebRTC Stream (NVENC Hardware) ==="
echo "Stream Key: $STREAM_KEY"
echo "Server: $SERVER_URL"
echo "Video Device: $VIDEO_DEVICE"
echo "Codec: AV1 (NVENC Hardware)"
echo

# Video: AV1 with NVENC hardware encoding (RTX 40-series and newer)
# Audio: High quality Opus encoding

gst-launch-1.0 \
  v4l2src device="$VIDEO_DEVICE" \
  ! video/x-raw,width=1920,height=1080,framerate=60/1 \
  ! videoconvert \
  ! 'video/x-raw,format=NV12' \
  ! $QUEUE_VIDEO_MID_RES \
  ! nvav1enc \
      preset=p4 \
      rc-mode=cbr \
      bitrate=6000000 \
      gop-size=60 \
      tune=ll \
  ! av1parse \
  ! rtpav1pay \
  ! $QUEUE_RTP \
  ! application/x-rtp,media=video,encoding-name=AV1,payload=96,clock-rate=90000 \
  ! whip0. \
  \
  pulsesrc \
  ! audioconvert \
  ! audioresample \
  ! 'audio/x-raw,rate=48000,channels=2' \
  ! $QUEUE_AUDIO \
  ! opusenc bitrate=192000 \
  ! rtpopuspay \
  ! $QUEUE_RTP \
  ! application/x-rtp,media=audio,encoding-name=OPUS,payload=97,clock-rate=48000 \
  ! whip0.sink_1 \
  \
  whipclientsink name=whip0 \
     \
    signaller::signaller::whip-endpoint="$SERVER_URL" \
    signaller::auth-token="$STREAM_KEY"
