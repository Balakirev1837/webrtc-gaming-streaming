#!/bin/bash
# stream-av1.sh - AV1 streaming pipeline with RAV1E (software encoding)

STREAM_KEY="${STREAM_KEY:-gaming}"
SERVER_URL="${SERVER_URL:-http://localhost:8080/api/whip}"
VIDEO_DEVICE="${VIDEO_DEVICE:-/dev/video0}"

# Source queue configuration
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/queue-config.sh"

echo "=== Starting AV1 WebRTC Stream (RAV1E) ==="
echo "Stream Key: $STREAM_KEY"
echo "Server: $SERVER_URL"
echo "Video Device: $VIDEO_DEVICE"
echo "Codec: AV1 (RAV1E)"
echo

# Video: AV1 with RAV1E encoder (optimized for CPU efficiency)
# Audio: High quality Opus encoding
# CPU optimizations: Minimal buffers, efficient settings

gst-launch-1.0 \
  v4l2src device="$VIDEO_DEVICE" \
  ! video/x-raw,width=1920,height=1080,framerate=60/1 \
  ! videoconvert ! 'video/x-raw,format=I420' \
  ! $QUEUE_VIDEO_MID_RES \
  ! rav1enc \
      speed-preset=10 \
      bitrate=6000 \
      tiles=4 \
      threads=4 \
      quantizer=100 \
  ! av1parse \
  ! rtpav1pay pt=96 \
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
