#!/bin/bash
# Queue configuration for different resolutions
# Usage: source ./queue-config.sh

# Video queue settings (non-leaky, time-based)
QUEUE_VIDEO_LOW_RES="queue max-size-buffers=5 max-size-time=500000000 max-size-bytes=0"
QUEUE_VIDEO_MID_RES="queue max-size-buffers=10 max-size-time=500000000 max-size-bytes=0"
QUEUE_VIDEO_HIGH_RES="queue max-size-buffers=15 max-size-time=500000000 max-size-bytes=0"

# Audio queue settings (increased from 1 to 10 buffers)
QUEUE_AUDIO="queue max-size-buffers=10 max-size-time=200000000 max-size-bytes=0"

# RTP packet queue
QUEUE_RTP="queue max-size-buffers=5 max-size-time=100000000 max-size-bytes=0"
