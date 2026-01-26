#!/bin/bash
# stream-av1-vaapi.sh - AV1 streaming pipeline with VA-API (Intel/AMD hardware)

STREAM_KEY="${STREAM_KEY:-gaming}"
SERVER_URL="${SERVER_URL:-http://localhost:8080/api/whip}"
VIDEO_DEVICE="${VIDEO_DEVICE:-/dev/video0}"

echo "=== Starting AV1 WebRTC Stream (VA-API Hardware) ==="
echo "Stream Key: $STREAM_KEY"
echo "Server: $SERVER_URL"
echo "Video Device: $VIDEO_DEVICE"
echo "Codec: AV1 (VA-API Hardware)"
echo

# Video: AV1 with VA-API hardware encoding (Intel Arc/AMD RDNA3+)
# Audio: High quality Opus encoding

gst-launch-1.0 \
  v4l2src device="$VIDEO_DEVICE" \
  ! video/x-raw,width=1920,height=1080,framerate=60/1 \
  ! videoconvert \
  ! 'video/x-raw,format=NV12' \
  ! queue max-size-buffers=0 max-size-time=0 max-size-bytes=0 \
  ! vaapiav1enc \
      rate-control=cbr \
      target-bitrate=6000 \
      keyframe-period=60 \
      quality-level=7 \
      tune=hq \
  ! av1parse \
  ! rtpav1pay \
  ! application/x-rtp,media=video,encoding-name=AV1,payload=96,clock-rate=90000 \
  ! whip0.sink_0 \
  \
  pulsesrc \
  ! audioconvert \
  ! audioresample \
  ! 'audio/x-raw,rate=48000,channels=2' \
  ! queue max-size-buffers=0 max-size-time=0 max-size-bytes=0 \
  ! opusenc bitrate=192000 \
  ! rtpopuspay \
  ! application/x-rtp,media=audio,encoding-name=OPUS,payload=97,clock-rate=48000 \
  ! whip0.sink_1 \
  \
  whipclientsink name=whip0 \
     \
    signaller::signaller::whip-endpoint="$SERVER_URL" \
    signaller::auth-token="$STREAM_KEY"
